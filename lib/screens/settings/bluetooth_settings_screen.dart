// Şu an için simülasyon yapacağız çünkü gerçek eşleştirme, platform kanal ve izinlerle yönetilir.

import 'package:flutter/material.dart';
import '../../widgets/custom_appbar.dart';

class BluetoothSettingsScreen extends StatefulWidget {
  const BluetoothSettingsScreen({super.key});

  @override
  State<BluetoothSettingsScreen> createState() =>
      _BluetoothSettingsScreenState();
}

class _BluetoothSettingsScreenState extends State<BluetoothSettingsScreen> {
  bool _isBluetoothEnabled = true;
  final List<String> _pairedDevices = [
    "Montech-001",
    "MontCihaz-A",
    "AkıllıMont-3"
  ];

  void _searchForDevices() {
    // Gerçek cihaz arama işlemi yerine simülasyon
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Yeni cihazlar aranıyor...")),
    );

    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _pairedDevices.add("YeniMontCihaz-${_pairedDevices.length + 1}");
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "Bluetooth Ayarları",
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            SwitchListTile(
              title: const Text("Bluetooth Açık"),
              value: _isBluetoothEnabled,
              onChanged: (value) {
                setState(() {
                  _isBluetoothEnabled = value;
                });
              },
              activeColor: Colors.orange,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _isBluetoothEnabled ? _searchForDevices : null,
              icon: const Icon(Icons.search),
              label: const Text("Cihaz Ara"),
            ),
            const SizedBox(height: 20),
            const Text("Eşleşmiş Cihazlar",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: _pairedDevices.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: const Icon(Icons.bluetooth),
                    title: Text(_pairedDevices[index]),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          _pairedDevices.removeAt(index);
                        });
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
