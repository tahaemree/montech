import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class BluetoothProvider extends ChangeNotifier {
  bool isBluetoothOn = false;
  List<BluetoothDevice> devices = [];
  BluetoothDevice? connectedDevice;
  BluetoothCharacteristic? notifyCharacteristic;

  String _bpm = "";
  String _temperature = "";
  String _externalTemp = ""; // Değişken adı camelCase olarak düzeltildi

  String get bpm => _bpm;
  String get externalTemp =>
      _externalTemp; // Getter adı camelCase olarak düzeltildi
  String get temperature => _temperature;

  // Used to prevent concurrent permission requests
  bool _isInitializing = false;
  bool _hasBeenInitialized = false;
  Completer<void>? _initializationCompleter;

  BluetoothProvider() {
    // Constructor doesn't call _init() anymore to avoid double initialization
  }

  // This method will be called only once from main.dart
  Future<void> initializeBluetooth() async {
    debugPrint("initializeBluetooth çağrıldı.");

    // If already initialized successfully, just return
    if (_hasBeenInitialized) {
      debugPrint("Bluetooth zaten başlatılmış, tekrar başlatılmıyor.");
      return;
    }

    // If currently initializing, return the same future
    if (_isInitializing) {
      debugPrint("Zaten başlatılıyor, mevcut işlem bekleniyor...");
      return _initializationCompleter?.future;
    }

    // Create a new completer for this initialization
    _isInitializing = true;
    _initializationCompleter = Completer<void>();

    try {
      // Request permissions safely (without causing concurrent requests)
      await _safeRequestPermissions();

      // Check Bluetooth state
      try {
        final state = await FlutterBluePlus.adapterState.first;
        isBluetoothOn = state == BluetoothAdapterState.on;
        debugPrint("Bluetooth durumu: $isBluetoothOn");

        // Try to turn on Bluetooth if it's off
        if (!isBluetoothOn) {
          debugPrint("Bluetooth kapalı, açılması için istek gönderiliyor...");
          await FlutterBluePlus.turnOn().timeout(const Duration(seconds: 5),
              onTimeout: () {
            debugPrint("Bluetooth açma isteği zaman aşımına uğradı");
            return;
          });
        }

        // Setup Bluetooth state listener
        FlutterBluePlus.adapterState.listen((state) {
          isBluetoothOn = state == BluetoothAdapterState.on;
          debugPrint("Bluetooth durumu değişti: $isBluetoothOn");
          if (isBluetoothOn) {
            startScan();
          } else {
            devices.clear();
          }
          notifyListeners();
        });

        // Start scan if Bluetooth is on
        if (isBluetoothOn) {
          startScan();
        }
      } catch (e) {
        debugPrint("Bluetooth durumu alınamadı: $e");
      }

      notifyListeners();
    } finally {
      // Mark initialization as complete
      _isInitializing = false;
      _hasBeenInitialized = true; // Mark as successfully initialized
      _initializationCompleter?.complete();
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
        "updateData çağrıldı: temp=[$temperature], bpm=[$pulse], externalTemp=[$externalTemp]");

    // Verileri güncelle
    _temperature = temperature;
    _bpm = pulse;
    _externalTemp = externalTemp;

    debugPrint(
        "Veriler güncellendi: sıcaklık=$_temperature, bpm=$_bpm, dış sıcaklık=$externalTemp");
    notifyListeners();
  }

  Future<void> readCharacteristic(
      BluetoothCharacteristic characteristic) async {
    try {
      final data = await characteristic.read();
      var decoded = utf8.decode(data);
      decoded = fixTurkishChars(decoded);

      debugPrint('onValueReceived - Gelen veri: $decoded');

      // Satır sonları veya boşluk karakterleriyle ayırıyoruz
      final lines = decoded.split(' ').map((line) => line.trim()).toList();

      String? temp;
      String? bpm;
      String? externalTemp;

      for (var line in lines) {
        if (line.startsWith("ic sicaklik")) {
          temp = line.replaceFirst("ic sicaklik", "").trim();
        } else if (line.startsWith("nabiz")) {
          bpm = line.replaceFirst("nabiz", "").trim();
        } else if (line.startsWith("dis sicaklik")) {
          externalTemp = line.replaceFirst("dis sicaklik", "").trim();
        }
      }
      debugPrint(
          "Ayrıştırılmış: sıcaklık=[$temp], bpm=[$bpm], dış sıcaklık=[$externalTemp]");

      // Eğer her ikisi de bulunduysa, verileri güncelle
      if (temp != null && bpm != null && externalTemp != null) {
        debugPrint("Ayrıştırılmış: sıcaklık=[$temp], bpm=[$bpm]");
        updateData(temp, bpm, externalTemp);
      } else {
        debugPrint("Notify veri formatı beklenenden farklı: $decoded");
      }
    } catch (e) {
      debugPrint('readCharacteristic - Veri okuma hatası: $e');
    }
  }

  void startScan() {
    debugPrint("startScan çağrıldı.");
    if (!isBluetoothOn) {
      debugPrint("Bluetooth kapalı olduğu için tarama başlatılamıyor.");
      return;
    }

    // Var olan cihaz listesini temizle
    devices.clear();
    notifyListeners();

    try {
      // Daha uzun bir tarama süresi ayarla (8 saniye)
      FlutterBluePlus.startScan(timeout: const Duration(seconds: 8));

      // Daha önce eklenmiş bir dinleyici varsa, yeni bir dinleyici eklemeden önce kaldır
      FlutterBluePlus.scanResults.listen((results) {
        bool changed = false;

        for (ScanResult r in results) {
          // RSSI -100'den büyükse (sinyal gücü yeterli) ve listede yoksa ekle
          if (r.rssi > -100 &&
              !devices.any((d) => d.remoteId == r.device.remoteId)) {
            devices.add(r.device);
            changed = true;
            debugPrint(
                "Yeni cihaz bulundu: ${r.device.platformName} (${r.device.remoteId}) - Sinyal: ${r.rssi}");
          }
        }

        // Sadece değişiklik olduysa UI'ı güncelle
        if (changed) {
          debugPrint("Bulunan toplam cihaz sayısı: ${devices.length}");
          notifyListeners();
        }
      }, onError: (error) {
        debugPrint("Tarama hatası: $error");
      });
    } catch (e) {
      debugPrint("startScan hatası: $e");
    }
  }

  Future<void> connectToDevice(
      BluetoothDevice device, BuildContext context) async {
    debugPrint(
        "connectToDevice çağrıldı: ${device.platformName} (${device.remoteId})");

    // Öncelikle izinleri kontrol edelim - hiçbir zaman paralel izin isteği göndermeyelim
    try {
      final bluetoothConnectStatus = await Permission.bluetoothConnect.status;
      final bluetoothScanStatus = await Permission.bluetoothScan.status;

      if (bluetoothConnectStatus != PermissionStatus.granted ||
          bluetoothScanStatus != PermissionStatus.granted) {
        debugPrint("Gerekli izinler eksik, izinleri istiyoruz...");
        // İzinler eksik, güvenli bir şekilde isteyelim
        await _safeRequestPermissions();

        // İzinleri tekrar kontrol edelim
        final newBluetoothConnectStatus =
            await Permission.bluetoothConnect.status;
        final newBluetoothScanStatus = await Permission.bluetoothScan.status;

        if (newBluetoothConnectStatus != PermissionStatus.granted ||
            newBluetoothScanStatus != PermissionStatus.granted) {
          throw Exception(
              "Bluetooth bağlantısı için gerekli izinler verilmedi");
        }
      }

      // Önce mevcut bağlantıları temizleyelim
      if (connectedDevice != null) {
        debugPrint("Önceki bağlantı kesiliyor...");
        try {
          await connectedDevice!.disconnect();
        } catch (e) {
          debugPrint("Önceki bağlantıyı kesme hatası: $e");
        }
        connectedDevice = null;
      }

      // Bağlantı yapmadan önce FlutterBluePlus taramasını durduralım
      try {
        await FlutterBluePlus.stopScan();
        debugPrint("Tarama durduruldu");
      } catch (e) {
        debugPrint("Tarama durdurma hatası: $e");
      }

      // Bluetooth cihazına bağlanma - yeniden deneme mekanizmasıyla
      debugPrint("Cihaza bağlanılıyor...");
      int retryCount = 0;
      const maxRetries = 3;

      while (retryCount < maxRetries) {
        try {
          await device.connect(
              autoConnect: false, timeout: Duration(seconds: 15));
          connectedDevice = device;
          notifyListeners();
          debugPrint("Cihaza başarıyla bağlanıldı!");
          break; // Başarılı bağlantı, döngüden çık
        } catch (e) {
          retryCount++;
          debugPrint("Bağlantı hatası (deneme $retryCount/$maxRetries): $e");
          if (retryCount >= maxRetries) {
            rethrow; // Son denemeden sonra hatayı yeniden fırlat (throw e yerine rethrow)
          }
          // Yeniden denemeden önce kısa bir bekleme
          await Future.delayed(Duration(seconds: 1));
        }
      }

      List<BluetoothService> services = await device.discoverServices();

      for (BluetoothService service in services) {
        for (BluetoothCharacteristic c in service.characteristics) {
          debugPrint('Servis: ${service.uuid}');
          debugPrint('  Karakteristik: ${c.uuid}');
          debugPrint('    Properties: ${c.properties}');
        }
      }

      final characteristic = services
          .expand((s) => s.characteristics)
          .firstWhere(
            (c) =>
                c.uuid.toString().toLowerCase().contains('ffe1') &&
                c.properties.notify,
            orElse: () => throw Exception('Notify karakteristiği bulunamadı'),
          );

      await characteristic.setNotifyValue(true);
      notifyCharacteristic = characteristic;

      characteristic.onValueReceived.listen((value) {
        var data = String.fromCharCodes(value);
        data = fixTurkishChars(data);
        debugPrint('onValueReceived - Gelen veri: $data');

        // Veriyi 'ic sicaklik' ve 'nabiz' kelimeleriyle ayrıştırma
        String? temp;
        String? bpm;
        String? externalTemp;

        if (data.contains("ic sicaklik") &&
            data.contains("nabiz") &&
            data.contains("dis sicaklik")) {
          final icStart = data.indexOf("ic sicaklik") + "ic sicaklik".length;
          final nabizStart = data.indexOf("nabiz");
          final disStart = data.indexOf("dis sicaklik");

          final icSicaklik = data.substring(icStart, nabizStart).trim();
          final nabiz =
              data.substring(nabizStart + "nabiz".length, disStart).trim();
          final disSicaklik =
              data.substring(disStart + "dis sicaklik".length).trim();

          temp = icSicaklik;
          bpm = nabiz;
          externalTemp = disSicaklik;
        }
        // buna gerek olmayabilir
        // 'ic sicaklik' etiketinden iç sıcaklık bilgisini çıkar
        if (data.contains("ic sicaklik")) {
          temp = data.split("ic sicaklik")[1].split("nabiz")[0].trim();
        }

// 'nabiz' etiketinden nabız bilgisini çıkar
        if (data.contains("nabiz")) {
          bpm = data.split("nabiz")[1].split("dis sicaklik")[0].trim();
        }

// 'dis sicaklik' etiketinden dış sıcaklık bilgisini çıkar
        if (data.contains("dis sicaklik")) {
          externalTemp = data.split("dis sicaklik")[1].trim();
        }

// Debug çıktıları sadece değerleri gösterir
        debugPrint("Sıcaklık: $temp");
        debugPrint("Nabız: $bpm");
        debugPrint("Dış Sıcaklık: $externalTemp");

// Eğer tüm değerler geldiyse güncelle
        if (temp != null && bpm != null && externalTemp != null) {
          updateData(temp, bpm, externalTemp);
        } else {
          debugPrint("Beklenen veri formatı eksik: $data");
        }
      });
    } catch (e) {
      debugPrint("Bağlanma hatası: $e");
      // Context kullanımını widget'a devretmek için hatayı tekrar fırlatıyoruz
      // Bu şekilde widget tarafında hata işlenebilir
      rethrow;
    }
  }

  // This method has been moved to the top of the class
  // and replaced with a more robust implementation

  // İzinlerin kontrol edilmesi ve istenmesi
  // Safe method to request permissions that handles concurrency
  Future<void> _safeRequestPermissions() async {
    debugPrint("İzinler güvenli bir şekilde isteniyor...");
    try {
      // Tüm gerekli izinleri tek seferde isteyelim
      Map<Permission, PermissionStatus> statuses = await [
        Permission.bluetooth,
        Permission.bluetoothConnect,
        Permission.bluetoothScan,
        Permission.locationWhenInUse,
        Permission.locationAlways,
      ].request();

      // İzin sonuçlarını logla
      statuses.forEach((permission, status) {
        debugPrint('$permission izin durumu: $status');
      });
    } catch (e) {
      debugPrint("İzin isteme hatası: $e");
    }
  }

  // This method is kept for backward compatibility
  // but delegates to the safe implementation
  Future<void> requestPermissions() async {
    debugPrint("requestPermissions çağrıldı (güvenli metoda yönlendiriliyor)");
    await _safeRequestPermissions();
  }

  Future<void> disconnectFromDevice() async {
    debugPrint("disconnectFromDevice çağrıldı.");
    try {
      await connectedDevice?.disconnect();
      debugPrint("Bağlantı kesildi.");
    } catch (e) {
      debugPrint("Bağlantı kesme hatası: $e");
    } finally {
      connectedDevice = null;
      notifyCharacteristic = null;
      _bpm = "";
      _temperature = "";
      notifyListeners();
    }
  }
}






