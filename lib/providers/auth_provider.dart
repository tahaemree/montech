import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoggedIn = false;
  String _username = '';
  String _activationCode = '';
  bool get isLoggedIn => _isLoggedIn;
  String get username => _username;
  String get activationCode => _activationCode;

  // Uygulamayı açtığında kullanıcı oturum bilgisini kontrol et
  Future<void> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    _username = prefs.getString('username') ?? '';
    _activationCode = prefs.getString('activationCode') ?? '';
    notifyListeners();
  }

  // Giriş yap
  Future<bool> login(
      String username, String password, String activationCode) async {
    // Gerçek uygulamada API'ye istek yapılacak
    // Şimdilik basit bir doğrulama
    if (password.isNotEmpty && activationCode.isNotEmpty) {
      _isLoggedIn = true;
      _username = username;
      _activationCode = activationCode;

      // Bilgileri kaydet
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('username', username);
      await prefs.setString('activationCode', activationCode);

      notifyListeners();
      return true;
    }
    return false;
  }

  // Çıkış yap
  Future<void> logout() async {
    _isLoggedIn = false;
    _username = '';
    _activationCode = '';

    // Bilgileri temizle
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    notifyListeners();
  }
}
