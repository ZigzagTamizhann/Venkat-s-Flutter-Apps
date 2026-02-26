// lib/theme/color_palette.dart
import 'package:flutter/material.dart';
import 'app_theme.dart';

class ColorPalette {
  static const Map<String, Color> letterColors = {
    'A': Color(0xFFFF6B6B), 'B': Color(0xFFFF9F7F), 'C': Color(0xFFFFD93D),
    'D': Color(0xFF5ECC7B), 'E': Color(0xFF4ECBA0), 'F': Color(0xFF5BB8FF),
    'G': Color(0xFFA855F7), 'H': Color(0xFFFF7BAC), 'I': Color(0xFFE67E22),
    'J': Color(0xFF3498DB), 'K': Color(0xFF9B59B6), 'L': Color(0xFF1ABC9C),
    'M': Color(0xFFE74C3C), 'N': Color(0xFFF39C12), 'O': Color(0xFF2ECC71),
    'P': Color(0xFF2980B9), 'Q': Color(0xFF8E44AD), 'R': Color(0xFFD35400),
    'S': Color(0xFF27AE60), 'T': Color(0xFF16A085), 'U': Color(0xFFE67E22),
    'V': Color(0xFF3498DB), 'W': Color(0xFF9B59B6), 'X': Color(0xFFE74C3C),
    'Y': Color(0xFFF1C40F), 'Z': Color(0xFF2C3E50),
    '0': Color(0xFFFF6B6B), '1': Color(0xFFFF9F7F), '2': Color(0xFFFFD93D),
    '3': Color(0xFF5ECC7B), '4': Color(0xFF4ECBA0), '5': Color(0xFF5BB8FF),
    '6': Color(0xFFA855F7), '7': Color(0xFFFF7BAC), '8': Color(0xFFE67E22),
    '9': Color(0xFF3498DB),
  };

  static Color getLetterColor(String letter) =>
      letterColors[letter.toUpperCase()] ?? AppColors.sky;

  static LinearGradient getLetterGradient(String letter) {
    final c = getLetterColor(letter);
    return LinearGradient(
      begin: Alignment.topLeft, end: Alignment.bottomRight,
      colors: [c, AppTheme.getDarkerColor(c, 0.7)],
    );
  }
}