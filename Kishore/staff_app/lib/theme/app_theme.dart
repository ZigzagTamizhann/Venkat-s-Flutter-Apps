import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTheme {
  // Modern color palette
  static const Color primary = Color(0xFF2E7D32); // Deep green
  static const Color primaryLight = Color(0xFF4CAF50); // Lighter green
  static const Color accent = Color(0xFFFF6B6B); // Coral accent
  static const Color background = Color(0xFFF8F9FA); // Light background
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceGlass = Color(0xF2FFFFFF); // Glass effect
  static const Color darkGlass = Color(0xCC2E7D32); // Dark glass for overlays
  
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textLight = Color(0xFFFFFFFF);
  
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);
  
  static const Color pendingColor = Color(0xFFFF9800);
  static const Color preparingColor = Color(0xFF2196F3);
  static const Color completedColor = Color(0xFF4CAF50);
  
  // Status colors
  static const Map<String, Color> statusColors = {
    'pending': pendingColor,
    'preparing': preparingColor,
    'prepare': preparingColor,
    'completed': completedColor,
  };

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primary,
      scaffoldBackgroundColor: background,
      fontFamily: '.SF Pro Display',
      
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.light,
        primary: primary,
        secondary: accent,
        surface: surface,
        background: background,
        error: error,
      ),
      
      appBarTheme: AppBarTheme(
        backgroundColor: surfaceGlass,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: const TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          fontFamily: '.SF Pro Display',
        ),
        iconTheme: const IconThemeData(color: primary),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shadowColor: Colors.black.withOpacity(0.05),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        clipBehavior: Clip.antiAlias,
      ),
      
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: textLight,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
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
        fillColor: surface,
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
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: error, width: 1),
        ),
        labelStyle: const TextStyle(color: textSecondary, fontSize: 15),
        hintStyle: TextStyle(color: textSecondary.withOpacity(0.7), fontSize: 15),
        prefixIconColor: textSecondary,
        suffixIconColor: textSecondary,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      ),
      
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: textPrimary,
          fontFamily: '.SF Pro Display',
        ),
        headlineMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: textPrimary,
          fontFamily: '.SF Pro Display',
        ),
        titleLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          fontFamily: '.SF Pro Display',
        ),
        titleMedium: TextStyle(
          fontSize: 18,
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
      
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: primary,
        unselectedItemColor: textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      
      tabBarTheme: const TabBarThemeData(
        labelColor: primary,
        unselectedLabelColor: textSecondary,
        indicatorColor: primary,
        labelStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          fontFamily: '.SF Pro Text',
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          fontFamily: '.SF Pro Text',
        ),
      ),
    );
  }
}