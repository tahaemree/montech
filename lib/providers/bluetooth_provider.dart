import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../services/database_service.dart';
import '../services/background_service.dart';
import '../services/emergency_service.dart';
import '../models/sensor_data.dart';
import '../utils/event_bus.dart';

// Bluetooth ile gelen acil durum event'i
class BluetoothEmergencySignalEvent {}

// Bağlantı durumu event'i (UI bilgilendirme için)
class BluetoothConnectionEvent {
  final bool isConnected;
  final String? deviceName;
  final String? message;

  BluetoothConnectionEvent({
    required this.isConnected,
    this.deviceName,
    this.message,
  });
}

class BluetoothProvider extends ChangeNotifier {
  bool isBluetoothOn = true;
  bool isScanning = false;
  List<BluetoothDevice> devices = [];
  BluetoothDevice? connectedDevice;
  BluetoothCharacteristic? notifyCharacteristic;
  bool _isBluetoothOn = false;
  final List<BluetoothDevice> _devices = [];

  // Veritabanı servisi
  final DatabaseService _databaseService = DatabaseService();
  
  // Bildirim servisi
  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  // Veriler - başlangıç değerleri
  String _bpm = "--";
  String _temperature = "--";
  String _externalTemp = "--";

  // Sensör verileri listesi (grafik için)
  List<SensorData> _sensorHistory = [];

  // Son bağlı cihaz bilgileri
  String? _lastConnectedDeviceId;
  String? _lastConnectedDeviceName;

  // Getterlar
  String get bpm => _bpm;
  String get externalTemp => _externalTemp;
  String get temperature => _temperature;
  List<SensorData> get sensorHistory => _sensorHistory;
  String? get lastConnectedDeviceId => _lastConnectedDeviceId;
  String? get lastConnectedDeviceName => _lastConnectedDeviceName;

  BluetoothProvider() {
    _initNotifications();
    _initDatabase();
    _loadLastConnectedDevice();
    _init();
  }

