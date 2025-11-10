import 'package:flutter/material.dart';

class LoveTheme {
  // Aşk temalı renkler - pembe, kırmızı, mor tonları
  static const Color primaryPink = Color(0xFFFF69B4); // Hot Pink
  static const Color lightPink = Color(0xFFFFB6C1); // Light Pink
  static const Color deepPink = Color(0xFFFF1493); // Deep Pink
  static const Color rose = Color(0xFFFFE4E1); // Misty Rose
  static const Color lavender = Color(0xFFE6E6FA); // Lavender
  static const Color lightRose = Color(0xFFFFF0F5); // Lavender Blush
  static const Color gold = Color(0xFFFFD700); // Gold
  static const Color darkPink = Color(0xFFC71585); // Medium Violet Red

  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryPink,
        primary: primaryPink,
        secondary: deepPink,
        tertiary: lavender,
        surface: lightRose,
        background: Colors.white,
        error: Colors.red.shade300,
      ),
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryPink,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        color: rose,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryPink,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: 5,
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: darkPink,
        ),
        displayMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: darkPink,
        ),
        headlineLarge: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: darkPink,
        ),
        headlineMedium: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: darkPink,
        ),
        bodyLarge: TextStyle(
          fontSize: 18,
          color: Colors.black87,
        ),
        bodyMedium: TextStyle(
          fontSize: 16,
          color: Colors.black87,
        ),
      ),
    );
  }

  // Gradient'ler
  static const LinearGradient pinkGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryPink, deepPink, darkPink],
  );

  static const LinearGradient lightPinkGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [lightRose, rose, lightPink],
  );

  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [gold, Color(0xFFFFA500)],
  );
}

