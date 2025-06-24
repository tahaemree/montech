import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/bluetooth_provider.dart';
import '../widgets/theme_screen.dart';
import '../widgets/ui_components.dart';

class BluetoothStatusScreen extends StatelessWidget {
  const BluetoothStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bluetoothProvider = Provider.of<BluetoothProvider>(context);
    final theme = Theme.of(context);

    return ThemedScreenScaffold(
      title: 'Bluetooth Durumu',
      bodyPadding: const EdgeInsets.all(16.0),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 60),
          CustomCard(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: bluetoothProvider.isBluetoothOn
                        ? theme.colorScheme.primary.withOpacity(0.2)
                        : Colors.grey.withOpacity(0.2),
                  ),
                  child: Icon(
                    bluetoothProvider.isBluetoothOn
                        ? Icons.bluetooth
                        : Icons.bluetooth_disabled,
                    size: 80,
                    color: bluetoothProvider.isBluetoothOn
                        ? theme.colorScheme.primary
                        : Colors.grey,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  bluetoothProvider.isBluetoothOn
                      ? 'Bluetooth Açık'
                      : 'Bluetooth Kapalı',
                  style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 22,
                      fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 10),
                Text(
                  bluetoothProvider.isBluetoothOn
                      ? 'Cihazınız diğer Bluetooth cihazları tarafından görülebilir'
                      : 'Bluetooth\'u açmanız gerekiyor',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: theme.textTheme.bodySmall?.color,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () {
                    if (bluetoothProvider.isBluetoothOn) {
                      // Cihazla eşleşmek için sonraki sayfaya yönlendir
                      Navigator.pushNamed(context, '/settings');
                    } else {
                      // Bluetooth'u açmalarını öneren bir mesaj göster
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              'Lütfen cihazınızın Bluetooth ayarlarını açın'),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(
                    bluetoothProvider.isBluetoothOn
                        ? 'Cihaz Ayarlarına Git'
                        : 'Bluetooth\'u Aç',
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
          const SizedBox(height: 20),
          if (bluetoothProvider.isBluetoothOn)
            CustomCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'Bluetooth Durumu',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: Icon(Icons.network_wifi,
                        color: theme.colorScheme.primary),
                    title: const Text('Sinyal Durumu'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.signal_cellular_alt,
                            color: theme.colorScheme.primary),
                        const SizedBox(width: 5),
                        Text('Güçlü',
                            style: TextStyle(
                                color: theme.textTheme.bodySmall?.color)),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: Icon(Icons.access_time,
                        color: theme.colorScheme.primary),
                    title: const Text('Son Bağlantı'),
                    trailing: Text('Şu an',
                        style:
                            TextStyle(color: theme.textTheme.bodySmall?.color)),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