  // Bildirim sistemini başlat
  Future<void> _initNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);
    await _notifications.initialize(initSettings);
  }

  // Bildirim göster
  Future<void> _showNotification(String title, String body) async {
    const androidDetails = AndroidNotificationDetails(
      'bluetooth_channel',
      'Bluetooth Bildirimleri',
      channelDescription: 'Bluetooth bağlantı durumu bildirimleri',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );
    const details = NotificationDetails(android: androidDetails);
    await _notifications.show(1, title, body, details);
  }

  // Son bağlı cihazı kaydet
  Future<void> _saveLastConnectedDevice(BluetoothDevice device) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('last_device_id', device.remoteId.str);
      await prefs.setString('last_device_name', device.platformName);
      _lastConnectedDeviceId = device.remoteId.str;
      _lastConnectedDeviceName = device.platformName;
      debugPrint("✅ Son bağlı cihaz kaydedildi: ${device.platformName}");
    } catch (e) {
      debugPrint("❌ Son bağlı cihaz kaydedilemedi: $e");
    }
  }

  // Son bağlı cihazı yükle
  Future<void> _loadLastConnectedDevice() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _lastConnectedDeviceId = prefs.getString('last_device_id');
      _lastConnectedDeviceName = prefs.getString('last_device_name');
      
      if (_lastConnectedDeviceId != null) {
        debugPrint("📱 Son bağlı cihaz bulundu: $_lastConnectedDeviceName ($_lastConnectedDeviceId)");
      }
    } catch (e) {
      debugPrint("❌ Son bağlı cihaz yüklenemedi: $e");
    }
  }

  // Veritabanını başlat
  Future<void> _initDatabase() async {
    try {
      await _databaseService.database;
      debugPrint("✅ Veritabanı başarıyla başlatıldı");

      // Son 100 sensör verisini yükle (varsa)
      final latestData = await _databaseService.getLatestSensorData(100);
      if (latestData.isNotEmpty) {
        _sensorHistory = latestData.reversed.toList();
        debugPrint("✅ ${latestData.length} adet geçmiş sensör verisi yüklendi");
      }

      // 30 günden eski verileri temizle
      _databaseService.cleanOldData(daysToKeep: 30);
    } catch (e) {
      debugPrint("❌ Veritabanı başlatma hatası: $e");
    }
  }

  void _init() async {
    debugPrint("_init çağrıldı.");
    FlutterBluePlus.adapterState.listen((state) {
      isBluetoothOn = state == BluetoothAdapterState.on;
      debugPrint("Bluetooth durumu: $isBluetoothOn");

      if (isBluetoothOn) {
        startScan();
        // Bluetooth açıldığında otomatik bağlanmayı dene
        _tryAutoConnect();
      } else {
        devices.clear();
      }

      notifyListeners();
    });
  }

  // Otomatik bağlanma dene
  Future<void> _tryAutoConnect() async {
    if (_lastConnectedDeviceId == null) {
      debugPrint("📱 Otomatik bağlanılacak cihaz yok");
      return;
    }

    if (connectedDevice != null) {
      debugPrint("📱 Zaten bir cihaza bağlı");
      return;
    }

    debugPrint("🔄 Son bağlı cihaza otomatik bağlanma deneniyor: $_lastConnectedDeviceName");
    
    // Biraz bekle - tarama tamamlansın
    await Future.delayed(const Duration(seconds: 3));
    
    // Cihazı bul
    final targetDevice = devices.firstWhere(
      (d) => d.remoteId.str == _lastConnectedDeviceId,
      orElse: () => BluetoothDevice(remoteId: DeviceIdentifier('')),
    );

    if (targetDevice.remoteId.str.isNotEmpty) {
      debugPrint("✅ Son bağlı cihaz bulundu, bağlanılıyor...");
      _showNotification(
        'MonTech Bağlanıyor',
        '$_lastConnectedDeviceName cihazına otomatik bağlanılıyor...',
      );
      await _connectToDeviceInternal(targetDevice, autoConnect: true);
    } else {
      debugPrint("⚠️ Son bağlı cihaz henüz bulunamadı, tarama devam ediyor...");
    }
  }

  String fixTurkishChars(String input) {
    return input
        .replaceAll("Ä°", "İ")
        .replaceAll("Ã§", "ç")
        .replaceAll("Ã¶", "ö")
        .replaceAll("Ã¼", "ü")
        .replaceAll("Ã‡", "Ç")
        .replaceAll("Ã–", "Ö")
        .replaceAll("Ãœ", "Ü")
        .replaceAll("ÅŸ", "ş")
        .replaceAll("ÄŸ", "ğ")
        .replaceAll("Ä±", "ı");
  }

  void updateData(String temperature, String pulse, String externalTemp) {
    debugPrint(
        "updateData çağrıldı: temp=[$temperature], bpm=[$pulse], external_temp=[$externalTemp]");

    // Acil durum sinyali kontrolü
    if (temperature.toLowerCase() == "emergency" ||
        pulse.toLowerCase() == "emergency" ||
        externalTemp.toLowerCase() == "emergency" ||
        temperature.trim().toLowerCase() == "ad" ||
        pulse.trim().toLowerCase() == "ad" ||
        externalTemp.trim().toLowerCase() == "ad") {
      debugPrint("⚠️ ACİL DURUM SİNYALİ ALINDI! ⚠️");
      try {
        eventBus.fire(BluetoothEmergencySignalEvent());
        BackgroundService.triggerEmergencySignal();
        EmergencyService.sendDirectEmergencyAlert();
      } catch (e) {
        debugPrint("⚠️ Acil durum sinyali işlenirken hata: $e");
      }
      return;
    }

    // Verileri güncelle
    _temperature = temperature;
    _bpm = pulse;
    _externalTemp = externalTemp;

    // Veritabanına kaydet
    try {
      final double internalTemp = double.parse(temperature);
      final double extTemp = double.parse(externalTemp);
      final int heartRate = int.parse(pulse);

      final sensorData = SensorData(
        timestamp: DateTime.now(),
        internalTemperature: internalTemp,
        externalTemperature: extTemp,
        heartRate: heartRate,
      );

      _databaseService.insertSensorData(sensorData).then((id) {
        if (id > 0) {
          _sensorHistory.add(sensorData);
          if (_sensorHistory.length > 100) {
            _sensorHistory.removeAt(0);
          }
          debugPrint("✅ Sensör verisi veritabanına kaydedildi: ID=$id");
        }
      });
    } catch (e) {
      debugPrint("❌ Veri dönüştürme hatası: $e");
    }

    debugPrint(
        "Veriler güncellendi: sıcaklık=$_temperature, bpm=$_bpm, dış sıcaklık=$externalTemp");
    notifyListeners();
  }

  Future<void> readCharacteristic(BluetoothCharacteristic characteristic) async {
    try {
      final data = await characteristic.read();
      var decoded = utf8.decode(data);
      decoded = fixTurkishChars(decoded);

      debugPrint('readCharacteristic - Gelen veri: $decoded');

      // Acil durum kodu kontrolü
      if (decoded.trim().toUpperCase() == "AD") {
        debugPrint("⚠️ ACİL DURUM SİNYALİ ALINDI: $decoded ⚠️");
        try {
          eventBus.fire(BluetoothEmergencySignalEvent());
          BackgroundService.triggerEmergencySignal();
          EmergencyService.sendDirectEmergencyAlert();
        } catch (e) {
          debugPrint("⚠️ Acil durum sinyali işlenirken hata: $e");
        }
        return;
      }

      // Normal veri formatını işle
      String? temp;
      String? bpm;
      String? externalTemp;

      final lines = decoded.split('\n');
      for (var line in lines) {
        if (line.startsWith("ic")) {
          temp = line.substring(2).trim();
        } else if (line.startsWith("bpm")) {
          bpm = line.substring(3).trim();
        } else if (line.startsWith("dis")) {
          externalTemp = line.substring(3).trim();
        }
      }

      if (temp != null && bpm != null && externalTemp != null) {
        updateData(temp, bpm, externalTemp);
      }
    } catch (e) {
      debugPrint('readCharacteristic - Veri okuma hatası: $e');
    }
  }

  // StreamSubscription'ları takip et
  StreamSubscription? _scanResultsSubscription;
  StreamSubscription? _isScanningSubscription;

  void startScan() {
    debugPrint("startScan çağrıldı.");

    if (!isBluetoothOn) {
      debugPrint("Bluetooth kapalı, tarama başlatılamadı.");
      return;
    }

    FlutterBluePlus.isScanning.first.then((scanning) async {
      if (scanning) {
        debugPrint("Tarama zaten devam ediyor.");
        return;
      }

      devices.clear();
      isScanning = true;
      notifyListeners();

      // Önceki subscription'ları iptal et
      _scanResultsSubscription?.cancel();
      _isScanningSubscription?.cancel();

      try {
        await FlutterBluePlus.startScan(
          timeout: const Duration(seconds: 15),
          androidUsesFineLocation: false,
        );

        debugPrint("Tarama başlatıldı...");
      } catch (e) {
        debugPrint("Tarama başlatma hatası: $e");
        isScanning = false;
        notifyListeners();
        return;
      }

      _scanResultsSubscription = FlutterBluePlus.scanResults.listen((results) {
        bool devicesAdded = false;

        for (ScanResult r in results) {
          if (!devices.any((d) => d.remoteId == r.device.remoteId)) {
            devices.add(r.device);
            devicesAdded = true;
            debugPrint("Yeni cihaz bulundu: ${r.device.platformName} - ${r.device.remoteId}");
            
            // Eğer bu son bağlı cihazsa ve henüz bağlı değilsek, otomatik bağlan
            if (r.device.remoteId.str == _lastConnectedDeviceId && connectedDevice == null) {
              debugPrint("🔄 Son bağlı cihaz bulundu! Otomatik bağlanılıyor...");
              _connectToDeviceInternal(r.device, autoConnect: true);
            }
          }
        }

        if (devicesAdded) {
          notifyListeners();
        }
      });

      _isScanningSubscription = FlutterBluePlus.isScanning.listen((scanning) {
        isScanning = scanning;
        if (!scanning) {
          debugPrint("Tarama tamamlandı. ${devices.length} cihaz bulundu.");
          notifyListeners();
        }
      });
    });
  }

  // Bağlantı durumu izleme
  StreamSubscription<BluetoothConnectionState>? _connectionStateSubscription;
  bool _isReconnecting = false;

  // Context gerektirmeyen internal bağlantı metodu
  Future<void> _connectToDeviceInternal(BluetoothDevice device, {bool autoConnect = false}) async {
    debugPrint("_connectToDeviceInternal: ${device.platformName} (${device.remoteId})");
    
    try {
      await device.connect(autoConnect: false, timeout: const Duration(seconds: 15));
      connectedDevice = device;
      
      // Son bağlı cihazı kaydet
      await _saveLastConnectedDevice(device);
      
      // Bağlantı bildirimi
      _showNotification(
        'Bağlantı Başarılı',
        '${device.platformName} cihazına bağlanıldı',
      );
      
      // Event gönder
      eventBus.fire(BluetoothConnectionEvent(
        isConnected: true,
        deviceName: device.platformName,
        message: 'Bağlantı başarılı',
      ));
      
      notifyListeners();
      debugPrint("✅ Cihaza bağlanıldı: ${device.platformName}");

      // Bağlantı durumunu izle
      _connectionStateSubscription?.cancel();
      _connectionStateSubscription = device.connectionState.listen((state) {
        debugPrint("📶 Bluetooth bağlantı durumu: $state");
        if (state == BluetoothConnectionState.disconnected && !_isReconnecting) {
          debugPrint("⚠️ Bağlantı kesildi!");
          _handleDisconnectionInternal(device);
        }
      });

      // Servisleri keşfet ve notify ayarla
      await _setupCharacteristics(device);
      
    } catch (e) {
      debugPrint("❌ Bağlanma hatası: $e");
      
      if (autoConnect) {
        _showNotification(
          'Otomatik Bağlantı Başarısız',
          '${device.platformName} cihazına bağlanılamadı',
        );
      }
    }
  }

  // Karakteristikleri ayarla
  Future<void> _setupCharacteristics(BluetoothDevice device) async {
    try {
      List<BluetoothService> services = await device.discoverServices();

      for (BluetoothService service in services) {
        for (BluetoothCharacteristic c in service.characteristics) {
          debugPrint('Servis: ${service.uuid}');
          debugPrint('  Karakteristik: ${c.uuid}');
        }
      }

      final characteristic = services
          .expand((s) => s.characteristics)
          .firstWhere(
            (c) => c.uuid.toString().toLowerCase().contains('ffe1') && c.properties.notify,
            orElse: () => throw Exception('Notify karakteristiği bulunamadı'),
          );

      await characteristic.setNotifyValue(true);
      notifyCharacteristic = characteristic;

      characteristic.onValueReceived.listen((value) {
        var data = String.fromCharCodes(value);
        data = fixTurkishChars(data);

        debugPrint('📱 BLUETOOTH VERİ ALINDI: $data');

        // Acil durum kodu kontrolü
        if (data.trim().toUpperCase() == "AD") {
          debugPrint('⚠️⚠️⚠️ ACİL DURUM SİNYALİ ALINDI ⚠️⚠️⚠️');
          try {
            eventBus.fire(BluetoothEmergencySignalEvent());
            BackgroundService.triggerEmergencySignal();
            EmergencyService.sendDirectEmergencyAlert();
          } catch (e) {
            debugPrint("⚠️ Acil durum sinyali işlenirken hata: $e");
          }
          return;
        }

        // Normal veri işleme
        _parseBluetoothData(data);
      });
    } catch (e) {
      debugPrint("❌ Karakteristik ayarlama hatası: $e");
    }
  }

  // Bluetooth verisini parse et
  void _parseBluetoothData(String data) {
    String? temp;
    String? bpm;
    String? externalTemp;

    final lines = data.split('\n');
    for (final line in lines) {
      if (line.startsWith("ic")) {
        temp = line.substring(2).trim();
      } else if (line.startsWith("bpm")) {
        bpm = line.substring(3).trim();
      } else if (line.startsWith("dis")) {
        externalTemp = line.substring(3).trim();
      }
    }

    // Fallback parsing
    if (temp == null && data.contains("ic")) {
      final icStart = data.indexOf("ic") + 2;
      final icEnd = data.contains("bpm") ? data.indexOf("bpm") : data.length;
      temp = data.substring(icStart, icEnd).trim();
    }

    if (bpm == null && data.contains("bpm")) {
      final bpmStart = data.indexOf("bpm") + 3;
      final bpmEnd = data.contains("dis") ? data.indexOf("dis") : data.length;
      bpm = data.substring(bpmStart, bpmEnd).trim();
    }

    if (externalTemp == null && data.contains("dis")) {
      final disStart = data.indexOf("dis") + 3;
      externalTemp = data.substring(disStart).trim();
    }

    if (temp != null && bpm != null && externalTemp != null) {
      updateData(temp, bpm, externalTemp);
    } else {
      debugPrint("❌ Eksik veri: temp=$temp, bpm=$bpm, extTemp=$externalTemp");
    }
  }

  Future<void> connectToDevice(BluetoothDevice device, BuildContext context) async {
    await _connectToDeviceInternal(device, autoConnect: false);
    
    if (connectedDevice == null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Bağlantı hatası oluştu")),
      );
    }
  }

  Future<void> initializeBluetooth() async {
    debugPrint("initializeBluetooth çağrıldı.");

    try {
      if (await Permission.bluetooth.isDenied) {
        await Permission.bluetooth.request();
        await Future.delayed(const Duration(milliseconds: 500));
      }

      if (await Permission.bluetoothConnect.isDenied) {
        await Permission.bluetoothConnect.request();
        await Future.delayed(const Duration(milliseconds: 500));
      }

      if (await Permission.bluetoothScan.isDenied) {
        await Permission.bluetoothScan.request();
        await Future.delayed(const Duration(milliseconds: 500));
      }

      if (await Permission.locationWhenInUse.isDenied) {
        await Permission.locationWhenInUse.request();
      }

      _isBluetoothOn = await FlutterBluePlus.adapterState.first == BluetoothAdapterState.on;
      debugPrint("Bluetooth ilk durumu: $_isBluetoothOn");
      notifyListeners();

      FlutterBluePlus.adapterState.listen((state) {
        _isBluetoothOn = state == BluetoothAdapterState.on;
        debugPrint("Bluetooth durumu değişti: $_isBluetoothOn");
        if (_isBluetoothOn) {
          startScan();
        } else {
          _devices.clear();
        }
        notifyListeners();
      });

      if (_isBluetoothOn) {
        await Future.delayed(const Duration(milliseconds: 500));
        startScan();
      }
    } catch (e) {
      debugPrint("Bluetooth başlatma hatası: $e");
    }
  }

  // Context gerektirmeyen bağlantı kopma handler'ı
  Future<void> _handleDisconnectionInternal(BluetoothDevice device) async {
    if (_isReconnecting) return;

    _isReconnecting = true;
    connectedDevice = null;
    notifyCharacteristic = null;
    
    // Bildirim göster
    _showNotification(
      'Bağlantı Kesildi',
      '${device.platformName} ile bağlantı kesildi. Yeniden bağlanılıyor...',
    );
    
    // Event gönder
    eventBus.fire(BluetoothConnectionEvent(
      isConnected: false,
      deviceName: device.platformName,
      message: 'Bağlantı kesildi, yeniden bağlanılıyor...',
    ));
    
    notifyListeners();

    // 3 deneme yap
    for (int i = 0; i < 3; i++) {
      try {
        debugPrint("🔄 Yeniden bağlanma denemesi ${i + 1}/3...");
        await Future.delayed(const Duration(seconds: 2));

        if (!isBluetoothOn) {
          debugPrint("❌ Bluetooth kapalı, yeniden bağlanamıyor");
          break;
        }

        await device.connect(autoConnect: false, timeout: const Duration(seconds: 10));
        connectedDevice = device;

        // Servisleri yeniden keşfet
        await _setupCharacteristics(device);

        debugPrint("✅ Yeniden bağlandı!");
        
        _showNotification(
          'Yeniden Bağlandı',
          '${device.platformName} cihazına yeniden bağlanıldı',
        );
        
        eventBus.fire(BluetoothConnectionEvent(
          isConnected: true,
          deviceName: device.platformName,
          message: 'Yeniden bağlanıldı',
        ));
        
        _isReconnecting = false;
        notifyListeners();
        return;
      } catch (e) {
        debugPrint("❌ Yeniden bağlanma hatası: $e");
      }
    }

    _isReconnecting = false;
    
    _showNotification(
      'Bağlantı Başarısız',
      '${device.platformName} ile bağlantı kurulamadı. Lütfen manuel olarak bağlanın.',
    );
    
    eventBus.fire(BluetoothConnectionEvent(
      isConnected: false,
      deviceName: device.platformName,
      message: 'Bağlantı kurulamadı',
    ));
    
    debugPrint("❌ Mont ile bağlantı kurulamadı. Lütfen manuel olarak bağlanın.");
  }

  Future<void> disconnectFromDevice() async {
    debugPrint("disconnectFromDevice çağrıldı.");
    _connectionStateSubscription?.cancel();
    _isReconnecting = true;

    if (connectedDevice != null) {
      try {
        final deviceName = connectedDevice!.platformName;
        await connectedDevice!.disconnect();
        debugPrint("Cihaz bağlantısı kesildi: $deviceName");
        
        _showNotification(
          'Bağlantı Kesildi',
          '$deviceName bağlantısı kapatıldı',
        );
        
        connectedDevice = null;
        notifyCharacteristic = null;
        notifyListeners();
      } catch (e) {
        debugPrint("Bağlantı kesme hatası: $e");
      }
    }

    _isReconnecting = false;
  }

  // Son bağlı cihazı temizle
  Future<void> clearLastConnectedDevice() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('last_device_id');
      await prefs.remove('last_device_name');
      _lastConnectedDeviceId = null;
      _lastConnectedDeviceName = null;
      debugPrint("✅ Son bağlı cihaz bilgisi temizlendi");
    } catch (e) {
      debugPrint("❌ Son bağlı cihaz temizlenemedi: $e");
    }
  }

  // Veritabanı metodları
  Future<List<SensorData>> getSensorDataByDateRange(DateTime startDate, DateTime endDate) async {
    return await _databaseService.getSensorDataByDateRange(startDate, endDate);
  }

  Future<List<SensorData>> getLatestSensorData(int limit) async {
    return await _databaseService.getLatestSensorData(limit);
  }

  Future<List<SensorData>> getTodaysSensorData() async {
    return await _databaseService.getTodaysSensorData();
  }

  Future<List<SensorData>> getLastHourData() async {
    return await _databaseService.getLastHourData();
  }

  // Test için rastgele veri oluştur
  Future<void> generateTestData() async {
    debugPrint("🧪 Test verisi oluşturuluyor...");

    final now = DateTime.now();
    for (int i = 0; i < 20; i++) {
      final timestamp = now.subtract(Duration(minutes: i * 3));
      final sensorData = SensorData(
        timestamp: timestamp,
        internalTemperature: 36.0 + (i % 5) * 0.2,
        externalTemperature: 25.0 + (i % 6) * 0.5,
        heartRate: 70 + (i % 10),
      );

      final id = await _databaseService.insertSensorData(sensorData);
      if (id > 0) {
        _sensorHistory.add(sensorData);
        debugPrint("✅ Test verisi #$i kaydedildi: ID=$id");
      }
    }

    debugPrint("🧪 Toplam ${_sensorHistory.length} test verisi oluşturuldu");
    notifyListeners();
  }

  @override
  void dispose() {
    _scanResultsSubscription?.cancel();
    _isScanningSubscription?.cancel();
    _connectionStateSubscription?.cancel();
    super.dispose();
  }
}
