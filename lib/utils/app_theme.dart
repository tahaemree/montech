import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Uygulama genelinde kullanılan tema, renk ve stil yardımcıları
class AppTheme {
  // Ana renk paletimiz
  static const Color primaryColor = Color(0xFF0F7C67); // Zümrüt Yeşili
  static const Color secondaryColor = Color(0xFF159676); // İkincil yeşil
  static const Color accentColor = Color(0xFF1AA687); // Vurgu yeşili
  static const Color backgroundColor = Color(0xFFF9FAFB); // Arka plan
  static const Color errorColor = Color(0xFFE53935); // Hata rengi
  static const Color warningColor = Color(0xFFFFC107); // Uyarı rengi
  static const Color successColor = Color(0xFF4CAF50); // Başarı rengi
  static const Color darkBackgroundColor = Color(0xFF1F1F1F); // Koyu arka plan

  // Metin renkleri
  static const Color textDark = Color(0xFF303030);
  static const Color textLight = Colors.white;
  static const Color textGrey = Color(0xFF757575);
  static const Color textLightGrey = Color(0xFFBDBDBD);

  // Gölge rengi
  static Color shadowColor = Colors.black.withOpacity(0.1);

  // Gradyan renkleri
  static List<Color> primaryGradient = [
    primaryColor,
    secondaryColor,
  ];

  static List<Color> accentGradient = [
    accentColor,
    accentColor.withBlue(accentColor.blue + 30),
  ];

  // Tutarlı boşluk değerleri
  static const double spacingXSmall = 4.0;
  static const double spacingSmall = 8.0;
  static const double spacingMedium = 16.0;
  static const double spacingLarge = 24.0;
  static const double spacingXLarge = 32.0;
  static const double spacingXXLarge = 48.0;

  // Yuvarlak köşe değerleri
  static const double radiusSmall = 4.0;
  static const double radiusMedium = 8.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 24.0;
  static const double radiusCircular = 50.0;

  // Sabit boyut değerleri
  static const double buttonHeight = 56.0;
  static const double appBarHeight = 60.0;
  static const double bottomBarHeight = 70.0;
  static const double cardElevation = 4.0;

  // Yüksek kaliteli görsel kaymalar için custom curve
  static const Curve animationCurve = Curves.easeInOutCubic;
  static const Duration animationDuration = Duration(milliseconds: 300);

