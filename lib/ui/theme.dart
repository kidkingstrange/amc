// lib/ui/theme.dart
import 'package:flutter/material.dart';

class AppColors {
  // Light Theme Palette (Paper & Ink)
  static const Color primary = Color(0xFF4F46E5); // Indigo
  static const Color yellow = Color(0xFFFFC93C); // Sunny
  static const Color coral = Color(0xFFFF6B6B); // Coral
  static const Color mint = Color(0xFF2EC4B6); // Mint
  static const Color sky = Color(0xFF4CC9F0); // Sky
  static const Color grape = Color(0xFF9B5DE5); // Grape
  static const Color paper = Color(0xFFFFF9F0); // Paper background
  static const Color ink = Color(0xFF1F2340); // Ink text

  // Dark Theme Palette
  static const Color nightBg = Color(0xFF121526);
  static const Color nightSurface = Color(0xFF1E2338);
  static const Color nightCell = Color(0xFF1A1E36);
  static const Color nightCellActive = Color(0xFF2D325A);

  // Crossword Cell Tints
  static const Color cellActiveLight = Color(0xFFEEF2FF);
  static const Color cellSelectedLight = Color(0xFFC7D2FE);
  static const Color cellError = Color(0xFFFFE4E6);
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.paper,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        secondary: AppColors.mint,
        surface: AppColors.paper,
        onSurface: AppColors.ink,
      ),
      fontFamily: 'Nunito',
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.nightBg,
      colorScheme: ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.mint,
        surface: AppColors.nightSurface,
        onSurface: Colors.white,
      ),
      fontFamily: 'Nunito',
    );
  }
}
