import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/bluetooth_provider.dart';

class BluetoothScreen extends StatefulWidget {
  const BluetoothScreen({super.key});

  @override
  State<BluetoothScreen> createState() => _BluetoothScreenState();
}

class _BluetoothScreenState extends State<BluetoothScreen> {
  @override
  void initState() {
    super.initState();
    // Ekran açıldığında ilk taramayı başlat
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final bluetoothProvider =
          Provider.of<BluetoothProvider>(context, listen: false);
      if (bluetoothProvider.isBluetoothOn &&
          bluetoothProvider.devices.isEmpty) {
        startScan();
      }
    });
  }

  void startScan() {
    final bluetoothProvider =
        Provider.of<BluetoothProvider>(context, listen: false);
    if (bluetoothProvider.isBluetoothOn) {
      bluetoothProvider.startScan();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Bluetooth kapalı. Lütfen önce Bluetooth\'u açın.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bluetoothProvider = Provider.of<BluetoothProvider>(context);

    return Scaffold(
      body: bluetoothProvider.isBluetoothOn
          ? Column(
              children: [
                if (bluetoothProvider.isScanning)
                  Container(
                    color: Colors.blue.withOpacity(0.1),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: const Center(
                      child: Text(
                        'Cihazlar taranıyor... Bulunan cihazlar aşağıda listeleniyor.',
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ),
                    ),
                  ),
                Expanded(
                  child: bluetoothProvider.devices.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (bluetoothProvider.isScanning)
                                const CircularProgressIndicator()
                              else
                                const Icon(Icons.bluetooth_searching,
                                    size: 64, color: Colors.blue),
                              const SizedBox(height: 16),
                              Text(
                                bluetoothProvider.isScanning
                                    ? 'Cihazlar aranıyor...'
                                    : 'Hiç cihaz bulunamadı',
                                style: const TextStyle(fontSize: 16),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Cihaz bulunamazsa, yenileme butonuna basın',
                                style:
                                    TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          itemCount: bluetoothProvider.devices.length,
                          separatorBuilder: (context, index) =>
                              const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final device = bluetoothProvider.devices[index];
                            final name = device.platformName.isNotEmpty
                                ? device.platformName
                                : "Bilinmeyen Cihaz";
                            final isConnected =
                                bluetoothProvider.connectedDevice?.remoteId ==
                                    device.remoteId;

                            return Card(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 8.0, vertical: 4.0),
                              elevation: 1,
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16.0, vertical: 8.0),
                                leading: Container(
                                  padding: const EdgeInsets.all(8.0),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  child: const Icon(Icons.bluetooth,
                                      color: Colors.blue),
                                ),
                                title: Text(
                                  name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(device.remoteId.str),
                                    if (isConnected)
                                      Container(
                                        margin: const EdgeInsets.only(top: 4),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.green.withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        child: const Text(
                                          'Bağlı',
                                          style: TextStyle(
                                              color: Colors.green,
                                              fontSize: 12),
                                        ),
                                      ),
                                  ],
                                ),
                                trailing: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isConnected
                                        ? Colors.red.shade100
                                        : Colors.blue,
                                    foregroundColor:
                                        isConnected ? Colors.red : Colors.white,
                                  ),
                                  onPressed: () {
                                    if (isConnected) {
                                      bluetoothProvider.disconnectFromDevice();
                                    } else {
                                      bluetoothProvider.connectToDevice(
                                          device, context);
                                    }
                                  },
                                  child: Text(isConnected
                                      ? 'Bağlantıyı Kes'
                                      : 'Bağlan'),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            )
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.bluetooth_disabled,
                      size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text("Bluetooth kapalı. Lütfen açınız.",
                      style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      // Bluetooth durumunu kontrol et (örnek kod, senin projenin içeriğine göre değişebilir)
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text(
                                'Lütfen telefonunuzun ayarlarından Bluetooth\'u açın')),
                      );
                    },
                    child: const Text('Bluetooth Durumunu Kontrol Et'),
                  ),
                ],
              ),
            ),
    );
  }
}
