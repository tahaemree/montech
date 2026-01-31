import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/navigation_provider.dart';
import '../providers/bluetooth_provider.dart';
import '../providers/emergency_provider.dart';
import '../widgets/custom_appbar.dart';
import 'bluetooth_screen.dart';
import 'home_screen.dart';
import 'map_screen.dart';
import 'chart_screen.dart';
import 'settings_screen.dart';
import 'emergency_contact_screen.dart';

// NavigationScreen için globalKey tanımlıyoruz - public olarak erişebilmek için
// Not: State tipini dynamic olarak tanımladık, böylece private tip uyarısı almayacağız
final GlobalKey<dynamic> navigationScreenKey = GlobalKey();

class NavigationScreen extends StatefulWidget {
  NavigationScreen({Key? key}) : super(key: navigationScreenKey);

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  bool _hasCheckedEmergencyContact = false;

  final List<Widget> _screens = [
    const HomeScreen(),
    const MapScreen(),
    const BluetoothScreen(),
    const ChartScreen(),
    const SettingsScreen(),
  ];

  final List<String> _titles = [
    "Ana Sayfa",
    "Harita",
    "Bluetooth",
    "Grafikler",
    "Ayarlar"
  ];

  @override
  void initState() {
    super.initState();

    // İlk yüklendikten biraz sonra acil durum kişisi kontrolü yap
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkEmergencyContact();
    });
  }

  // Acil durum kişisi kontrolü
  void _checkEmergencyContact() async {
    if (_hasCheckedEmergencyContact) return;
    _hasCheckedEmergencyContact = true;

    // Provider yüklenene kadar bekle
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (!mounted) return;
    
    final emergencyProvider = Provider.of<EmergencyProvider>(context, listen: false);
    
    // Provider yüklenirken bekle
    if (emergencyProvider.isLoading) {
      await Future.delayed(const Duration(milliseconds: 500));
    }
    
    if (!mounted) return;
    
    // Acil durum kişisi yoksa dialog göster
    if (!emergencyProvider.hasEmergencyContact) {
      _showEmergencyContactSetupDialog();
    }
  }

  // Acil durum kişisi ekleme dialog'u
  void _showEmergencyContactSetupDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // Kapatılamaz
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
              child: const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Acil Durum Kişisi Gerekli!',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Güvenliğiniz için bir acil durum kişisi eklemeniz gerekmektedir.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.orange, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Mont acil durum sinyali gönderdiğinde, bu kişiye otomatik SMS gönderilecektir.',
                      style: TextStyle(fontSize: 12, color: Colors.orange),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: const Icon(Icons.person_add),
              label: const Text('Şimdi Ekle', style: TextStyle(fontWeight: FontWeight.bold)),
              onPressed: () {
                Navigator.pop(dialogContext);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const EmergencyContactScreen()),
                ).then((_) {
                  // Geri döndüğünde tekrar kontrol et
                  if (mounted) {
                    final provider = Provider.of<EmergencyProvider>(context, listen: false);
                    if (!provider.hasEmergencyContact) {
                      // Hala eklenmemişse tekrar göster
                      Future.delayed(const Duration(milliseconds: 300), () {
                        if (mounted) _showEmergencyContactSetupDialog();
                      });
                    }
                  }
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  // Function to switch tab from outside (for backward compatibility with GlobalKey)
  void switchTab(int index) {
    final navigationProvider =
        Provider.of<NavigationProvider>(context, listen: false);
    navigationProvider.changeTab(index);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NavigationProvider>(
        builder: (context, navigationProvider, _) {
      return Scaffold(
        appBar: CustomAppBar(
          title: _titles[navigationProvider.currentIndex],
          // Grafik sekmesinde olduğunda rengi değiştir
          backgroundColor:
              navigationProvider.currentIndex == 3 ? Colors.blue : null,
          // Bluetooth sekmesi için refresh butonu ekle
          actions: [
            if (navigationProvider.currentIndex == 2) // Bluetooth sekmesi
              Row(
                children: [
                  // Scanning indicator
                  Consumer<BluetoothProvider>(
                    builder: (context, bluetoothProvider, _) {
                      if (bluetoothProvider.isScanning) {
                        return Container(
                          margin: const EdgeInsets.only(right: 8.0),
                          width: 20,
                          height: 20,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                  // Refresh button
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    tooltip: 'Bluetooth cihazlarını yeniden tara',
                    onPressed: () {
                      final bluetoothProvider = Provider.of<BluetoothProvider>(
                          context,
                          listen: false);
                      if (!bluetoothProvider.isScanning) {
                        bluetoothProvider.startScan();
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Cihazlar taranıyor...')));
                      }
                    },
                  ),
                ],
              ),
          ],
        ),
        body: _screens[navigationProvider.currentIndex],
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(
                    26), // 0.1 opaklık değeri yaklaşık 26 alpha değerine eşit
                blurRadius: 8,
                offset: const Offset(0, -3),
              ),
            ],
          ),
          child: BottomNavigationBar(
            currentIndex: navigationProvider.currentIndex,
            selectedItemColor: navigationProvider.currentIndex == 3
                ? Colors.blue
                : Colors.orangeAccent,
            unselectedItemColor: Colors.grey,
            type: BottomNavigationBarType.fixed,
            elevation: 16,
            iconSize: 26,
            selectedFontSize: 14,
            unselectedFontSize: 12,
            onTap: (index) {
              navigationProvider.changeTab(index);
            },
            items: [
              const BottomNavigationBarItem(
                  icon: Icon(Icons.home), label: "Ana Sayfa"),
              const BottomNavigationBarItem(
                  icon: Icon(Icons.map), label: "Harita"),
              const BottomNavigationBarItem(
                  icon: Icon(Icons.bluetooth), label: "Bluetooth"),
              // Grafik sekmesi daha belirgin
              BottomNavigationBarItem(
                icon: const Icon(Icons.bar_chart),
                label: "Grafikler",
                // Animasyonlu tooltip ekleyelim
                tooltip: "Sensör verisi grafiklerini görüntüle",
              ),
              const BottomNavigationBarItem(
                  icon: Icon(Icons.settings), label: "Ayarlar"),
            ],
          ),
        ),
      );
    });
  }
}