// Eski
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_blue_plus/flutter_blue_plus.dart';
// import 'package:permission_handler/permission_handler.dart';

// import 'bluetooth_helper.dart';
// import 'sensor_data_provider.dart';

// class BluetoothProvider with ChangeNotifier {
//   bool _isBluetoothOn = false;
//   List<BluetoothDevice> _devices = [];

//   List<BluetoothDevice> get devices => _devices;
//   bool get isBluetoothOn => _isBluetoothOn;

//   BluetoothDevice? _connectedDevice;
//   BluetoothDevice? get connectedDevice => _connectedDevice;



//   Future<void> connectToDevice(
//       BluetoothDevice device, SensorDataProvider sensorProvider) async {
//     try {
//       await device.connect();
//       _connectedDevice = device;
//       notifyListeners();

//       // BluetoothHelper üzerinden veri okumayı başlat
//       final helper = BluetoothHelper();
//       await helper.startReading(device, sensorProvider);
//     } catch (e) {
//       print("Bağlanma hatası: $e");
//     }
//   }

//   Future<void> disconnectFromDevice() async {
//     if (_connectedDevice != null) {
//       try {
//         await _connectedDevice!.disconnect();
//         _connectedDevice = null;
//         notifyListeners();
//       } catch (e) {
//         print("Bağlantıyı kesme hatası: $e");
//       }
//     }
//   }

