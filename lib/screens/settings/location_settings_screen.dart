import 'package:flutter/material.dart';
import '../../widgets/custom_appbar.dart';

class LocationSettingsScreen extends StatefulWidget {
  const LocationSettingsScreen({super.key});

  @override
  State<LocationSettingsScreen> createState() => _LocationSettingsScreenState();
}

class _LocationSettingsScreenState extends State<LocationSettingsScreen> {
  bool _locationSharingEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "Konum Ayarları",
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Icon(Icons.location_on, size: 60, color: Colors.orange),
            const SizedBox(height: 20),
            const Text(
              "Konum Paylaşımı",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              "Konum bilgilerinizi sistemle paylaşmak, acil durum anlarında daha hızlı müdahale edilmesini sağlar.",
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            SwitchListTile(
              title: const Text("Konum paylaşımını aktif et"),
              value: _locationSharingEnabled,
              onChanged: (value) {
                setState(() {
                  _locationSharingEnabled = value;
                });
              },
              activeColor: Colors.orange,
            ),
          ],
        ),
      ),
    );
  }
}
