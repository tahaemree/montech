import 'package:flutter/material.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  bool _pushNotificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Bildirim Ayarları"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Push Bildirimleri",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Bildirimleri Aç/Kapat"),
                Switch(
                  value: _pushNotificationsEnabled,
                  onChanged: (value) {
                    setState(() {
                      _pushNotificationsEnabled = value;
                    });
                    // Burada tercihi kaydetme işlemleri yapılabilir
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          value ? "Bildirimler açıldı" : "Bildirimler kapatıldı",
                        ),
                      ),
                    );
                  },
                  activeColor: Colors.orange,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
