import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/bluetooth_helper.dart';
import 'providers/sensor_data_provider.dart';
import 'providers/bluetooth_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/login_screen.dart';
import 'screens/navigation_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/splash_screen.dart'; // Yeni splash screen
import 'utils/app_theme.dart'; // Geliştirilmiş tema sistemi

void main() {
  WidgetsFlutterBinding.ensureInitialized(); // Flutter'ı başlatıyoruz
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => SensorDataProvider()),
        ChangeNotifierProvider(create: (_) => BluetoothProvider()),
        ChangeNotifierProvider(create: (_) => BluetoothHelper()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const MainApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const MainApp(),
    );
  }
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> with WidgetsBindingObserver {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Sistem tema değişikliklerini algılıyoruz
  @override
  void didChangePlatformBrightness() {
    if (mounted) {
      final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
      // eğer sistem temasına göre ayarlanmışsa tema, güncelliyoruz
      themeProvider.checkSystemTheme();
    }
    super.didChangePlatformBrightness();
  }

  void _onInitializationComplete() {
    if (mounted) {
      setState(() {
        _isInitialized = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'MonTech',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.getLightTheme(),
      darkTheme: AppTheme.getDarkTheme(),
      themeMode: themeProvider.themeMode,
      home: !_isInitialized
          ? SplashScreen(onInitializationComplete: _onInitializationComplete)
          : authProvider.isLoggedIn
              ? const NavigationScreen()
              : const LoginScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const NavigationScreen(),
        '/settings': (context) => const SettingsScreen(),
      },
    );
  }
}