//   void startScan() {
//     _devices.clear();
//     FlutterBluePlus.startScan(timeout: Duration(seconds: 4));
//     FlutterBluePlus.scanResults.listen((results) {
//       for (var result in results) {
//         if (!_devices.any((d) => d.id == result.device.id)) {
//           _devices.add(result.device);
//         }
//       }
//       notifyListeners();
//     });
//   }
// }




//eski
// import 'package:flutter/material.dart';
// import 'package:flutter_blue_plus/flutter_blue_plus.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:provider/provider.dart';

// import 'sensor_data_provider.dart';

// class BluetoothProvider with ChangeNotifier {
//   bool _isBluetoothOn = false;
//   List<BluetoothDevice> _devices = [];
//   BluetoothDevice? _connectedDevice;
//   String? _errorMessage;

//   bool get isBluetoothOn => _isBluetoothOn;
//   List<BluetoothDevice> get devices => _devices;
//   BluetoothDevice? get connectedDevice => _connectedDevice;
//   String? get errorMessage => _errorMessage;

//   Future<void> initializeBluetooth() async {
//     await _requestPermissions();

//     BluetoothAdapterState state = await FlutterBluePlus.adapterState.first;
//     _isBluetoothOn = state == BluetoothAdapterState.on;
//     notifyListeners();

