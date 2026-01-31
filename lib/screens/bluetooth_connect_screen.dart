import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../widgets/custom_appbar.dart';

class BluetoothConnectScreen extends StatefulWidget {
  const BluetoothConnectScreen({super.key});

  @override
  BluetoothConnectScreenState createState() => BluetoothConnectScreenState();
}

class BluetoothConnectScreenState extends State<BluetoothConnectScreen> {
  final List<BluetoothDevice> devicesList = [];
  bool isScanning = false;
  BluetoothDevice? connectedDevice;
  BluetoothCharacteristic? characteristic;

  @override
  void initState() {
    super.initState();
    FlutterBluePlus.scanResults.listen((scanResults) {
      setState(() {
        devicesList.clear();
        devicesList.addAll(scanResults.map((result) => result.device));
      });
    });
  }

  void startScan() {
    if (!isScanning) {
      FlutterBluePlus.startScan(timeout: const Duration(seconds: 4));
      setState(() {
        isScanning = true;
      });
    }
  }

  void stopScan() {
    if (isScanning) {
      FlutterBluePlus.stopScan();
      setState(() {
        isScanning = false;
      });
    }
  }

  void connectToDevice(BluetoothDevice device) async {
    try {
      await device.connect();
      setState(() {
        connectedDevice = device;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Connected to device: ${device.platformName}")),
        );
      }
      discoverServices(device);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Connection error: $e")),
        );
      }
    }
  }

  void discoverServices(BluetoothDevice device) async {
    List<BluetoothService> services = await device.discoverServices();
    for (BluetoothService service in services) {
      for (BluetoothCharacteristic c in service.characteristics) {
        if (c.properties.read) {
          setState(() {
            characteristic = c;
          });
          readData(c);
        }
      }
    }
  }

  void readData(BluetoothCharacteristic c) async {
    List<int> value = await c.read();
    String data = String.fromCharCodes(value);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Received data: $data")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: "Connect to Bluetooth Device"),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: startScan,
            child: const Text("Start Bluetooth Scan"),
          ),
          ElevatedButton(
            onPressed: stopScan,
            child: const Text("Stop Scan"),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: devicesList.length,
              itemBuilder: (context, index) {
                BluetoothDevice device = devicesList[index];
                return ListTile(
                  title: Text(device.platformName),
                  subtitle: Text(device.remoteId.toString()),
                  onTap: () => connectToDevice(device),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    stopScan();
    super.dispose();
  }
}





// GPT
// import 'package:flutter/material.dart';
// import 'package:flutter_blue_plus/flutter_blue_plus.dart';
// import 'home_screen.dart';

// class BluetoothConnectScreen extends StatefulWidget {
//   @override
//   _BluetoothConnectScreenState createState() => _BluetoothConnectScreenState();
// }

// class _BluetoothConnectScreenState extends State<BluetoothConnectScreen> {
//   List<ScanResult> scanResults = [];
//   bool isScanning = false;
//   BluetoothDevice? connectedDevice;
//   BluetoothCharacteristic? characteristic;

//   @override
//   void initState() {
//     super.initState();
//     FlutterBluePlus.scanResults.listen((results) {
//       setState(() {
//         scanResults = results;
//       });
//     });
//   }

//   void startScan() {
//     if (!isScanning) {
//       FlutterBluePlus.startScan(timeout: Duration(seconds: 4));
//       setState(() {
//         isScanning = true;
//       });
//     }
//   }

//   void stopScan() {
//     if (isScanning) {
//       FlutterBluePlus.stopScan();
//       setState(() {
//         isScanning = false;
//       });
//     }
//   }

//   void connectToDevice(BluetoothDevice device) async {
//     try {
//       await device.connect();
//       setState(() {
//         connectedDevice = device;
//       });
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(
//             "Bağlandı: ${device.remoteId}",
//           ),
//         ),
//       );
//       discoverServices(device);
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Bağlantı hatası: $e")),
//       );
//     }
//   }

//   void discoverServices(BluetoothDevice device) async {
//     List<BluetoothService> services = await device.discoverServices();
//     for (BluetoothService service in services) {
//       for (BluetoothCharacteristic c in service.characteristics) {
//         if (c.properties.read) {
//           setState(() {
//             characteristic = c;
//           });
//           readData(c);
//         }
//       }
//     }
//   }

//   void readData(BluetoothCharacteristic c) async {
//     try {
//       List<int> value = await c.read();
//       String data = String.fromCharCodes(value);

//       // Beklenen format: "pulse:78,temp:36.5"
//       final parts = data.split(",");
//       String pulse =
//           parts.firstWhere((e) => e.startsWith("pulse:")).split(":")[1];
//       String temp =
//           parts.firstWhere((e) => e.startsWith("temp:")).split(":")[1];

//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => HomeScreen(
//             pulse: pulse,
//             temperature: temp,
//           ),
//         ),
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Veri okuma hatası: $e")),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Bluetooth Cihaz Bağlantısı")),
//       body: Column(
//         children: [
//           ElevatedButton(
//             onPressed: startScan,
//             child: Text("Taramayı Başlat"),
//           ),
//           ElevatedButton(
//             onPressed: stopScan,
//             child: Text("Taramayı Durdur"),
//           ),
//           Expanded(
//             child: ListView.builder(
//               itemCount: scanResults.length,
//               itemBuilder: (context, index) {
//                 final result = scanResults[index];
//                 final device = result.device;
//                 final name = result.advertisementData.localName.isNotEmpty
//                     ? result.advertisementData.localName
//                     : "Bilinmeyen Cihaz";

