// import 'package:flutter_blue_plus/flutter_blue_plus.dart';
// import 'package:montech/providers/sensor_data_provider.dart';
// import 'package:provider/provider.dart';
// import 'package:flutter/material.dart';

// class BluetoothHelper with ChangeNotifier {
//   BluetoothDevice? _connectedDevice;
//   String? _errorMessage;

//   BluetoothDevice? get connectedDevice => _connectedDevice;
//   String? get errorMessage => _errorMessage;

//   Future<void> connectToDevice(
//       BluetoothDevice device, BuildContext context) async {
//     // Cihaz bağlantı durumunu dinleme
//     device.state.listen((state) {
//       if (state == BluetoothDeviceState.connected) {
//         print("Gerçekten bağlandı!");
//       } else {
//         print("Bağlantı durumu: $state");
//       }
//     });

//     try {
//       // Cihaza bağlanma
//       await device.connect();
//       _connectedDevice = device;
//       _errorMessage = null;
//       notifyListeners();

//       // Servisleri keşfetme
//       List<BluetoothService> services = await device.discoverServices();
//       if (services.isNotEmpty) {
//         print("Servisler keşfedildi. Cihaz gerçekten bağlı.");
//         final BluetoothService firstService = services.first;
//         if (firstService.characteristics.isNotEmpty) {
//           final BluetoothCharacteristic characteristic =
//               firstService.characteristics.first;

//           // Veriyi okuma
//           List<int> value = await characteristic.read();
//           print("Veri okundu: $value");

//           // Veriyi SensorDataProvider'a gönderme
//           final sensorDataProvider =
//               Provider.of<SensorDataProvider>(context, listen: false);
//           sensorDataProvider.updateWithBluetoothData(
//               value[0].toInt(), value[1].toDouble());
//         } else {
//           print("İlk serviste karakteristik bulunamadı.");
//           _errorMessage = "İlk serviste karakteristik bulunamadı.";
//           notifyListeners();
//         }
//       } else {
//         print("Servis bulunamadı. Bağlantı sorunlu olabilir.");
//         _errorMessage = "Servis bulunamadı.";
//         notifyListeners();
//       }
//     } catch (e) {
//       _errorMessage = "Bağlantı başarısız oldu: $e";
//       notifyListeners();
//     }
//   }

//   String convertListToString(List<int> value) {
//     return String.fromCharCodes(value);
//   }

//   void parseBluetoothData(List<int> value, BuildContext context) {
//     final sensorDataProvider =
//         Provider.of<SensorDataProvider>(context, listen: false);
//     String data = convertListToString(value);
//     print("Gelen veri:\n$data");

//     try {
//       // Satırlara böl
//       List<String> lines = data.trim().split('\n');
//       double? temp;
//       int? bpm;

//       for (String line in lines) {
//         if (line.contains("İç sıcaklık")) {
//           temp = double.tryParse(line.split(":").last.trim());
//         } else if (line.contains("Nabız")) {
//           bpm = int.tryParse(line.split(":").last.trim());
//         }
//       }

//       if (temp != null && bpm != null) {
//         sensorDataProvider.updateWithBluetoothData(bpm, temp);
//         print("Veri başarıyla güncellendi: $bpm BPM, $temp °C");
//       } else {
//         print("Eksik veri, güncelleme yapılmadı.");
//       }
//     } catch (e) {
//       print("Veri ayrıştırma hatası: $e");
//     }
//   }
// }
