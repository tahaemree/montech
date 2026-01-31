import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/bluetooth_provider.dart';
import '../widgets/custom_appbar.dart';

class BluetoothStatusScreen extends StatelessWidget {
  const BluetoothStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bluetoothProvider = Provider.of<BluetoothProvider>(context);

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Bluetooth Durumu',
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              bluetoothProvider.isBluetoothOn
                  ? Icons.bluetooth
                  : Icons.bluetooth_disabled,
              size: 80,
              color:
                  bluetoothProvider.isBluetoothOn ? Colors.blue : Colors.grey,
            ),
            const SizedBox(height: 20),
            Text(
              bluetoothProvider.isBluetoothOn
                  ? "Bluetooth açık"
                  : "Bluetooth kapalı",
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                bluetoothProvider.initializeBluetooth();
              },
              child: const Text("Bluetooth'u Kontrol Et"),
            ),
          ],
        ),
      ),
    );
  }
}
// Main
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// import '../providers/bluetooth_provider.dart';

// class BluetoothStatusScreen extends StatelessWidget {
//   const BluetoothStatusScreen({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final bluetoothProvider = Provider.of<BluetoothProvider>(context);

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Bluetooth Durumu'),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               bluetoothProvider.isBluetoothOn
//                   ? Icons.bluetooth
//                   : Icons.bluetooth_disabled,
//               size: 80,
//               color:
//                   bluetoothProvider.isBluetoothOn ? Colors.blue : Colors.grey,
//             ),
//             const SizedBox(height: 20),
//             Text(
//               bluetoothProvider.isBluetoothOn
//                   ? "Bluetooth açık"
//                   : "Bluetooth kapalı",
//               style: const TextStyle(fontSize: 24),
//             ),
//             const SizedBox(height: 40),
//             ElevatedButton(
//               onPressed: () {
//                 bluetoothProvider.initializeBluetooth(context);
//               },
//               child: const Text("Bluetooth'u Kontrol Et"),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
