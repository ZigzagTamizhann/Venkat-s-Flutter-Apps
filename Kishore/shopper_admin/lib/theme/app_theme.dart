import 'package:flutter/material.dart';

class AppTheme {
  // iOS-inspired color palette
  static const Color primary = Color(0xFF007AFF); // iOS Blue
  static const Color secondary = Color(0xFF8E8E93); // iOS Gray
  static const Color background = Color(0xFFF2F2F7); // iOS Light Gray
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceGlass = Color(0xE6FFFFFF); // Glass effect
  static const Color error = Color(0xFFFF3B30); // iOS Red
  static const Color success = Color(0xFF34C759); // iOS Green
  static const Color warning = Color(0xFFFF9500); // iOS Orange
  static const Color purple = Color(0xFF5856D6); // iOS Purple
  static const Color teal = Color(0xFF5AC8FA); // iOS Teal
  
  static const Color textPrimary = Color(0xFF1C1C1E); // iOS Dark Gray
  static const Color textSecondary = Color(0xFF8E8E93); // iOS Light Gray
  static const Color divider = Color(0xFFC6C6C8); // iOS Separator

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primary,
      scaffoldBackgroundColor: background,
      fontFamily: '.SF Pro Display', // iOS font
      
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.light,
        primary: primary,
        secondary: secondary,
        error: error,
        surface: surfaceGlass,
      ),
      
      appBarTheme: const AppBarTheme(
        backgroundColor: surfaceGlass,
        foregroundColor: textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          fontFamily: '.SF Pro Display',
        ),
        iconTheme: IconThemeData(color: primary),
      ),
      
      cardTheme: CardThemeData(
        color: surfaceGlass,
        elevation: 0,
        shadowColor: Colors.black.withOpacity(0.03),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        clipBehavior: Clip.antiAlias,
      ),
      
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: '.SF Pro Text',
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
        labelStyle: const TextStyle(color: textSecondary, fontSize: 15),
        hintStyle: TextStyle(color: textSecondary.withOpacity(0.7), fontSize: 15),
        prefixIconColor: textSecondary,
        suffixIconColor: textSecondary,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
        titleSmall: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          fontFamily: '.SF Pro Text',
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
        labelLarge: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: primary,
          fontFamily: '.SF Pro Text',
        ),
      ),
      
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return primary;
          }
          return Colors.white;
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return primary.withOpacity(0.3);
          }
          return Colors.black.withOpacity(0.1);
        }),
      ),
      
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return primary;
          }
          return Colors.transparent;
        }),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }
}