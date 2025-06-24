import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/bluetooth_provider.dart';
import 'bluetooth_connect_screen.dart';
import 'bluetooth_status_screen.dart';

class BluetoothScreen extends StatelessWidget {
  const BluetoothScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bluetoothProvider = Provider.of<BluetoothProvider>(context);

    // BluetoothStatusScreen ve BluetoothConnectScreen arasında geçiş yap
    return bluetoothProvider.isBluetoothOn
        ? const BluetoothConnectScreen()
        : const BluetoothStatusScreen();
  }
}
