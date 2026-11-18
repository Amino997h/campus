import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';
import 'theme_service.dart';

class AppTheme {
  static ThemeData get lightTheme => buildTheme(
        primary: ThemeService().primary,
        navy: ThemeService().navy,
        surface: ThemeService().surface,
      );

  static ThemeData buildTheme({
    required Color primary,
    required Color navy,
    required Color surface,
  }) {
    final baseTextTheme = Typography.material2021().black;

    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        primary: primary,
        surface: surface,
      ),
      scaffoldBackgroundColor: Colors.white,
      textTheme: GoogleFonts.varelaRoundTextTheme(baseTextTheme),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: navy),
        titleTextStyle: TextStyle(
          color: navy,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.borderLight,
        thickness: 1.0,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: primary,
        unselectedItemColor: navy.withValues(alpha: 0.65),
        elevation: 0,
      ),
    );
  }
}