//     FlutterBluePlus.adapterState.listen((newState) {
//       if (newState == BluetoothAdapterState.on) {
//         _isBluetoothOn = true;
//         startScan();
//       } else {
//         _isBluetoothOn = false;
//         _devices.clear();
//         notifyListeners();
//       }
//     });

//     if (_isBluetoothOn) {
//       startScan();
//     }
//   }

//   void startScan() {
//     _devices.clear();
//     FlutterBluePlus.startScan(timeout: const Duration(seconds: 4));
//     FlutterBluePlus.scanResults.listen((results) {
//       for (var result in results) {
//         if (!_devices.any((d) => d.id == result.device.id)) {
//           _devices.add(result.device);
//         }
//       }
//       notifyListeners();
//     });
//   }

//   Future<void> connectToDevice(BluetoothDevice device) async {
//     try {
//       await device.connect();
//       _connectedDevice = device;
//       _errorMessage = null;
//       notifyListeners();

//       // Bağlantı durumunu dinle
//       device.state.listen((state) {
//         if (state == BluetoothDeviceState.connected) {
//           print("Gerçekten bağlandı!");
//         } else {
//           print("Bağlantı durumu: $state");
//         }
//       });

//       // Servisleri keşfet
//       List<BluetoothService> services = await device.discoverServices();
//       if (services.isNotEmpty) {
//         print("Servisler keşfedildi. Cihaz gerçekten bağlı.");

