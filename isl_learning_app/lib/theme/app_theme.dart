// lib/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppColors {
  // 🌈 Primary Palette — Juicy, saturated, children-joy colors
  static const sky      = Color(0xFF5BB8FF);
  static const mint     = Color(0xFF4ECBA0);
  static const sunshine = Color(0xFFFFD93D);
  static const coral    = Color(0xFFFF6B6B);
  static const grape    = Color(0xFFA855F7);
  static const peach    = Color(0xFFFF9F7F);
  static const lemon    = Color(0xFFFFF176);
  static const rose     = Color(0xFFFF7BAC);
  static const ocean    = Color(0xFF4A90E2);
  static const grass    = Color(0xFF5ECC7B);

  // 🎨 Card Gradients
  static const gradAlphabet = [Color(0xFF5ECC7B), Color(0xFF2DB87A)];
  static const gradNumbers  = [Color(0xFFFF9F7F), Color(0xFFFF6B6B)];
  static const gradWords    = [Color(0xFF5BB8FF), Color(0xFF4A90E2)];
  static const gradGames    = [Color(0xFFA855F7), Color(0xFF7C3AED)];
  static const gradStories  = [Color(0xFFFFD93D), Color(0xFFFFA500)];
  static const gradQuests   = [Color(0xFFFF7BAC), Color(0xFFE91E8C)];
  static const gradProgress = [Color(0xFF4ECBA0), Color(0xFF2DB87A)];
  static const gradSettings = [Color(0xFF94A3B8), Color(0xFF64748B)];

  // 🏠 Backgrounds
  static const bgMain  = Color(0xFFF0F9FF);
  static const bgCard  = Color(0xFFFFFFFF);
  static const bgSoft  = Color(0xFFF8FAFF);

  // 📝 Text
  static const textDark   = Color(0xFF1E3A5F);
  static const textMid    = Color(0xFF4A6785);
  static const textLight  = Color(0xFF8FAEC6);
  static const textWhite  = Color(0xFFFFFFFF);

  // ✅ Status
  static const success = Color(0xFF4ECBA0);
  static const warning = Color(0xFFFFD93D);
  static const error   = Color(0xFFFF6B6B);
  static const info    = Color(0xFF5BB8FF);
}

class AppTheme {
  // Compatibility aliases (keep existing code working)
  static const Color primaryBlue    = AppColors.sky;
  static const Color primaryGreen   = AppColors.mint;
  static const Color primaryPurple  = AppColors.grape;
  static const Color primaryOrange  = AppColors.peach;
  static const Color primaryPink    = AppColors.rose;
  static const Color primaryTeal    = AppColors.sky;
  static const Color primaryRed     = AppColors.coral;
  static const Color primaryCoral   = AppColors.coral;
  static const Color primaryYellow  = AppColors.sunshine;
  static const Color rainbowRed     = AppColors.coral;
  static const Color rainbowOrange  = AppColors.peach;
  static const Color rainbowYellow  = AppColors.sunshine;
  static const Color rainbowGreen   = AppColors.grass;
  static const Color rainbowBlue    = AppColors.sky;
  static const Color rainbowPurple  = AppColors.grape;
  static const Color rainbowPink    = AppColors.rose;
  static const Color backgroundLight = AppColors.bgMain;
  static const Color backgroundCard  = AppColors.bgCard;
  static const Color backgroundGradientStart = Color(0xFFF0F9FF);
  static const Color backgroundGradientEnd   = Color(0xFFF8F0FF);
  static const Color textPrimary    = AppColors.textDark;
  static const Color textSecondary  = AppColors.textMid;
  static const Color textLight      = AppColors.textLight;
  static const Color textWhite      = AppColors.textWhite;
  static const Color accentYellow   = AppColors.lemon;
  static const Color accentGold     = AppColors.sunshine;
  static const Color accentMint     = AppColors.mint;
  static const Color successGreen   = AppColors.success;
  static const Color warningOrange  = AppColors.warning;
  static const Color errorRed       = AppColors.error;
  static const Color infoBlue       = AppColors.info;
  static const Color gardenGrass    = AppColors.grass;
  static const Color gardenLeaf     = AppColors.mint;
  static const Color gardenFlower   = AppColors.rose;
  static const Color gardenSun      = AppColors.sunshine;
  static const Color gardenSky      = AppColors.sky;

  static Color getLighterColor(Color color, [double ratio = 0.8]) =>
      Color.lerp(color, Colors.white, ratio) ?? color;

  static Color getDarkerColor(Color color, [double ratio = 0.8]) =>
      Color.lerp(color, Colors.black, ratio) ?? color;

  static ThemeData get childTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.bgMain,
      colorScheme: const ColorScheme.light(
        primary: AppColors.sky,
        secondary: AppColors.grape,
        tertiary: AppColors.mint,
        surface: AppColors.bgCard,
        background: AppColors.bgMain,
        error: AppColors.error,
        onPrimary: AppColors.textWhite,
        onSecondary: AppColors.textWhite,
        onSurface: AppColors.textDark,
        onBackground: AppColors.textDark,
      ),
      textTheme: const TextTheme(
        displayLarge:  TextStyle(fontSize: 48, fontWeight: FontWeight.w900, color: AppColors.textDark),
        headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: AppColors.textDark),
        headlineMedium:TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: AppColors.textDark),
        headlineSmall: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textDark),
        titleLarge:    TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textDark),
        titleMedium:   TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textDark),
        bodyLarge:     TextStyle(fontSize: 17, color: AppColors.textDark),
        bodyMedium:    TextStyle(fontSize: 15, color: AppColors.textMid),
        bodySmall:     TextStyle(fontSize: 13, color: AppColors.textLight),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        clipBehavior: Clip.antiAlias,
        color: AppColors.bgCard,
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textDark,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
    );
  }

  static LinearGradient get rainbowGradient => const LinearGradient(
    colors: [AppColors.coral, AppColors.peach, AppColors.sunshine,
             AppColors.grass, AppColors.sky, AppColors.grape, AppColors.rose],
  );

  static List<Color> get confettiColors =>
      [AppColors.coral, AppColors.sunshine, AppColors.grass,
       AppColors.sky, AppColors.grape, AppColors.rose, AppColors.peach];

  static BoxDecoration get playfulCardDecoration => BoxDecoration(
    color: AppColors.bgCard,
    borderRadius: BorderRadius.circular(24),
    boxShadow: [
      BoxShadow(color: AppColors.sky.withOpacity(0.12), blurRadius: 20, offset: const Offset(0, 8)),
    ],
  );
}