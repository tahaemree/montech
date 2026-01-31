import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../widgets/custom_appbar.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  final String _kvkkUrl =
      "https://www.example.com/kvkk"; // Gerçek URL ile değiştir

  Future<void> _launchPrivacyPolicy() async {
    if (!await launchUrl(Uri.parse(_kvkkUrl))) {
      throw Exception("KVKK bağlantısı açılamadı.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: "Gizlilik Politikası",
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.privacy_tip, size: 60, color: Colors.deepPurple),
            const SizedBox(height: 20),
            const Text(
              "Kişisel Verilerin Korunması",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            const Text(
              "Uygulama, kullanıcıların kişisel verilerini KVKK (Kişisel Verilerin Korunması Kanunu) kapsamında işlemektedir. "
              "Verileriniz yalnızca sistemin çalışmasını sağlamak amacıyla kullanılır.",
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: _launchPrivacyPolicy,
              icon: const Icon(Icons.link),
              label: const Text("KVKK ve Gizlilik Politikasını Görüntüle"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