//         // İlk characteristic üzerinden veri oku
//         for (BluetoothService service in services) {
//           for (BluetoothCharacteristic characteristic
//               in service.characteristics) {
//             if (characteristic.properties.read) {
//               try {
//                 List<int> value = await characteristic.read();
//                 print("Veri okundu: $value");
//               } catch (e) {
//                 print("Veri okunamadı: $e");
//               }
//             }
//           }
//         }
//       } else {
//         print("Servis bulunamadı. Bağlantı sorunlu olabilir.");
//       }
//     } catch (e) {
//       _errorMessage = "Connection failed: $e";
//       notifyListeners();
//     }
//   }

//   Future<void> disconnectFromDevice() async {
//     if (_connectedDevice != null) {
//       try {
//         await _connectedDevice!.disconnect();
//         _connectedDevice = null;
//         notifyListeners();
//       } catch (e) {
//         _errorMessage = "Disconnection failed: \$e";
//         notifyListeners();
//       }
//     }
//   }

//   Future<void> _requestPermissions() async {
//     await [
//       Permission.bluetooth,
//       Permission.bluetoothConnect,
//       Permission.bluetoothScan,
//       Permission.locationWhenInUse,
//     ].request();
//   }
// }
// Main
// import 'package:flutter_blue_plus/flutter_blue_plus.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../providers/sensor_data_provider.dart';

// class BluetoothProvider with ChangeNotifier {
//   bool _isBluetoothOn = false;

