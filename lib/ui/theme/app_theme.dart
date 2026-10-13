import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary = Color(0xFFFF4B26); // Gourmet Coral / Sunset Orange
  static const Color primaryDark = Color(0xFFD63410);
  static const Color primaryLight = Color(0xFFFFECE8);
  static const Color secondary = Color(0xFFFFB300); // Warm Golden Amber
  static const Color success = Color(0xFF10B981); // Emerald Green
  static const Color error = Color(0xFFEF4444);

  // Light Mode Colors
  static const Color lightBg = Color(0xFFF7F8FA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightTextPrimary = Color(0xFF111827);
  static const Color lightTextSecondary = Color(0xFF6B7280);
  static const Color lightBorder = Color(0xFFE5E7EB);

  // Dark Mode Colors
  static const Color darkBg = Color(0xFF0F1115);
  static const Color darkSurface = Color(0xFF181B20);
  static const Color darkCard = Color(0xFF20242B);
  static const Color darkTextPrimary = Color(0xFFF9FAFB);
  static const Color darkTextSecondary = Color(0xFF9CA3AF);
  static const Color darkBorder = Color(0xFF2C323C);

  static TextTheme _buildTextTheme({required Color textColor, required Color secondaryColor}) {
    const fontFallbacks = <String>[
      'Plus Jakarta Sans',
      'Inter',
      'Roboto',
      '-apple-system',
      'BlinkMacSystemFont',
      'Segoe UI',
      'sans-serif',
    ];

    return TextTheme(
      displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: textColor, letterSpacing: -0.5, fontFamilyFallback: fontFallbacks),
      displayMedium: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: textColor, letterSpacing: -0.5, fontFamilyFallback: fontFallbacks),
      displaySmall: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: textColor, fontFamilyFallback: fontFallbacks),
      headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: textColor, fontFamilyFallback: fontFallbacks),
      titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: textColor, fontFamilyFallback: fontFallbacks),
      titleMedium: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: textColor, fontFamilyFallback: fontFallbacks),
      titleSmall: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textColor, fontFamilyFallback: fontFallbacks),
      bodyLarge: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w500, color: textColor, height: 1.4, fontFamilyFallback: fontFallbacks),
      bodyMedium: TextStyle(fontSize: 13, fontWeight: FontWeight.normal, color: textColor, height: 1.4, fontFamilyFallback: fontFallbacks),
      bodySmall: TextStyle(fontSize: 11.5, fontWeight: FontWeight.normal, color: secondaryColor, fontFamilyFallback: fontFallbacks),
      labelLarge: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, fontFamilyFallback: fontFallbacks),
      labelSmall: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: secondaryColor, letterSpacing: 0.4, fontFamilyFallback: fontFallbacks),
    );
  }

  static ThemeData lightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primary,
      scaffoldBackgroundColor: lightBg,
      colorScheme: const ColorScheme.light(
        primary: primary,
        secondary: secondary,
        surface: lightSurface,
        error: error,
        onPrimary: Colors.white,
        onSecondary: Colors.black,
        onSurface: lightTextPrimary,
      ),
      textTheme: _buildTextTheme(
        textColor: lightTextPrimary,
        secondaryColor: lightTextSecondary,
      ),
      cardTheme: CardThemeData(
        color: lightCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: lightBorder, width: 1),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: lightSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: lightTextPrimary),
        titleTextStyle: TextStyle(
          color: lightTextPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 2,
          shadowColor: primary.withAlpha(80),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: const BorderSide(color: primary, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF3F4F6),
        hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.transparent),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
      ),
    );
  }

  static ThemeData darkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: primary,
      scaffoldBackgroundColor: darkBg,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: secondary,
        surface: darkSurface,
        error: error,
        onPrimary: Colors.white,
        onSecondary: Colors.black,
        onSurface: darkTextPrimary,
      ),
      textTheme: _buildTextTheme(
        textColor: darkTextPrimary,
        secondaryColor: darkTextSecondary,
      ),
      cardTheme: CardThemeData(
        color: darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: darkBorder, width: 1),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: darkSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: darkTextPrimary),
        titleTextStyle: TextStyle(
          color: darkTextPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: const BorderSide(color: primary, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1A1E24),
        hintStyle: const TextStyle(color: Color(0xFF6B7280), fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
      ),
    );
  }
}
