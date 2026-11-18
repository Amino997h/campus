import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// الفئات اللونية الجاهزة (Color Presets)
class ThemePreset {
  final String id;
  final String name;
  final String description;
  final Color primary;
  final Color navy;
  final Color surface;
  final Color primaryLight;

  const ThemePreset({
    required this.id,
    required this.name,
    required this.description,
    required this.primary,
    required this.navy,
    required this.surface,
    required this.primaryLight,
  });
}

class ThemeService {
  static final ThemeService _instance = ThemeService._internal();
  factory ThemeService() => _instance;
  ThemeService._internal();

  // إشعار تغيير الألوان لإعادة بناء واجهة التطبيق فورياً
  final ValueNotifier<int> themeNotifier = ValueNotifier<int>(0);

  // الحزم الجاهزة المنسقة
  static const List<ThemePreset> presets = [
    ThemePreset(
      id: 'original',
      name: 'Campus Original',
      description: 'الوردي التوتي والكحلي الأكاديمي',
      primary: Color(0xFFE84A5F),
      navy: Color(0xFF1F3C6D),
      surface: Color(0xFFF8FAFC),
      primaryLight: Color(0xFFFCEAEF),
    ),
    ThemePreset(
      id: 'ocean',
      name: 'Ocean Breeze',
      description: 'أزرق المحيط السماوي والكحلي العميق',
      primary: Color(0xFF0284C7),
      navy: Color(0xFF0F172A),
      surface: Color(0xFFF0F9FF),
      primaryLight: Color(0xFFE0F2FE),
    ),
    ThemePreset(
      id: 'forest',
      name: 'Forest Nature',
      description: 'أخضر الغابة الحيوي والصنوبر الداكن',
      primary: Color(0xFF059669),
      navy: Color(0xFF064E3B),
      surface: Color(0xFFF0FDF4),
      primaryLight: Color(0xFFDCFCE7),
    ),
    ThemePreset(
      id: 'flame',
      name: 'Blazing Flame',
      description: 'البرتقالي الناري الدافئ والأسود الكربوني',
      primary: Color(0xFFEA580C),
      navy: Color(0xFF18181B),
      surface: Color(0xFFFFFBEB),
      primaryLight: Color(0xFFFFEDD5),
    ),
    ThemePreset(
      id: 'lavender',
      name: 'Royal Velvet',
      description: 'البنفسجي الملكي والداكن الليلي',
      primary: Color(0xFF7C3AED),
      navy: Color(0xFF1E1B4B),
      surface: Color(0xFFFAF5FF),
      primaryLight: Color(0xFFF3E8FF),
    ),
  ];

  // الألوان الحالية النشطة
  Color _primary = const Color(0xFFE84A5F);
  Color _navy = const Color(0xFF1F3C6D);
  Color _surface = const Color(0xFFF8FAFC);
  Color _primaryLight = const Color(0xFFFCEAEF);
  String _activePresetId = 'original';

  Color get primary => _primary;
  Color get navy => _navy;
  Color get surface => _surface;
  Color get primaryLight => _primaryLight;
  String get activePresetId => _activePresetId;

  // تهيئة وقراءة التفضيلات المحفوظة
  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _activePresetId = prefs.getString('theme_preset_id') ?? 'original';

      final primaryVal = prefs.getInt('theme_primary');
      final navyVal = prefs.getInt('theme_navy');
      final surfaceVal = prefs.getInt('theme_surface');

      if (primaryVal != null) {
        _primary = Color(primaryVal);
        _primaryLight = _primary.withValues(alpha: 0.12);
      }
      if (navyVal != null) _navy = Color(navyVal);
      if (surfaceVal != null) _surface = Color(surfaceVal);

      themeNotifier.value++;
    } catch (_) {}
  }

  // تطبيق حزمة جاهزة
  Future<void> applyPreset(ThemePreset preset) async {
    _activePresetId = preset.id;
    _primary = preset.primary;
    _navy = preset.navy;
    _surface = preset.surface;
    _primaryLight = preset.primaryLight;

    themeNotifier.value++;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('theme_preset_id', preset.id);
      await prefs.setInt('theme_primary', preset.primary.toARGB32());
      await prefs.setInt('theme_navy', preset.navy.toARGB32());
      await prefs.setInt('theme_surface', preset.surface.toARGB32());
    } catch (_) {}
  }

  // تخصيص الألوان يدوياً
  Future<void> applyCustomColors({
    required Color primary,
    required Color navy,
    required Color surface,
  }) async {
    _activePresetId = 'custom';
    _primary = primary;
    _navy = navy;
    _surface = surface;
    _primaryLight = primary.withValues(alpha: 0.12);

    themeNotifier.value++;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('theme_preset_id', 'custom');
      await prefs.setInt('theme_primary', primary.toARGB32());
      await prefs.setInt('theme_navy', navy.toARGB32());
      await prefs.setInt('theme_surface', surface.toARGB32());
    } catch (_) {}
  }

  // استعادة الألوان الافتراضية
  Future<void> resetToDefault() async {
    await applyPreset(presets.first);
  }
}
