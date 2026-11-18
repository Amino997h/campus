import 'package:flutter/material.dart';
import '../theme/theme_service.dart';

class AppColors {
  // ألوان ديناميكية تتغير حسب الثيم الذي يختاره المستخدم
  static Color get primary => ThemeService().primary;
  static Color get primaryDark => ThemeService().primary;
  static Color get primaryLight => ThemeService().primaryLight;

  static Color get navy => ThemeService().navy;
  static Color get navyDark => ThemeService().navy;
  static const Color avatarBg = Color(0xFFDCE6F5);

  // ألوان النصوص والحدود
  static const Color textDark = Color(0xFF0F1A2C);
  static const Color textMuted = Color(0xFF9CA7B7);
  static const Color borderLight = Color(0xFFE5E9F0);
  static const Color searchBarBg = Color(0xFFF4F6F9);
  static Color get surface => ThemeService().surface;
  static const Color background = Colors.white;

  // ألوان حلقات التحقق الأكاديمية (محمية ومستثناة تماماً ولا تتغير أبداً)
  static const Color verificationDefault = Color(0xFFE84A5F); // Level 1 (Pink)
  static const Color verificationNavy = Color(0xFF1F3C6D);    // Level 2 (Academic Navy)
  static const Color verificationEmerald = Color(0xFF0D9488); // Level 3 Student (Emerald Green)
  static const Color verificationGold = Color(0xFFC59B27);    // Level 3 Professor (Academic Gold)
}
