import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/bluetooth_helper.dart';
import 'providers/sensor_data_provider.dart';
import 'providers/bluetooth_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/navigation_provider.dart';
import 'providers/emergency_provider.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/bluetooth_screen.dart';
import 'screens/chart_screen.dart';
import 'screens/navigation_screen.dart';
import 'widgets/emergency_handler.dart';
import 'services/background_service.dart';
import 'package:permission_handler/permission_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Uygulama başladığında arka plan servisini başlat
  await BackgroundService.initializeService();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => SensorDataProvider()),
        ChangeNotifierProvider(create: (_) => BluetoothProvider()),
        ChangeNotifierProvider(create: (_) => BluetoothHelper()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
        ChangeNotifierProvider(create: (_) => EmergencyProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MainApp();
  }
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeLoginStatus();
    _checkPermissions();
  }

  void _initializeLoginStatus() async {
    if (!mounted) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.checkLoginStatus();

    if (!mounted) return;

    final bluetoothProvider =
        Provider.of<BluetoothProvider>(context, listen: false);
    await bluetoothProvider.initializeBluetooth();

    if (!mounted) return;

    setState(() {
      _isInitialized = true;
    });
  }

  Future<void> _checkPermissions() async {
    // Arka plan servisi için gereken izinler
    var notificationStatus = await Permission.notification.status;
    if (!notificationStatus.isGranted) {
      await Permission.notification.request();
    }

    // Pil optimizasyon izni (uygulamanın arka planda sorunsuz çalışması için)
    try {
      var ignoreBatteryStatus =
          await Permission.ignoreBatteryOptimizations.status;
      if (!ignoreBatteryStatus.isGranted) {
        await Permission.ignoreBatteryOptimizations.request();
      }
    } catch (e) {
      debugPrint("Pil optimizasyonu izni isteme hatası: $e");
    }

    // SMS izni - acil durum için kritik
    try {
      var smsStatus = await Permission.sms.status;
      if (!smsStatus.isGranted) {
        await Permission.sms.request();
      }
    } catch (e) {
      debugPrint("SMS izni isteme hatası: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return EmergencyHandler(
      child: MaterialApp(
        title: 'MonTech',
        debugShowCheckedModeBanner: false,
        theme: ThemeData.light(),
        darkTheme: ThemeData.dark(),
        themeMode: themeProvider.isDarkMode
            ? ThemeMode.dark
            : ThemeMode.light,
        home: !_isInitialized
            ? const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              )
            : authProvider.isLoggedIn
                ? NavigationScreen()
                : const LoginScreen(),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/home': (context) => const HomeScreen(),
          '/bluetooth': (context) => const BluetoothScreen(),
          '/charts': (context) => const ChartScreen(),
          '/navigation': (context) => NavigationScreen(),
        },
      ),
    );
  }
}
