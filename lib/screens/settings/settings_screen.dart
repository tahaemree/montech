import 'package:flutter/material.dart';
import '../../widgets/custom_appbar.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // Şu anlık simüle edilen değişiklik işlemi
    await Future.delayed(const Duration(seconds: 2));

    setState(() => _isLoading = false);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Parola başarıyla değiştirildi!')),
    );

    Navigator.pop(context); // Ayarlar ekranına geri dön
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: "Parola Değiştir"),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _oldPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Eski Parola',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Gerekli alan' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _newPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Yeni Parola',
                  prefixIcon: Icon(Icons.lock),
                ),
                validator: (value) => value == null || value.length < 6
                    ? 'En az 6 karakter'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Yeni Parolayı Onayla',
                  prefixIcon: Icon(Icons.lock),
                ),
                validator: (value) => value != _newPasswordController.text
                    ? 'Parolalar eşleşmiyor'
                    : null,
              ),
              const SizedBox(height: 32),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton.icon(
                      onPressed: _changePassword,
                      icon: const Icon(Icons.save),
                      label: const Text('Parolayı Değiştir'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