//                 return ListTile(
//                   title: Text(name),
//                   subtitle: Text("MAC: ${device.remoteId}"),
//                   onTap: () => connectToDevice(device),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     stopScan();
//     super.dispose();
//   }
// }












// Main Kod
// import 'package:flutter/material.dart';
// import 'package:flutter_blue_plus/flutter_blue_plus.dart';

// import 'home_screen.dart';

// class BluetoothConnectScreen extends StatefulWidget {
//   @override
//   _BluetoothConnectScreenState createState() => _BluetoothConnectScreenState();
// }

// class _BluetoothConnectScreenState extends State<BluetoothConnectScreen> {
//   final List<BluetoothDevice> devicesList = [];
//   bool isScanning = false;
//   BluetoothDevice? connectedDevice;
//   BluetoothCharacteristic? characteristic;
//   List<ScanResult> scanResults = [];

//   @override
//   void initState() {
//     super.initState();
//     FlutterBluePlus.scanResults.listen((results) {
//       setState(() {
//         scanResults = results;
//       });
//     });
//   }

//   // @override
//   // void initState() {
//   //   super.initState();
//   //   FlutterBluePlus.scanResults.listen((scanResults) {
//   //     setState(() {
//   //       devicesList.clear();
//   //       devicesList.addAll(scanResults.map((result) => result.device));
//   //     });
//   //   });
//   // }
//   void readData(BluetoothCharacteristic c) async {
//     List<int> value = await c.read();
//     String data = String.fromCharCodes(value);

//     // Örnek: "pulse:78,temp:36.5"
//     final parts = data.split(",");
//     String pulse =
//         parts.firstWhere((e) => e.startsWith("pulse:")).split(":")[1];
//     String temp = parts.firstWhere((e) => e.startsWith("temp:")).split(":")[1];

//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => HomeScreen(
//           pulse: pulse,
//           temperature: temp,
//         ),
//       ),
//     );
//   }

//   void startScan() {
//     if (!isScanning) {
//       FlutterBluePlus.startScan(timeout: Duration(seconds: 4));
//       setState(() {
//         isScanning = true;
//       });
//     }
//   }

//   void stopScan() {
//     if (isScanning) {
//       FlutterBluePlus.stopScan();
//       setState(() {
//         isScanning = false;
//       });
//     }
//   }

//   void connectToDevice(BluetoothDevice device) async {
//     try {
//       await device.connect();
//       setState(() {
//         connectedDevice = device;
//       });
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//             content: Text(
//                 "Connected to device: platformName:${device.platformName} remoteId:${device.remoteId}")),
//       );
//       discoverServices(device);
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Connection error: $e")),
//       );
//     }
//   }

//   void discoverServices(BluetoothDevice device) async {
//     List<BluetoothService> services = await device.discoverServices();
//     for (BluetoothService service in services) {
//       for (BluetoothCharacteristic c in service.characteristics) {
//         if (c.properties.read) {
//           setState(() {
//             characteristic = c;
//           });
//           readData(c);
//         }
//       }
//     }
//   }

//   // void readData(BluetoothCharacteristic c) async {
//   //   List<int> value = await c.read();
//   //   String data = String.fromCharCodes(value);
//   //   ScaffoldMessenger.of(context).showSnackBar(
//   //     SnackBar(content: Text("Received data: $data")),
//   //   );
//   // }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Connect to Bluetooth Device")),
//       body: Column(
//         children: [
//           ElevatedButton(
//             onPressed: startScan,
//             child: Text("Start Bluetooth Scan"),
//           ),
//           ElevatedButton(
//             onPressed: stopScan,
//             child: Text("Stop Scan"),
//           ),
//           Expanded(
//             child: ListView.builder(
//               itemCount: scanResults.length,
//               itemBuilder: (context, index) {
//                 final result = scanResults[index];
//                 final device = result.device;
//                 final name = result.advertisementData.localName.isNotEmpty
//                     ? result.advertisementData.localName
//                     : device.platformName;

//                 return ListTile(
//                   title: Text(name),
//                   subtitle: Text("remoteId" +
//                       device.remoteId.toString() +
//                       "platformName:${device.platformName}"), // MAC adresi
//                   onTap: () => connectToDevice(device),
//                 );
//               },
//             ),
//           )
//         ],
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     stopScan();
//     super.dispose();
//   }
// }


