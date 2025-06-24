import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/bluetooth_provider.dart';

class SplashScreen extends StatefulWidget {
  final Function onInitializationComplete;

  const SplashScreen({super.key, required this.onInitializationComplete});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 0.8, curve: Curves.easeOutBack),
      ),
    );

    _controller.forward();

    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // First check login status
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.checkLoginStatus();

      // mounted kontrolü - async işlem sonrası
      if (!mounted) return;

      // Then initialize Bluetooth with proper error handling
      final bluetoothProvider =
          Provider.of<BluetoothProvider>(context, listen: false);

      try {
        await bluetoothProvider.initializeBluetooth(); // Initialize Bluetooth
      } catch (e) {
        // If Bluetooth initialization fails, log the error but continue
        debugPrint("Bluetooth initialization error: $e");
        // We don't want app startup to fail just because of Bluetooth issues
      }
    } catch (e) {
      debugPrint("Initialization error: $e");
    } finally {
      // Animasyon tamamlansın diye biraz bekletelim
      await Future.delayed(const Duration(milliseconds: 800));

      // Always set initialization as complete, even if there are errors
      // This ensures the app doesn't get stuck on splash screen
      if (mounted) {
        widget.onInitializationComplete();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primary.withOpacity(0.8),
              Theme.of(context).colorScheme.primary,
            ],
          ),
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: size.width * 0.4,
                        height: size.width * 0.4,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            "MonTech",
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      SizedBox(
                        width: 40,
                        height: 40,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white.withOpacity(0.9),
                          ),
                          strokeWidth: 3,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        "Yükleniyor...",
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
