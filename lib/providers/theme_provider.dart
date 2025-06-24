import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = false;
  // Tema modu: system (sistem), light (açık), dark (koyu)
  String _themePreference = 'system';

  bool get isDarkMode => _isDarkMode;

  String get themePreference => _themePreference;

  // Tema modu seçimi
  ThemeMode get themeMode {
    switch (_themePreference) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }

  ThemeProvider() {
    _loadTheme();
  }

  // Sistem tema değişikliklerini kontrol et
  void checkSystemTheme() {
    if (_themePreference == 'system') {
      final isDark =
          SchedulerBinding.instance.platformDispatcher.platformBrightness ==
              Brightness.dark;
      if (_isDarkMode != isDark) {
        _isDarkMode = isDark;
        notifyListeners();
      }
    }
  }

  // Başlangıçta kayıtlı tema modunu oku
  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    _themePreference = prefs.getString('themePreference') ?? 'system';

    // Eğer tema modu 'system' ise, sistem temasını kontrol et
    if (_themePreference == 'system') {
      _isDarkMode =
          SchedulerBinding.instance.platformDispatcher.platformBrightness ==
              Brightness.dark;
    } else {
      _isDarkMode = _themePreference == 'dark';
    }

    notifyListeners();
  }

  // Kullanıcı tema tercihini ayarlar
  Future<void> setThemePreference(String preference) async {
    _themePreference = preference;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('themePreference', preference);

    if (preference == 'system') {
      _isDarkMode =
          SchedulerBinding.instance.platformDispatcher.platformBrightness ==
              Brightness.dark;
    } else {
      _isDarkMode = preference == 'dark';
    }

    notifyListeners();
  }

  // Kullanıcı temayı değiştirdiğinde kayıt et (eski yöntem - geriye dönük uyumluluk için)
  Future<void> setDarkMode(bool value) async {
    _isDarkMode = value;
    _themePreference = value ? 'dark' : 'light';
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', value);
    await prefs.setString('themePreference', _themePreference);
    notifyListeners();
  }

  // Toggle fonksiyonu da dursun (eski kodlar için)
  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    _themePreference = _isDarkMode ? 'dark' : 'light';
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
    await prefs.setString('themePreference', _themePreference);
    notifyListeners();
  }
}