  // Açık tema oluşturma
  static ThemeData getLightTheme() {
    return ThemeData.light().copyWith(
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      colorScheme: ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: Colors.white,
        error: errorColor,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textDark,
        onError: Colors.white,
        surfaceTint: const Color(0xFFE1F8F5), // Çok açık yeşil tint
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: textDark,
        elevation: 2,
        shadowColor: shadowColor,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.dark.copyWith(
          statusBarColor: Colors.transparent,
        ),
        titleTextStyle: const TextStyle(
          color: primaryColor,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          fontFamily: 'Poppins',
        ),
        iconTheme: const IconThemeData(color: primaryColor),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: primaryColor,
        unselectedItemColor: textGrey,
        elevation: 12,
        type: BottomNavigationBarType.fixed,
        selectedIconTheme: IconThemeData(size: 28, color: primaryColor),
        unselectedIconTheme: IconThemeData(size: 24, color: textGrey),
        selectedLabelStyle: TextStyle(
            fontWeight: FontWeight.w600, fontSize: 12, fontFamily: 'Poppins'),
        unselectedLabelStyle: TextStyle(fontSize: 11, fontFamily: 'Poppins'),
      ),
      cardTheme: ThemeData.light().cardTheme.copyWith(
            color: Colors.white,
            elevation: cardElevation,
            shadowColor: shadowColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radiusLarge),
            ),
            clipBehavior: Clip.antiAlias,
          ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 4,
          shadowColor: primaryColor.withOpacity(0.4),
          minimumSize: const Size.fromHeight(buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusLarge),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: spacingLarge,
            vertical: spacingMedium,
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
            fontSize: 16,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: const BorderSide(color: primaryColor, width: 2),
          minimumSize: const Size.fromHeight(buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusLarge),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: spacingLarge,
            vertical: spacingMedium,
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.all(spacingMedium),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusLarge),
          borderSide: const BorderSide(color: textLightGrey, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusLarge),
          borderSide: const BorderSide(color: textLightGrey, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusLarge),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusLarge),
          borderSide: const BorderSide(color: errorColor, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusLarge),
          borderSide: const BorderSide(color: errorColor, width: 2),
        ),
        hintStyle: TextStyle(color: textGrey.withOpacity(0.7)),
        labelStyle: const TextStyle(color: textGrey),
        errorStyle: const TextStyle(color: errorColor, fontSize: 12),
        prefixIconColor: textGrey,
        suffixIconColor: textGrey,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: textDark,
          fontFamily: 'Poppins',
        ),
        displayMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: textDark,
          fontFamily: 'Poppins',
        ),
        displaySmall: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: textDark,
          fontFamily: 'Poppins',
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textDark,
          fontFamily: 'Poppins',
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: textDark,
          fontFamily: 'Poppins',
        ),
        titleSmall: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: textDark,
          fontFamily: 'Poppins',
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: textDark,
          fontFamily: 'Poppins',
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: textDark,
          fontFamily: 'Poppins',
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          color: textGrey,
          fontFamily: 'Poppins',
        ),
      ),
      dividerTheme: DividerThemeData(
        color: textLightGrey.withOpacity(0.5),
        thickness: 1,
        space: spacingMedium,
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryColor;
          }
          return Colors.transparent;
        }),
        side: BorderSide(width: 2, color: textGrey.withOpacity(0.5)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusSmall),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryColor;
          }
          return Colors.grey.shade400;
        }),
        trackColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryColor.withOpacity(0.3);
          }
          return Colors.grey.shade300;
        }),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryColor;
          }
          return textGrey;
        }),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: textDark,
        contentTextStyle: const TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Koyu tema oluşturma
  static ThemeData getDarkTheme() {
    return ThemeData.dark().copyWith(
      primaryColor: accentColor,
      scaffoldBackgroundColor: darkBackgroundColor,
      colorScheme: ColorScheme.dark(
        primary: accentColor,
        secondary: secondaryColor,
        surface: const Color(0xFF2C2C2C),
        error: errorColor,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textLight,
        onError: Colors.white,
        surfaceTint: const Color(0xFF0A5C4A), // Koyu yeşil tint
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFF242424),
        foregroundColor: textLight,
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.3),
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.light.copyWith(
          statusBarColor: Colors.transparent,
        ),
        titleTextStyle: const TextStyle(
          color: textLight,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          fontFamily: 'Poppins',
        ),
        iconTheme: const IconThemeData(color: Colors.white70),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF242424),
        selectedItemColor: accentColor,
        unselectedItemColor: Colors.grey,
        elevation: 12,
        type: BottomNavigationBarType.fixed,
        selectedIconTheme: IconThemeData(size: 28, color: accentColor),
        unselectedIconTheme: IconThemeData(size: 24, color: Colors.grey),
        selectedLabelStyle: TextStyle(
            fontWeight: FontWeight.w600, fontSize: 12, fontFamily: 'Poppins'),
        unselectedLabelStyle: TextStyle(fontSize: 11, fontFamily: 'Poppins'),
      ),
      cardTheme: ThemeData.dark().cardTheme.copyWith(
            color: const Color(0xFF2C2C2C),
            elevation: cardElevation,
            shadowColor: Colors.black.withOpacity(0.4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radiusLarge),
            ),
            clipBehavior: Clip.antiAlias,
          ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentColor,
          foregroundColor: Colors.white,
          elevation: 4,
          shadowColor: Colors.black.withOpacity(0.4),
          minimumSize: const Size.fromHeight(buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusLarge),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: spacingLarge,
            vertical: spacingMedium,
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: accentColor,
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
            fontSize: 16,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: accentColor,
          side: const BorderSide(color: accentColor, width: 2),
          minimumSize: const Size.fromHeight(buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusLarge),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: spacingLarge,
            vertical: spacingMedium,
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF2C2C2C),
        contentPadding: const EdgeInsets.all(spacingMedium),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusLarge),
          borderSide: const BorderSide(color: Color(0xFF555555), width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusLarge),
          borderSide: const BorderSide(color: Color(0xFF555555), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusLarge),
          borderSide: const BorderSide(color: accentColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusLarge),
          borderSide: const BorderSide(color: errorColor, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusLarge),
          borderSide: const BorderSide(color: errorColor, width: 2),
        ),
        hintStyle: const TextStyle(color: Color(0xFF999999)),
        labelStyle: const TextStyle(color: Color(0xFFBBBBBB)),
        errorStyle: const TextStyle(color: errorColor, fontSize: 12),
        prefixIconColor: const Color(0xFFBBBBBB),
        suffixIconColor: const Color(0xFFBBBBBB),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: textLight,
          fontFamily: 'Poppins',
        ),
        displayMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: textLight,
          fontFamily: 'Poppins',
        ),
        displaySmall: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: textLight,
          fontFamily: 'Poppins',
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textLight,
          fontFamily: 'Poppins',
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: textLight,
          fontFamily: 'Poppins',
        ),
        titleSmall: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: textLight,
          fontFamily: 'Poppins',
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: textLight,
          fontFamily: 'Poppins',
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: textLight,
          fontFamily: 'Poppins',
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          color: Color(0xFFBBBBBB),
          fontFamily: 'Poppins',
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFF555555),
        thickness: 1,
        space: spacingMedium,
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.selected)) {
            return accentColor;
          }
          return Colors.transparent;
        }),
        side: const BorderSide(width: 2, color: Color(0xFF888888)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusSmall),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.selected)) {
            return accentColor;
          }
          return Colors.grey.shade400;
        }),
        trackColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.selected)) {
            return accentColor.withOpacity(0.3);
          }
          return Colors.grey.shade700;
        }),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.selected)) {
            return accentColor;
          }
          return Colors.grey.shade400;
        }),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: const Color(0xFF333333),
        contentTextStyle: const TextStyle(color: textLight),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