//   bool get isBluetoothOn => _isBluetoothOn;

//   Future<void> initializeBluetooth(BuildContext context) async {
//     // İzinleri kontrol et ve iste
//     await _requestPermissions();

//     // Bluetooth'un mevcut durumunu kontrol et
//     BluetoothAdapterState state = await FlutterBluePlus.adapterState.first;
//     _isBluetoothOn = state == BluetoothAdapterState.on;
//     notifyListeners();

//     // Bluetooth kapalıysa, durumu dinle
//     if (!_isBluetoothOn) {
//       FlutterBluePlus.adapterState.listen((newState) {
//         if (newState == BluetoothAdapterState.on) {
//           _isBluetoothOn = true;
//           notifyListeners();
//         }
//       });
//     }

//     // Bluetooth açık ise taramayı başlat
//     if (_isBluetoothOn) {
//       FlutterBluePlus.startScan(
//           timeout: const Duration(seconds: 4)); // Bluetooth taramasını başlat
//       FlutterBluePlus.scanResults.listen((scanResults) {
//         for (ScanResult result in scanResults) {
//           connectToDevice(result.device, context);
//         }
//       });
//     }
//   }

//   // İzinleri kontrol et ve kullanıcıdan izin iste
//   Future<void> _requestPermissions() async {
//     if (await Permission.bluetooth.isDenied) {
//       await Permission.bluetooth.request();
//     }
//     if (await Permission.bluetoothConnect.isDenied) {
//       await Permission.bluetoothConnect.request();
//     }
//     if (await Permission.bluetoothScan.isDenied) {
//       await Permission.bluetoothScan.request();
//     }
//     if (await Permission.locationWhenInUse.isDenied) {
//       await Permission.locationWhenInUse.request();
//     }
//     if (await Permission.locationAlways.isDenied) {
//       await Permission.locationAlways.request(); // Android 10 ve sonrası için
//     }
//   }

//   // İzinlerin durumunu kontrol et
//   Future<void> checkPermissions() async {
//     var bluetoothPermission = await Permission.bluetooth.status;
//     var bluetoothConnectPermission = await Permission.bluetoothConnect.status;
//     var bluetoothScanPermission = await Permission.bluetoothScan.status;
//     var locationPermission = await Permission.locationWhenInUse.status;

//     if (!bluetoothPermission.isGranted) {
//       print("Bluetooth izni verilmedi");
//     } else if (!bluetoothConnectPermission.isGranted) {
//       print("Bluetooth connect izni verilmedi");
//     } else if (!bluetoothScanPermission.isGranted) {
//       print("Bluetooth scan izni verilmedi");
//     } else if (!locationPermission.isGranted) {
//       print("Konum izni verilmedi");
//     }
//   }

//   // Bluetooth izinlerinin kontrol edilmesi, her yeni durumu kontrol etme
//   Future<void> checkBluetoothStatus() async {
//     BluetoothAdapterState state = await FlutterBluePlus.adapterState.first;
//     if (state == BluetoothAdapterState.on) {
//       print("Bluetooth açık");
//     } else if (state == BluetoothAdapterState.off) {
//       print("Bluetooth kapalı");
//     }
//   }

//   void connectToDevice(BluetoothDevice device, BuildContext context) async {
//     try {
//       await device.connect();
//       discoverServices(device, context);
//     } catch (e) {
//       print("Connection error: $e");
//     }
//   }

//   void discoverServices(BluetoothDevice device, BuildContext context) async {
//     List<BluetoothService> services = await device.discoverServices();
//     for (BluetoothService service in services) {
//       for (BluetoothCharacteristic characteristic in service.characteristics) {
//         if (characteristic.properties.read) {
//           characteristic.value.listen((value) {
//             // Assuming the data is in a specific format
//             int newHeartRate = value[0]; // Example: first byte is heart rate
//             double newBodyTemperature = value[1] +
//                 value[2] / 100; // Example: next two bytes are body temperature

