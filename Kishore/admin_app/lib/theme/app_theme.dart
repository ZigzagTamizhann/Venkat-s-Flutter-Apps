import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary = Color(0xFF007AFF); // iOS blue
  static const Color background = Color(0xFFF5F5F7); // Light gray background
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceGlass = Color(0xE6FFFFFF); // Glass effect
  static const Color darkSurface = Color(0xFF1C1C1E);
  static const Color textPrimary = Color(0xFF1C1C1E);
  static const Color textSecondary = Color(0xFF8E8E93);
  static const Color success = Color(0xFF34C759);
  static const Color error = Color(0xFFFF3B30);
  static const Color divider = Color(0xFFC6C6C8);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: background,
    primaryColor: primary,
    fontFamily: '.SF Pro Display', // iOS font
    
    appBarTheme: const AppBarTheme(
      elevation: 0,
      backgroundColor: surfaceGlass,
      foregroundColor: textPrimary,
      titleTextStyle: TextStyle(
        color: textPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        fontFamily: '.SF Pro Display',
      ),
      iconTheme: IconThemeData(color: primary),
    ),
    
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      clipBehavior: Clip.antiAlias,
      color: surfaceGlass,
    ),
    
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          fontFamily: '.SF Pro Display',
        ),
      ),
    ),
    
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceGlass,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primary, width: 1),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: error, width: 1),
      ),
      labelStyle: const TextStyle(color: textSecondary),
      hintStyle: const TextStyle(color: textSecondary),
      prefixIconColor: textSecondary,
      suffixIconColor: textSecondary,
    ),
    
    textTheme: const TextTheme(
      titleLarge: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: textPrimary,
        fontFamily: '.SF Pro Display',
      ),
      titleMedium: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        fontFamily: '.SF Pro Display',
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        color: textPrimary,
        fontFamily: '.SF Pro Text',
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: textSecondary,
        fontFamily: '.SF Pro Text',
      ),
    ),
  );
}