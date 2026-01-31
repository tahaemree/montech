import 'package:flutter/material.dart';
import 'package:montech/screens/bluetooth_connect_screen.dart';
import 'package:montech/screens/bluetooth_status_screen.dart';
import 'package:montech/screens/emergency_contact_screen.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/auth_provider.dart';
import '../providers/emergency_provider.dart';
import '../providers/theme_provider.dart';
import 'login_screen.dart'; // Dönüş için

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool isDarkMode = false;
  bool notificationsEnabled = true;
  bool bluetoothEnabled = true;
  bool locationSharingEnabled = true;

  // Bölüm başlığı için özel widget
  Widget _buildSectionHeader(
      BuildContext context, String title, IconData icon, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: Theme.of(context).primaryColor,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  // Ayarlar için kart widget'ı
  Widget _buildSettingsCard({required Widget child}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }

  // Profil bilgisi için özel widget
  Widget _buildProfileTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconColor,
    required bool isDark,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: iconColor),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          color: isDark ? Colors.white70 : Colors.black87,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: isDark ? Colors.white54 : Colors.black54,
        ),
      ),
    );
  }

  void _launchPrivacyPolicy() async {
    const url =
        'https://example.com/kvkk'; // KVKK veya Gizlilik Politikası URL'iniz
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    final authProvider = Provider.of<AuthProvider>(context);
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildSectionHeader(
            context,
            "Kullanıcı Bilgileri",
            Icons.person_outline,
            themeProvider.isDarkMode,
          ),
          const SizedBox(height: 15),
          _buildSettingsCard(
            child: Column(
              children: [
                _buildProfileTile(
                  icon: Icons.person,
                  title: "Ad Soyad",
                  subtitle: "Demo Kullanıcı",
                  iconColor: Colors.blue,
                  isDark: themeProvider.isDarkMode,
                ),
                _buildProfileTile(
                  icon: Icons.account_circle,
                  title: "Kullanıcı Adı",
                  subtitle: authProvider.username,
                  iconColor: Colors.purple,
                  isDark: themeProvider.isDarkMode,
                ),
                _buildProfileTile(
                  icon: Icons.vpn_key,
                  title: "Aktivasyon Kodu",
                  subtitle: "MONT2025",
                  iconColor: Colors.orange,
                  isDark: themeProvider.isDarkMode,
                ),
                const Divider(),
                // Acil Durum Kişisi Düzenle
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                  child: Consumer<EmergencyProvider>(
                    builder: (context, emergencyProvider, _) {
                      final hasContact = emergencyProvider.hasEmergencyContact;

                      return ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        icon: Icon(
                          hasContact ? Icons.edit_note : Icons.person_add,
                          size: 22,
                        ),
                        label: Text(hasContact
                            ? "Acil Durum Kişisini Düzenle"
                            : "Acil Durum Kişisi Ekle"),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const EmergencyContactScreen(),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),

                // Bluetooth Butonları
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          icon: const Icon(Icons.bluetooth, size: 20),
                          label: const Text("Bluetooth Test"),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const BluetoothStatusScreen()),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          icon: const Icon(Icons.link, size: 20),
                          label: const Text("Bağlantı"),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const BluetoothConnectScreen()),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 25),
          _buildSectionHeader(
            context,
            "Uygulama Ayarları",
            Icons.settings,
            themeProvider.isDarkMode,
          ),
          const SizedBox(height: 15),
          _buildSettingsCard(
            child: Column(
              children: [
                ListTile(
                  title: const Text("Parola Değiştir"),
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.indigo.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.lock_outline, color: Colors.indigo),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text("Parola değiştirme henüz eklenmedi.")),
                    );
                  },
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text("Karanlık Mod"),
                  secondary: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child:
                        const Icon(Icons.dark_mode, color: Colors.deepPurple),
                  ),
                  value: themeProvider.isDarkMode,
                  onChanged: (value) {
                    themeProvider.toggleTheme();
                  },
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text("Bildirimler"),
                  secondary: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.notifications_active,
                        color: Colors.amber),
                  ),
                  value: notificationsEnabled,
                  onChanged: (val) {
                    setState(() {
                      notificationsEnabled = val;
                    });
                  },
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text("Bluetooth Eşleştirme"),
                  secondary: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.bluetooth, color: Colors.blue),
                  ),
                  value: bluetoothEnabled,
                  onChanged: (val) {
                    setState(() {
                      bluetoothEnabled = val;
                    });
                  },
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text("Konum Paylaşımı"),
                  secondary: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.location_on, color: Colors.green),
                  ),
                  value: locationSharingEnabled,
                  onChanged: (val) {
                    setState(() {
                      locationSharingEnabled = val;
                    });
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 25),
          _buildSectionHeader(
            context,
            "Diğer",
            Icons.more_horiz,
            themeProvider.isDarkMode,
          ),
          const SizedBox(height: 15),
          _buildSettingsCard(
            child: Column(
              children: [
                ListTile(
                  title: const Text("KVKK / Gizlilik Politikası"),
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.teal.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.privacy_tip, color: Colors.teal),
                  ),
                  trailing: const Icon(Icons.open_in_new, size: 16),
                  onTap: _launchPrivacyPolicy,
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text("Çıkış Yap"),
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.logout, color: Colors.red),
                  ),
                  onTap: () async {
                    final navigator = Navigator.of(context);
                    await Provider.of<AuthProvider>(context, listen: false)
                        .logout();
                    if (mounted) {
                      navigator.pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                        (route) => false,
                      );
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
