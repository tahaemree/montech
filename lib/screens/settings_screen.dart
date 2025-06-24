import 'package:flutter/material.dart';
import 'package:montech/screens/bluetooth_connect_screen.dart';
import 'package:montech/screens/bluetooth_status_screen.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/ui_components.dart';
import '../widgets/theme_screen.dart';
import 'dart:ui';
// login_screen.dart artık doğrudan import edilmiyor, route kullanılıyor

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool notificationsEnabled = true;
  bool bluetoothEnabled = true;
  bool locationSharingEnabled = true;

  void _launchPrivacyPolicy() async {
    const url =
        'https://example.com/kvkk'; // KVKK veya Gizlilik Politikası URL'iniz
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  } // Asenkron çıkış işlemi için yardımcı metod

  Future<void> _handleLogout(BuildContext context) async {
    // Dialog ile onay soralım
    final bool? confirmLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Çıkış Yap'),
        content:
            const Text('Hesabınızdan çıkış yapmak istediğinize emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Çıkış Yap', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmLogout != true) return;

    // Context'i yerel değişkene kaydederek ilk kullanım
    final navigator = Navigator.of(context);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Asenkron işlem ve güvenlik kontrolü
    await authProvider.logout();
    if (!mounted) return;

    // Navigation işlemi
    navigator.pushNamedAndRemoveUntil('/login', (route) => false);
  }

  void _showThemeSelectionBottomSheet(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Tema Seçimi',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: const Text('Sistem Teması'),
                  subtitle: const Text('Cihazınızın tema ayarlarını kullanır'),
                  leading: const Icon(Icons.auto_awesome),
                  trailing: Radio<String>(
                    value: 'system',
                    groupValue: themeProvider.themePreference,
                    onChanged: (value) {
                      setState(() {
                        themeProvider.setThemePreference(value!);
                      });
                    },
                  ),
                ),
                ListTile(
                  title: const Text('Açık Tema'),
                  subtitle: const Text('Her zaman açık temayı kullanır'),
                  leading: const Icon(Icons.light_mode),
                  trailing: Radio<String>(
                    value: 'light',
                    groupValue: themeProvider.themePreference,
                    onChanged: (value) {
                      setState(() {
                        themeProvider.setThemePreference(value!);
                      });
                    },
                  ),
                ),
                ListTile(
                  title: const Text('Koyu Tema'),
                  subtitle: const Text('Her zaman koyu temayı kullanır'),
                  leading: const Icon(Icons.dark_mode),
                  trailing: Radio<String>(
                    value: 'dark',
                    groupValue: themeProvider.themePreference,
                    onChanged: (value) {
                      setState(() {
                        themeProvider.setThemePreference(value!);
                      });
                    },
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('TAMAM'),
                  ),
                ),
              ],
            ),
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final theme = Theme.of(context);

    return ThemedScreenScaffold(
      title: "Ayarlar",
      extendBodyBehindAppBar: true,
      addTopSafeArea: true,
      bodyPadding: const EdgeInsets.symmetric(horizontal: 16),
      body: ListView(
        padding: const EdgeInsets.only(top: 16, bottom: 16),
        children: [
          // Profil kartı
          CustomCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          authProvider.username.isNotEmpty
                              ? authProvider.username
                                  .substring(0, 1)
                                  .toUpperCase()
                              : "U",
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Demo Kullanıcı",
                            style: theme.textTheme.titleLarge,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            authProvider.username,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.textTheme.bodySmall?.color,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: () {
                    // Profil düzenleme sayfasına gitme
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Profil düzenleme henüz eklenmedi."),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(40),
                  ),
                  child: const Text("Profili Düzenle"),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Bluetooth bölümü
          Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 8),
            child: Text(
              "Bluetooth",
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          CustomCard(
            child: Column(
              children: [
                ListTile(
                  title: const Text("Bluetooth Durumu"),
                  leading:
                      Icon(Icons.bluetooth, color: theme.colorScheme.primary),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      PageTransition(
                          page: BluetoothStatusScreen(),
                          type: TransitionType.rightToLeft),
                    );
                  },
                ),
                Divider(height: 1, color: Colors.grey.withOpacity(0.2)),
                ListTile(
                  title: const Text("Bluetooth Bağlantıları"),
                  leading: Icon(Icons.bluetooth_connected,
                      color: theme.colorScheme.primary),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      PageTransition(
                          page: BluetoothConnectScreen(),
                          type: TransitionType.rightToLeft),
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Uygulama ayarları bölümü
          Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 8),
            child: Text(
              "Uygulama Ayarları",
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          CustomCard(
            child: Column(
              children: [
                ListTile(
                  title: const Text("Tema Ayarları"),
                  leading:
                      Icon(Icons.palette, color: theme.colorScheme.primary),
                  trailing: Text(
                    themeProvider.themePreference == 'system'
                        ? "Sistem"
                        : themeProvider.themePreference == 'dark'
                            ? "Koyu"
                            : "Açık",
                    style: theme.textTheme.bodySmall,
                  ),
                  onTap: () {
                    _showThemeSelectionBottomSheet(context);
                  },
                ),
                Divider(height: 1, color: Colors.grey.withOpacity(0.2)),
                SwitchListTile(
                  title: const Text("Bildirimler"),
                  secondary: Icon(Icons.notifications_active,
                      color: theme.colorScheme.primary),
                  value: notificationsEnabled,
                  onChanged: (val) {
                    setState(() {
                      notificationsEnabled = val;
                    });
                  },
                ),
                Divider(height: 1, color: Colors.grey.withOpacity(0.2)),
                SwitchListTile(
                  title: const Text("Konum Paylaşımı"),
                  secondary:
                      Icon(Icons.location_on, color: theme.colorScheme.primary),
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

          const SizedBox(height: 24),

          // Güvenlik ve uygulama bölümü
          Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 8),
            child: Text(
              "Güvenlik ve Uygulama",
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          CustomCard(
            child: Column(
              children: [
                ListTile(
                  title: const Text("Parola Değiştir"),
                  leading: Icon(Icons.lock_outline,
                      color: theme.colorScheme.primary),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text("Parola değiştirme henüz eklenmedi.")),
                    );
                  },
                ),
                Divider(height: 1, color: Colors.grey.withOpacity(0.2)),
                ListTile(
                  title: const Text("KVKK / Gizlilik Politikası"),
                  leading:
                      Icon(Icons.privacy_tip, color: theme.colorScheme.primary),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: _launchPrivacyPolicy,
                ),
                Divider(height: 1, color: Colors.grey.withOpacity(0.2)),
                ListTile(
                  title: const Text("Hakkında"),
                  leading: Icon(Icons.info_outline,
                      color: theme.colorScheme.primary),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    showAboutDialog(
                      context: context,
                      applicationName: "MonTech",
                      applicationVersion: "1.0.0",
                      applicationIcon: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(
                          child: Text(
                            "M",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      children: [
                        const SizedBox(height: 16),
                        const Text(
                            "MonTech, sensör verilerini izleme ve takip etme uygulamasıdır."),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Çıkış Yap butonu
          AnimatedButton(
            primaryColor: Colors.redAccent,
            onPressed: () => _handleLogout(context),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.logout, color: Colors.white),
                SizedBox(width: 8),
                Text(
                  "ÇIKIŞ YAP",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
