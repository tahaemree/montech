import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:battery_plus/battery_plus.dart';
import '../providers/sensor_data_provider.dart';
import '../providers/bluetooth_provider.dart';
import '../widgets/data_row.dart';
import 'package:montech/services/emergency_service.dart';

class HomeScreen extends StatefulWidget {
  final String? pulse;
  final String? temperature;
  final String? externalTemp; // camelCase olarak değiştirildi

  const HomeScreen(
      {this.pulse,
      this.temperature,
      this.externalTemp,
      super.key}); // super parameter kullanımı

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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

  // NavigationScreen tarafından yönetildiği için bu metod kaldırıldı

  void _showEmergencyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Acil Durum Seçimi'),
        content:
            const Text('Lütfen mesajı nasıl göndermek istediğinizi seçin:'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              EmergencyService.sendEmergencySMS();
            },
            child: const Text('SMS ile gönder'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              EmergencyService.sendWhatsAppWithLocation();
            },
            child: const Text('WhatsApp ile gönder'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
        ],
      ),
    );
  }

  Widget _buildHomeTab() {
    final sensorData = Provider.of<SensorDataProvider>(context);
    final bluetoothProvider = Provider.of<BluetoothProvider>(context);

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: ListView(
        children: [
          // Sensör Bilgileri Kartı
          Card(
            elevation: 4,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Sensör Bilgileri',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      Icon(
                        bluetoothProvider.isBluetoothOn
                            ? Icons.bluetooth_connected
                            : Icons.bluetooth_disabled,
                        color: bluetoothProvider.isBluetoothOn
                            ? Colors.blue
                            : Colors.grey,
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
                      final bool isDeviceConnected =
                          bluetoothProvider.connectedDevice != null;
                      final bool hasNoData = temperature.isEmpty &&
                          pulse.isEmpty &&
                          externalTemp.isEmpty;

                      if (!isDeviceConnected || hasNoData) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                !isDeviceConnected
                                    ? Icons.bluetooth_disabled
                                    : Icons.sensors_off,
                                size: 64,
                                color: Colors.grey,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                !isDeviceConnected
                                    ? "Cihaz bağlı değil"
                                    : "Sensör verisi alınamıyor",
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 8),
                            ],
                          ),
                        );
                      }

                      return Column(
                        children: [
                          Card(
                            child: ListTile(
                              leading: const Icon(Icons.thermostat),
                              title: const Text("İç Sıcaklık"),
                              subtitle: Text(temperature.isNotEmpty
                                  ? "$temperature °C"
                                  : "Veri yok"),
                            ),
                          ),
                          Card(
                            child: ListTile(
                              leading: const Icon(Icons.thermostat),
                              title: const Text("Dış Sıcaklık"),
                              subtitle: Text(externalTemp.isNotEmpty
                                  ? "$externalTemp °C"
                                  : "Veri yok"),
                            ),
                          ),
                          Card(
                            child: ListTile(
                              leading: const Icon(Icons.favorite),
                              title: const Text("Nabız"),
                              subtitle: Text(
                                  pulse.isNotEmpty ? "$pulse bpm" : "Veri yok"),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 15),

          // Batarya Bilgileri Kartı
          Card(
            elevation: 4,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Batarya Durumu',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
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
                  const SizedBox(height: 10),
                  DataRowWidget(
                    title: "Telefon Şarjı",
                    value: "%$_batteryLevel",
                    status: _batteryLevel < 20
                        ? "Dikkat"
                        : _batteryLevel < 50
                            ? "Normal"
                            : "Çok iyi",
                  ),
                  DataRowWidget(
                    title: "Güç Veren Batarya",
                    value: "%${sensorData.battery1Charge}",
                    status: "İyi",
                  ),
                  DataRowWidget(
                    title: "Şarj Edilen Batarya",
                    value: "%${sensorData.battery2Charge}",
                    status: "Düşük",
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Isıtma Sistemi:",
                          style: TextStyle(fontWeight: FontWeight.w500)),
                      Switch(
                        value: sensorData.heatingEnabled,
                        onChanged: (value) => sensorData.toggleHeating(),
                        activeColor: Colors.orange,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 15),

          // Acil Durum Butonu
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(40),
                backgroundColor: Colors.red,
              ),
              onPressed: _showEmergencyDialog,
              child: const Text(
                'ACİL\nDURUM',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Provider.of<SensorDataProvider>(context); // Sadece provider'ı dinlemek için

    return Scaffold(
      body: _buildHomeTab(),
    );
  }
}
