import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const primary = Color(0xFF7C6AFF);
  static const accent = Color(0xFF5B8FFF);
  static const background = Color(0xFF0F0F1A);
  static const card = Color(0xFF1A1830);
  static const surface = Color(0xFF252340);
  static const textWhite = Color(0xFFFFFFFF);
  static const textGrey = Color(0xFF9999BB);
  static const success = Color(0xFF4CAF50);
  static const warning = Color(0xFFFFC107);
  static const error = Color(0xFFF44336);
  static const info = Color(0xFF2196F3);
}

class AppTheme {
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.background,
    primaryColor: AppColors.primary,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primary,
      secondary: AppColors.accent,
      surface: AppColors.card,
    ),
    textTheme: GoogleFonts.plusJakartaSansTextTheme(
      ThemeData.dark().textTheme,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: AppColors.textWhite,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    useMaterial3: true,
  );

  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: AppColors.primary,
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.accent,
    ),
    textTheme: GoogleFonts.plusJakartaSansTextTheme(
      ThemeData.light().textTheme,
    ),
    useMaterial3: true,
  );
}