//             Provider.of<SensorDataProvider>(context, listen: false)
//                 .updateWithRandomData(); // Bluetooth test ederken updateWithBluetoothData fonksiyonunu kullan
//           });
//         }
//       }
//     }
//   }
// }








// import 'package:flutter_blue_plus/flutter_blue_plus.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../providers/sensor_data_provider.dart';

// class BluetoothProvider with ChangeNotifier {
//   bool _isBluetoothOn = false;

//   bool get isBluetoothOn => _isBluetoothOn;

//   Future<void> initializeBluetooth(BuildContext context) async {
//     // İzinleri kontrol et ve iste
//     await _requestPermissions();

//     // Bluetooth'un mevcut durumunu kontrol et
//     BluetoothAdapterState state = await FlutterBluePlus.adapterState.first;
//     _isBluetoothOn = state == BluetoothAdapterState.on;
//     notifyListeners();

//     // Bluetooth kapalıysa, durumu dinle
//     if (!_isBluetoothOn) {
//       FlutterBluePlus.adapterState.listen((newState) {
//         if (newState == BluetoothAdapterState.on) {
//           _isBluetoothOn = true;
//           notifyListeners();
//         }
//       });
//     }

//     // Bluetooth açık ise taramayı başlat
//     if (_isBluetoothOn) {
//       FlutterBluePlus.startScan(
//           timeout: const Duration(seconds: 4)); // Bluetooth taramasını başlat
//       FlutterBluePlus.scanResults.listen((scanResults) {
//         for (ScanResult result in scanResults) {
//           connectToDevice(result.device, context);
//         }
//       });
//     }
//   }

//   // İzinleri kontrol et ve kullanıcıdan izin iste
//   Future<void> _requestPermissions() async {
//     if (await Permission.bluetooth.isDenied) {
//       await Permission.bluetooth.request();
//     }
//     if (await Permission.bluetoothConnect.isDenied) {
//       await Permission.bluetoothConnect.request();
//     }
//     if (await Permission.bluetoothScan.isDenied) {
//       await Permission.bluetoothScan.request();
//     }
//     if (await Permission.locationWhenInUse.isDenied) {
//       await Permission.locationWhenInUse.request();
//     }
//     if (await Permission.locationAlways.isDenied) {
//       await Permission.locationAlways.request(); // Android 10 ve sonrası için
//     }
//   }

//   // İzinlerin durumunu kontrol et
//   Future<void> checkPermissions() async {
//     var bluetoothPermission = await Permission.bluetooth.status;
//     var bluetoothConnectPermission = await Permission.bluetoothConnect.status;
//     var bluetoothScanPermission = await Permission.bluetoothScan.status;
//     var locationPermission = await Permission.locationWhenInUse.status;

//     if (!bluetoothPermission.isGranted) {
//       print("Bluetooth izni verilmedi");
//     } else if (!bluetoothConnectPermission.isGranted) {
//       print("Bluetooth connect izni verilmedi");
//     } else if (!bluetoothScanPermission.isGranted) {
//       print("Bluetooth scan izni verilmedi");
//     } else if (!locationPermission.isGranted) {
//       print("Konum izni verilmedi");
//     }
//   }

//   // Bluetooth izinlerinin kontrol edilmesi, her yeni durumu kontrol etme
//   Future<void> checkBluetoothStatus() async {
//     BluetoothAdapterState state = await FlutterBluePlus.adapterState.first;
//     if (state == BluetoothAdapterState.on) {
//       print("Bluetooth açık");
//     } else if (state == BluetoothAdapterState.off) {
//       print("Bluetooth kapalı");
//     }
//   }

//   void connectToDevice(BluetoothDevice device, BuildContext context) async {
//     try {
//       await device.connect();
//       discoverServices(device, context);
//     } catch (e) {
//       print("Connection error: $e");
//     }
//   }

