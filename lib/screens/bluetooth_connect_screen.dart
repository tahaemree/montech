import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../widgets/theme_screen.dart';
import '../widgets/ui_components.dart';

class BluetoothConnectScreen extends StatefulWidget {
  const BluetoothConnectScreen({super.key});

  @override
  State<BluetoothConnectScreen> createState() => _BluetoothConnectScreenState();
}

class _BluetoothConnectScreenState extends State<BluetoothConnectScreen> {
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
      FlutterBluePlus.startScan(timeout: Duration(seconds: 4));
      setState(() {
        isScanning = true;
        devicesList.clear();
      });

      Future.delayed(Duration(seconds: 4), () {
        if (mounted) {
          setState(() {
            isScanning = false;
          });
        }
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

  @override
  void dispose() {
    stopScan();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ThemedScreenScaffold(
      title: 'Bluetooth Bağlantısı',
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: startScan,
          tooltip: 'Yeniden Tara',
        ),
      ],
      bodyPadding: const EdgeInsets.all(16.0),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 70),
          // Durum kartı
          CustomCard(
            child: Column(
              children: [
                const SizedBox(height: 16),
                isScanning
                    ? const Column(
                        children: [
                          SizedBox(
                            width: 40,
                            height: 40,
                            child: CircularProgressIndicator(),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Bluetooth Cihazları Taranıyor...',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      )
                    : Column(
                        children: [
                          Icon(
                            Icons.bluetooth_searching,
                            size: 60,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Yakındaki Cihazları Tara',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: isScanning ? stopScan : startScan,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child:
                      Text(isScanning ? 'Taramayı Durdur' : 'Taramayı Başlat'),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Cihaz listesi başlığı
          Text(
            'Bulunan Cihazlar',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          // Cihaz listesi
          Expanded(
            child: devicesList.isEmpty
                ? Center(
                    child: Text(
                      isScanning
                          ? 'Cihazlar aranıyor...'
                          : 'Hiç cihaz bulunamadı. Tekrar taramak için dokunun.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: theme.textTheme.bodySmall?.color,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: devicesList.length,
                    itemBuilder: (context, index) {
                      final device = devicesList[index];
                      final isConnected = connectedDevice == device;

                      return CustomCard(
                        isHoverable: true,
                        onTap: () async {
                          if (isConnected) {
                            try {
                              await device.disconnect();
                              setState(() {
                                connectedDevice = null;
                              });
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text('Bağlantı kesme hatası: $e')),
                              );
                            }
                          } else {
                            try {
                              await device.connect();
                              setState(() {
                                connectedDevice = device;
                              });
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Bağlantı hatası: $e')),
                              );
                            }
                          }
                        },
                        child: ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isConnected
                                  ? theme.colorScheme.primary.withOpacity(0.2)
                                  : Colors.grey.withOpacity(0.1),
                            ),
                            child: Icon(
                              isConnected
                                  ? Icons.bluetooth_connected
                                  : Icons.bluetooth,
                              color: isConnected
                                  ? theme.colorScheme.primary
                                  : Colors.grey,
                            ),
                          ),
                          title: Text(
                            device.name.isEmpty
                                ? 'Bilinmeyen Cihaz'
                                : device.name,
                            style: TextStyle(
                              fontWeight: isConnected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                          subtitle: Text(device.id.id),
                          trailing: isConnected
                              ? Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary
                                        .withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    'Bağlandı',
                                    style: TextStyle(
                                      color: theme.colorScheme.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                )
                              : const Icon(Icons.arrow_forward_ios, size: 16),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
