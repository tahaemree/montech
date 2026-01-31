import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'dart:async';

import 'sensor_data_provider.dart';

class BluetoothHelper with ChangeNotifier {
  BluetoothDevice? _connectedDevice;
  Timer? _readTimer;

  /// Başlatma metodu, artık context yerine doğrudan SensorDataProvider alıyor
  Future<void> startReading(
      BluetoothDevice device, SensorDataProvider sensorProvider) async {
    List<BluetoothService> services = await device.discoverServices();
    for (var service in services) {
      debugPrint("Servis: ${service.uuid}");
      for (var characteristic in service.characteristics) {
        debugPrint("  Karakteristik: ${characteristic.uuid}");
        debugPrint("    Properties: ${characteristic.properties}");
      }
    }

    BluetoothCharacteristic? characteristic;
    try {
      characteristic = services.expand((s) => s.characteristics).firstWhere(
        (c) => c.uuid.toString() == '0000ffe1-0000-1000-8000-00805f9b34fb',
      );
    } catch (e) {
      debugPrint("Karakteristik bulunamadı.");
      return; // Metoddan çık
    }

    _readTimer = Timer.periodic(const Duration(seconds: 2), (_) async {
      if (characteristic != null) {
        List<int> data = await characteristic.read();
        _parseAndUpdateSensorData(data, sensorProvider);
      }
    });
  }

  Future<void> connectToDevice(
      BluetoothDevice device, SensorDataProvider sensorProvider) async {
    await device.connect();
    _connectedDevice = device;

    List<BluetoothService> services = await device.discoverServices();
    final characteristic = services
        .expand((service) => service.characteristics)
        .firstWhere((c) => c.properties.read,
            orElse: () => throw Exception("Uygun karakteristik bulunamadı"));

    _readTimer = Timer.periodic(const Duration(seconds: 2), (_) async {
      List<int> data = await characteristic.read();
      _parseAndUpdateSensorData(data, sensorProvider);
    });
    for (var service in services) {
      for (var c in service.characteristics) {
        debugPrint(
            "Servis UUID: ${service.uuid}, Char UUID: ${c.uuid}, Props: ${c.properties}");
        try {
          var val = await c.read();
          debugPrint("-> Okunan veri: ${String.fromCharCodes(val)}");
        } catch (_) {
          debugPrint("-> Okuma başarısız");
        }
      }
    }
  }

  /// Context yerine doğrudan provider nesnesi kullanılıyor
  void _parseAndUpdateSensorData(
      List<int> rawData, SensorDataProvider sensorProvider) {
    String rawText = String.fromCharCodes(rawData);
    debugPrint("Gelen veri: $rawText");

    final tempRegex = RegExp(r"İç sıcaklık\s*:\s*([\d.]+)");
    final bpmRegex = RegExp(r"Nabız\s*:\s*(\d+)");

    double temp =
        double.tryParse(tempRegex.firstMatch(rawText)?.group(1) ?? "0") ?? 0;
    int bpm = int.tryParse(bpmRegex.firstMatch(rawText)?.group(1) ?? "0") ?? 0;

    sensorProvider.updateWithBluetoothData(bpm, temp);
  }

  Future<void> disconnect() async {
    _readTimer?.cancel();
    if (_connectedDevice != null) {
      await _connectedDevice!.disconnect();
      _connectedDevice = null;
    }
  }
}