//   void discoverServices(BluetoothDevice device, BuildContext context) async {
//     List<BluetoothService> services = await device.discoverServices();
//     for (BluetoothService service in services) {
//       for (BluetoothCharacteristic characteristic in service.characteristics) {
//         if (characteristic.properties.read) {
//           characteristic.value.listen((value) {
//             // Assuming the data is in a specific format
//             int newHeartRate = value[0]; // Example: first byte is heart rate
//             double newBodyTemperature = value[1] +
//                 value[2] / 100; // Example: next two bytes are body temperature

//             Provider.of<SensorDataProvider>(context, listen: false)
//                 .updateWithBluetoothData(newHeartRate, newBodyTemperature);
//           });
//         }
//       }
//     }
//   }
// }




// import 'package:flutter_blue_plus/flutter_blue_plus.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:flutter/material.dart';

// class BluetoothProvider with ChangeNotifier {
//   bool _isBluetoothOn = false;

//   bool get isBluetoothOn => _isBluetoothOn;

//   Future<void> initializeBluetooth() async {
//     // İzinleri kontrol et ve iste
//     await _requestPermissions();

//     // Bluetooth'un mevcut durumunu kontrol et
//     BluetoothAdapterState state = await FlutterBluePlus.adapterState.first;
//     _isBluetoothOn = state == BluetoothAdapterState.on;
//     notifyListeners();

//     // Bluetooth kapalıysa, durumu dinle
//     if (!_isBluetoothOn) {
//       FlutterBluePlus.adapterState.listen((newState) {
//         if (newState == BluetoothAdapterState.on) {
//           _isBluetoothOn = true;
//           notifyListeners();
//         }
//       });
//     }

//     // Bluetooth açık ise taramayı başlat
//     if (_isBluetoothOn) {
//       FlutterBluePlus.startScan(
//           timeout: const Duration(seconds: 4)); // Bluetooth taramasını başlat
//     }
//   }

//   // İzinleri kontrol et ve kullanıcıdan izin iste
//   Future<void> _requestPermissions() async {
//     if (await Permission.bluetooth.isDenied) {
//       await Permission.bluetooth.request();
//     }
//     if (await Permission.bluetoothConnect.isDenied) {
//       await Permission.bluetoothConnect.request();
//     }
//     if (await Permission.bluetoothScan.isDenied) {
//       await Permission.bluetoothScan.request();
//     }
//     if (await Permission.locationWhenInUse.isDenied) {
//       await Permission.locationWhenInUse.request();
//     }
//     if (await Permission.locationAlways.isDenied) {
//       await Permission.locationAlways.request(); // Android 10 ve sonrası için
//     }
//   }

//   // İzinlerin durumunu kontrol et
//   Future<void> checkPermissions() async {
//     var bluetoothPermission = await Permission.bluetooth.status;
//     var bluetoothConnectPermission = await Permission.bluetoothConnect.status;
//     var bluetoothScanPermission = await Permission.bluetoothScan.status;
//     var locationPermission = await Permission.locationWhenInUse.status;

//     if (!bluetoothPermission.isGranted) {
//       print("Bluetooth izni verilmedi");
//     } else if (!bluetoothConnectPermission.isGranted) {
//       print("Bluetooth connect izni verilmedi");
//     } else if (!bluetoothScanPermission.isGranted) {
//       print("Bluetooth scan izni verilmedi");
//     } else if (!locationPermission.isGranted) {
//       print("Konum izni verilmedi");
//     }
//   }

//   // Bluetooth izinlerinin kontrol edilmesi, her yeni durumu kontrol etme
//   Future<void> checkBluetoothStatus() async {
//     BluetoothAdapterState state = await FlutterBluePlus.adapterState.first;
//     if (state == BluetoothAdapterState.on) {
//       print("Bluetooth açık");
//     } else if (state == BluetoothAdapterState.off) {
//       print("Bluetooth kapalı");
//     }
//   }
// }
