import 'package:flutter/material.dart';
import 'dart:ui';
import '../utils/app_theme.dart';

/// Tüm uygulama genelinde tutarlı bir ekran yapısı sağlayan bileşen
/// Bu widget, ekranlar için standart AppBar, BodyContent ve Bottom Navigation Bar içerir
class ThemedScreenScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final bool? extendBodyBehindAppBar;
  final bool? centerTitle;
  final bool automaticallyImplyLeading;
  final Widget? leading;
  final PreferredSizeWidget? bottom;
  final EdgeInsets? bodyPadding;
  final bool addTopSafeArea;

  const ThemedScreenScaffold({
    super.key,
    required this.title,
    required this.body,
    this.actions,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.extendBodyBehindAppBar = true,
    this.centerTitle = true,
    this.automaticallyImplyLeading = true,
    this.leading,
    this.bottom,
    this.bodyPadding,
    this.addTopSafeArea = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    // AppBar arkaplan rengi
    final appBarColor = isDarkMode
        ? Color(0xFF242424).withOpacity(0.95)
        : Colors.white.withOpacity(0.95);

    return Scaffold(
      extendBodyBehindAppBar: extendBodyBehindAppBar ?? false,
      appBar: AppBar(
        title: Text(title),
        backgroundColor: appBarColor,
        elevation: 8,
        centerTitle: centerTitle,
        automaticallyImplyLeading: automaticallyImplyLeading,
        leading: leading,
        bottom: bottom,
        shadowColor:
            isDarkMode ? Colors.black.withOpacity(0.3) : AppTheme.shadowColor,
        actions: actions,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
        ),
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: Colors.transparent),
          ),
        ),
        titleTextStyle: TextStyle(
          fontWeight: FontWeight.bold,
          fontFamily: 'Poppins',
          fontSize: 20,
          color: isDarkMode ? Colors.white : primaryColor,
        ),
        iconTheme: IconThemeData(
          color: primaryColor.withOpacity(0.9),
        ),
      ),
      body: extendBodyBehindAppBar! && addTopSafeArea
          ? SafeArea(
              child: Padding(
                padding: bodyPadding ?? EdgeInsets.zero,
                child: body,
              ),
            )
          : Padding(
              padding: bodyPadding ?? EdgeInsets.zero,
              child: body,
            ),
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}

/// Özel AppBar bileşeni
class ThemedAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool? centerTitle;
  final Widget? leading;
  final PreferredSizeWidget? bottom;

  const ThemedAppBar({
    super.key,
    required this.title,
    this.actions,
    this.centerTitle = true,
    this.leading,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    // AppBar arkaplan rengi
    final appBarColor = isDarkMode
        ? Color(0xFF242424).withOpacity(0.95)
        : Colors.white.withOpacity(0.95);

    return AppBar(
      title: Text(title),
      backgroundColor: appBarColor,
      elevation: 8,
      centerTitle: centerTitle,
      leading: leading,
      bottom: bottom,
      shadowColor:
          isDarkMode ? Colors.black.withOpacity(0.3) : AppTheme.shadowColor,
      actions: actions,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      flexibleSpace: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(color: Colors.transparent),
        ),
      ),
      titleTextStyle: TextStyle(
        fontWeight: FontWeight.bold,
        fontFamily: 'Poppins',
        fontSize: 20,
        color: isDarkMode ? Colors.white : primaryColor,
      ),
      iconTheme: IconThemeData(
        color: primaryColor.withOpacity(0.9),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(bottom != null
      ? kToolbarHeight + bottom!.preferredSize.height
      : kToolbarHeight);
}

/// Özel NavigationBar bileşeni
class ThemedBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<BottomNavigationBarItem> items;

  const ThemedBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    // Navigation Bar arkaplan rengi
    final navBarColor = isDarkMode
        ? Color(0xFF242424).withOpacity(0.95)
        : Colors.white.withOpacity(0.95);

    return Container(
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
              currentIndex: currentIndex,
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
              onTap: onTap,
              items: items,
            ),
          ),
        ),
      ),
    );
  }
}
