import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:battery_plus/battery_plus.dart';
import '../providers/sensor_data_provider.dart';
import '../providers/bluetooth_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/navigation_provider.dart';

import '../utils/event_bus.dart';
import 'bluetooth_screen.dart';
import 'map_screen.dart';
import 'settings_screen.dart';
import 'package:montech/services/emergency_service.dart';

class HomeScreen extends StatefulWidget {
  final String? pulse;
  final String? temperature;
  final String? externalTemp;

  const HomeScreen(
      {super.key, this.pulse, this.temperature, this.externalTemp});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final int _selectedIndex = 0;
  final Battery _battery = Battery();
  int _batteryLevel = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadBatteryLevel();
      _updateBatteryLevel();
    });
  }

  void _loadBatteryLevel() async {
    final level = await _battery.batteryLevel;
    setState(() {
      _batteryLevel = level;
    });
  }

  void _updateBatteryLevel() async {
    final level = await _battery.batteryLevel;
    setState(() {
      _batteryLevel = level;
    });
  }

  void _showEmergencyDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.warning_amber_rounded, color: Colors.red),
            ),
            const SizedBox(width: 12),
            const Text('Acil Durum'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tüm kayıtlı acil durum kişilerine konum bilgisiyle birlikte mesaj gönderilecektir.'),
            SizedBox(height: 12),
            Text(
              'Konum kapalıysa otomatik olarak açılacak ve doğru konum alındıktan sonra gönderilecektir.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('İptal'),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.send, size: 18),
            label: const Text('Tüm Kişilere Gönder'),
            onPressed: () {
              Navigator.pop(dialogContext);
              _sendToAllContacts();
            },
          ),
        ],
      ),
    );
  }

  void _sendToAllContacts() async {
    // Loading dialog göster
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Acil durum mesajları gönderiliyor...'),
            SizedBox(height: 8),
            Text(
              'Konum alınıyor ve mesajlar gönderiliyor',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );

    try {
      await EmergencyService.sendToAllContacts(context);
      
      if (mounted) {
        Navigator.of(context).pop(); // Loading dialog'u kapat
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Acil durum mesajları gönderildi'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildHomeTab() {
    final sensorData = Provider.of<SensorDataProvider>(context);
    final bluetoothProvider = Provider.of<BluetoothProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: ListView(
        children: [
          // Bluetooth Bağlantı Durumu Kartı
          _buildBluetoothStatusCard(bluetoothProvider, themeProvider),
          const SizedBox(height: 16),
          
          // Sensör Bilgileri Kartı
          Card(
            elevation: 3,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    themeProvider.isDarkMode
                        ? const Color(0xFF2C2C2C)
                        : Colors.white,
                    themeProvider.isDarkMode
                        ? const Color(0xFF3A3A3A)
                        : const Color(0xFFF8F9FA),
                  ],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.sensors,
                              color: Theme.of(context).primaryColor,
                              size: 22,
                            ),
                            const SizedBox(width: 8),
                            const Text('Sensör Verileri',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.bar_chart),
                              color: Theme.of(context).primaryColor,
                              onPressed: () {
                                _showGraphTypeSelectionDialog(context);
                              },
                              tooltip: 'Grafikleri Görüntüle',
                            ),
                            Icon(
                              bluetoothProvider.isBluetoothOn
                                  ? Icons.bluetooth_connected
                                  : Icons.bluetooth_disabled,
                              color: bluetoothProvider.isBluetoothOn
                                  ? Theme.of(context).primaryColor
                                  : Colors.grey,
                            ),
                          ],
                        ),
                      ],
                    ),
                    const Divider(),
                    const SizedBox(height: 10),
                    Consumer<BluetoothProvider>(
                      builder: (context, bluetoothProvider, child) {
                        final temperature = bluetoothProvider.temperature;
                        final pulse = bluetoothProvider.bpm;
                        final externalTemp = bluetoothProvider.externalTemp;

                        return Column(
                          children: [
                            _buildSensorDataTile(
                              icon: Icons.thermostat_outlined,
                              title: "İç Sıcaklık",
                              value: "$temperature °C",
                              color: Colors.orange.shade700,
                            ),
                            const SizedBox(height: 12),
                            _buildSensorDataTile(
                              icon: Icons.ac_unit_outlined,
                              title: "Dış Sıcaklık",
                              value: "$externalTemp °C",
                              color: Colors.blue.shade700,
                            ),
                            const SizedBox(height: 12),
                            _buildSensorDataTile(
                              icon: Icons.favorite_outline,
                              title: "Nabız",
                              value: "$pulse bpm",
                              color: Colors.red.shade700,
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Batarya Bilgileri Kartı
          Card(
            elevation: 3,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    themeProvider.isDarkMode
                        ? const Color(0xFF2C2C2C)
                        : Colors.white,
                    themeProvider.isDarkMode
                        ? const Color(0xFF3A3A3A)
                        : const Color(0xFFF8F9FA),
                  ],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.battery_charging_full,
                              color: Theme.of(context).primaryColor,
                              size: 22,
                            ),
                            const SizedBox(width: 8),
                            const Text('Batarya Durumu',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        Icon(
                          sensorData.heatingEnabled
                              ? Icons.whatshot
                              : Icons.ac_unit,
                          color: sensorData.heatingEnabled
                              ? Colors.orange
                              : Colors.blue,
                        ),
                      ],
                    ),
                    const Divider(),
                    const SizedBox(height: 14),
                    _buildBatteryTile(
                      title: "Telefon Şarjı",
                      level: _batteryLevel,
                      color: _batteryLevel > 50
                          ? Colors.green
                          : _batteryLevel > 20
                              ? Colors.orange
                              : Colors.red,
                      status: _batteryLevel < 20
                          ? "Dikkat"
                          : _batteryLevel < 50
                              ? "Normal"
                              : "Çok iyi",
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 25),

          // Acil Durum Butonu
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Column(
              children: [
                Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                    gradient: const RadialGradient(
                      colors: [Colors.red, Color(0xFFAA0000)],
                      radius: 0.8,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withOpacity(0.4),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _showEmergencyDialog,
                      customBorder: const CircleBorder(),
                      splashColor: Colors.white.withOpacity(0.3),
                      child: const Center(
                        child: Text(
                          'ACİL\nDURUM',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Acil durumda yardım çağırmak için butona basın',
                  style: TextStyle(
                    fontSize: 13,
                    color: themeProvider.isDarkMode
                        ? Colors.grey.shade400
                        : Colors.grey.shade700,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Sensör veri kutusu widgetı
  Widget _buildSensorDataTile({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDark = themeProvider.isDarkMode;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF232323) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Batarya durum kutusu widgetı
  Widget _buildBatteryTile({
    required String title,
    required int level,
    required Color color,
    String? status,
  }) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDark = themeProvider.isDarkMode;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF232323) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          children: [
            Icon(
              level > 80
                  ? Icons.battery_full
                  : level > 50
                      ? Icons.battery_5_bar
                      : level > 20
                          ? Icons.battery_3_bar
                          : Icons.battery_alert,
              color: color,
              size: 28,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: level / 100,
                            backgroundColor: isDark
                                ? Colors.grey.shade800
                                : Colors.grey.shade200,
                            color: color,
                            minHeight: 8,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '%$level',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (status != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: _getStatusColor(status),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'dikkat':
      case 'düşük':
        return Colors.orange;
      case 'çok iyi':
      case 'iyi':
        return Colors.green;
      case 'normal':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  // Grafik seçenekleri diyalogunu göster

  // Grafik tipi seçim diyalogu
  void _showGraphTypeSelectionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Görüntülenecek Grafik'),
        content: const Text('Hangi veri grafiğini görüntülemek istiyorsunuz?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // İç sıcaklık grafiğini seç
              eventBus.fire(GraphTypeSelectedEvent('internal_temp'));
              selectedGraphType = 'internal_temp';
              // Grafik ekranına geç
              final navigationProvider =
                  Provider.of<NavigationProvider>(context, listen: false);
              navigationProvider.changeTab(3);
            },
            child: const Text('İç Sıcaklık'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Dış sıcaklık grafiğini seç
              eventBus.fire(GraphTypeSelectedEvent('external_temp'));
              selectedGraphType = 'external_temp';
              // Grafik ekranına geç
              final navigationProvider =
                  Provider.of<NavigationProvider>(context, listen: false);
              navigationProvider.changeTab(3);
            },
            child: const Text('Dış Sıcaklık'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Nabız grafiğini seç
              eventBus.fire(GraphTypeSelectedEvent('heart_rate'));
              selectedGraphType = 'heart_rate';
              // Grafik ekranına geç
              final navigationProvider =
                  Provider.of<NavigationProvider>(context, listen: false);
              navigationProvider.changeTab(3);
            },
            child: const Text('Nabız'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
        ],
      ),
    );
  }

  Widget _buildBluetoothStatusCard(BluetoothProvider bluetoothProvider, ThemeProvider themeProvider) {
    final isConnected = bluetoothProvider.connectedDevice != null;
    final deviceName = bluetoothProvider.connectedDevice?.platformName ?? 
                       bluetoothProvider.lastConnectedDeviceName ?? 'Bilinmiyor';

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isConnected
                ? [Colors.green.withOpacity(0.1), Colors.green.withOpacity(0.05)]
                : [Colors.orange.withOpacity(0.1), Colors.orange.withOpacity(0.05)],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Bluetooth ikonu
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isConnected 
                      ? Colors.green.withOpacity(0.15) 
                      : Colors.orange.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isConnected ? Icons.bluetooth_connected : Icons.bluetooth_searching,
                  color: isConnected ? Colors.green : Colors.orange,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              
              // Durum bilgisi
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isConnected ? 'Mont Bağlı' : 'Mont Bağlı Değil',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: isConnected ? Colors.green[700] : Colors.orange[700],
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isConnected 
                          ? deviceName
                          : bluetoothProvider.lastConnectedDeviceName != null
                              ? 'Son: $deviceName (Aranıyor...)'
                              : 'Bluetooth ekranından bağlanın',
                      style: TextStyle(
                        fontSize: 12,
                        color: themeProvider.isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              
              // Bağlan/Kes butonu
              if (!isConnected && bluetoothProvider.lastConnectedDeviceId != null)
                TextButton.icon(
                  onPressed: () {
                    bluetoothProvider.startScan();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Cihaz aranıyor...')),
                    );
                  },
                  icon: Icon(
                    Icons.refresh,
                    size: 18,
                    color: Colors.orange[700],
                  ),
                  label: Text(
                    'Ara',
                    style: TextStyle(color: Colors.orange[700]),
                  ),
                ),
              
              if (isConnected)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.green.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'Aktif',
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> widgetOptions = <Widget>[
      _buildHomeTab(),
      const MapScreen(),
      const BluetoothScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: widgetOptions.elementAt(_selectedIndex),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }
}
