import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'map_screen.dart';
import 'bluetooth_screen.dart';
import 'dart:ui';
import '../utils/app_theme.dart'; // Tema sabitlerini içe aktarıyoruz

class NavigationScreen extends StatefulWidget {
  const NavigationScreen({super.key});

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _fabAnimationController;

  @override
  void initState() {
    super.initState();
    _fabAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    super.dispose();
  }

  final List<Widget> _screens = [
    const HomeScreen(),
    const MapScreen(),
    const BluetoothScreen(),
  ];

  final List<String> _titles = ["MonTech", "Konum", "Bluetooth"];

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    // AppBar arkaplan rengi
    final appBarColor = isDarkMode
        ? Color(0xFF242424).withOpacity(0.95)
        : Colors.white.withOpacity(0.95);

    // Navigation Bar arkaplan rengi
    final navBarColor = isDarkMode
        ? Color(0xFF242424).withOpacity(0.95)
        : Colors.white.withOpacity(0.95);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 8,
        backgroundColor: appBarColor,
        shadowColor:
            isDarkMode ? Colors.black.withOpacity(0.3) : AppTheme.shadowColor,
        centerTitle: true,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: Colors.transparent),
          ),
        ),
        title: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(opacity: animation, child: child);
          },
          child: Text(
            _titles[_currentIndex],
            key: ValueKey<String>(_titles[_currentIndex]),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
              fontSize: 20,
              color: isDarkMode ? Colors.white : primaryColor,
            ),
          ),
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            color: primaryColor.withOpacity(0.9),
            tooltip: 'Bildirimler',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Bildirimler açılacak'),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            color: primaryColor.withOpacity(0.9),
            tooltip: 'Ayarlar',
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: isDarkMode
                  ? Colors.black.withOpacity(0.3)
                  : AppTheme.shadowColor,
              blurRadius: 15,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(
              decoration: BoxDecoration(
                color: navBarColor,
              ),
              child: BottomNavigationBar(
                elevation: 0,
                backgroundColor: Colors.transparent,
                currentIndex: _currentIndex,
                selectedItemColor: primaryColor,
                unselectedItemColor:
                    isDarkMode ? Colors.grey[400] : Colors.grey[600],
                selectedLabelStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                    fontSize: 12),
                unselectedLabelStyle:
                    const TextStyle(fontFamily: 'Poppins', fontSize: 11),
                type: BottomNavigationBarType.fixed,
                landscapeLayout: BottomNavigationBarLandscapeLayout.centered,
                onTap: (index) {
                  setState(() => _currentIndex = index);
                  _fabAnimationController.forward(from: 0.0);
                },
                items: [
                  BottomNavigationBarItem(
                    icon: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: EdgeInsets.all(_currentIndex == 0 ? 8.0 : 5.0),
                      decoration: BoxDecoration(
                        color: _currentIndex == 0
                            ? primaryColor.withOpacity(0.2)
                            : Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                          _currentIndex == 0 ? Icons.home : Icons.home_outlined,
                          size: _currentIndex == 0 ? 28 : 24),
                    ),
                    label: "Ana Sayfa",
                  ),
                  BottomNavigationBarItem(
                    icon: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: EdgeInsets.all(_currentIndex == 1 ? 8.0 : 5.0),
                      decoration: BoxDecoration(
                        color: _currentIndex == 1
                            ? primaryColor.withOpacity(0.2)
                            : Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                          _currentIndex == 1 ? Icons.map : Icons.map_outlined,
                          size: _currentIndex == 1 ? 28 : 24),
                    ),
                    label: "Harita",
                  ),
                  BottomNavigationBarItem(
                    icon: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: EdgeInsets.all(_currentIndex == 2 ? 8.0 : 5.0),
                      decoration: BoxDecoration(
                        color: _currentIndex == 2
                            ? primaryColor.withOpacity(0.2)
                            : Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                          _currentIndex == 2
                              ? Icons.bluetooth_connected
                              : Icons.bluetooth,
                          size: _currentIndex == 2 ? 28 : 24),
                    ),
                    label: "Bluetooth",
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
