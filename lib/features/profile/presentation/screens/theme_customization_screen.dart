import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/theme_service.dart';

class ThemeCustomizationScreen extends StatefulWidget {
  const ThemeCustomizationScreen({super.key});

  @override
  State<ThemeCustomizationScreen> createState() => _ThemeCustomizationScreenState();
}

class _ThemeCustomizationScreenState extends State<ThemeCustomizationScreen> {
  final ThemeService _themeService = ThemeService();

  late Color _customPrimary;
  late Color _customNavy;
  late Color _customSurface;
  bool _isCustomMode = false;

  // خيارات الألوان المتاحة في منتقي الألوان اليدوي
  static const List<Color> _primaryOptions = [
    Color(0xFFE84A5F), // Pink / Berry (Original)
    Color(0xFF0284C7), // Sky Blue
    Color(0xFF2563EB), // Royal Blue
    Color(0xFF059669), // Emerald Green
    Color(0xFF10B981), // Mint Green
    Color(0xFFEA580C), // Flame Orange
    Color(0xFFD97706), // Amber Gold
    Color(0xFF7C3AED), // Royal Purple
    Color(0xFFDB2777), // Deep Rose
    Color(0xFF475569), // Slate Grey
  ];

  static const List<Color> _navyOptions = [
    Color(0xFF1F3C6D), // Classic Academic Navy
    Color(0xFF0F172A), // Midnight Dark
    Color(0xFF064E3B), // Deep Forest Pine
    Color(0xFF18181B), // Volcanic Dark Slate
    Color(0xFF1E1B4B), // Deep Indigo Night
    Color(0xFF312E81), // Deep Royal Indigo
    Color(0xFF4A044E), // Deep Plum
    Color(0xFF1C1917), // Deep Espresso
  ];

  static const List<Color> _surfaceOptions = [
    Color(0xFFF8FAFC), // Crisp Clean White/Slate (Original)
    Color(0xFFF0F9FF), // Light Sky Tint
    Color(0xFFF0FDF4), // Light Mint Tint
    Color(0xFFFFFBEB), // Light Amber Cream
    Color(0xFFFAF5FF), // Light Lavender Tint
    Color(0xFFFFF1F2), // Light Rose Tint
    Color(0xFFF1F5F9), // Slate Cool
    Colors.white,       // Pure White
  ];

  @override
  void initState() {
    super.initState();
    _customPrimary = _themeService.primary;
    _customNavy = _themeService.navy;
    _customSurface = _themeService.surface;
    _isCustomMode = _themeService.activePresetId == 'custom';
  }

  void _onSelectPreset(ThemePreset preset) {
    setState(() {
      _isCustomMode = false;
      _customPrimary = preset.primary;
      _customNavy = preset.navy;
      _customSurface = preset.surface;
    });
    _themeService.applyPreset(preset);
  }

  void _applyCustomColor({Color? primary, Color? navy, Color? surface}) {
    setState(() {
      _isCustomMode = true;
      if (primary != null) _customPrimary = primary;
      if (navy != null) _customNavy = navy;
      if (surface != null) _customSurface = surface;
    });
    _themeService.applyCustomColors(
      primary: _customPrimary,
      navy: _customNavy,
      surface: _customSurface,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.navy, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Theme & Colors',
          style: TextStyle(
            color: AppColors.navy,
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await _themeService.resetToDefault();
              setState(() {
                _isCustomMode = false;
                _customPrimary = _themeService.primary;
                _customNavy = _themeService.navy;
                _customSurface = _themeService.surface;
              });
            },
            child: Text(
              'Reset',
              style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 13.5),
            ),
          ),
          const SizedBox(width: 6.0),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Divider(height: 1.0, color: AppColors.borderLight),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 18.0),
        children: [
          // 1. بطاقة المعاينة الحية (Live Interactive Preview Card)
          _buildLivePreviewCard(),
          const SizedBox(height: 16.0),

          // تنبيه الموثوقية والحصانة
          _buildImmunityNotice(),
          const SizedBox(height: 24.0),

          // 2. الحزم السريعة (Curated Preset Bundles)
          const Text(
            'QUICK PRESETS',
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.bold,
              color: AppColors.textMuted,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 12.0),
          ...ThemeService.presets.map((preset) => _buildPresetTile(preset)),
          const SizedBox(height: 28.0),

          // 3. التخصيص الكامل اليدوي (Custom Color Studio)
          Row(
            children: [
              const Text(
                'CUSTOM PALETTE STUDIO',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textMuted,
                  letterSpacing: 0.8,
                ),
              ),
              const Spacer(),
              if (_isCustomMode)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.5),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Text(
                    'Active',
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14.0),

          // تخصيص اللون الأساسي (Primary Accent)
          _buildColorPickerSection(
            title: '1. Primary Accent (Buttons, Highlights & Icons)',
            selectedColor: _customPrimary,
            palette: _primaryOptions,
            onColorPicked: (c) => _applyCustomColor(primary: c),
          ),
          const SizedBox(height: 20.0),

          // تخصيص لون العناوين والشريط (Navy / Titles)
          _buildColorPickerSection(
            title: '2. Titles & Nav Elements (Headings & Bottom Nav)',
            selectedColor: _customNavy,
            palette: _navyOptions,
            onColorPicked: (c) => _applyCustomColor(navy: c),
          ),
          const SizedBox(height: 20.0),

          // تخصيص لون الأسطح والبطاقات (Surface Tint)
          _buildColorPickerSection(
            title: '3. Surface & Card Background Tint',
            selectedColor: _customSurface,
            palette: _surfaceOptions,
            onColorPicked: (c) => _applyCustomColor(surface: c),
          ),
          const SizedBox(height: 40.0),
        ],
      ),
    );
  }

  Widget _buildLivePreviewCard() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18.0),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38.0,
                height: 38.0,
                decoration: BoxDecoration(
                  color: AppColors.navy.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(Icons.palette_rounded, color: AppColors.navy, size: 20),
                ),
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Live Interface Preview',
                      style: TextStyle(
                        fontSize: 14.0,
                        fontWeight: FontWeight.bold,
                        color: AppColors.navy,
                      ),
                    ),
                    const SizedBox(height: 2.0),
                    Text(
                      'See how buttons and accents look in real-time',
                      style: TextStyle(fontSize: 11.5, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
              Container(
                width: 12.0,
                height: 12.0,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14.0),
          Row(
            children: [
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.0)),
                ),
                onPressed: () {},
                icon: const Icon(Icons.send_rounded, size: 14.0),
                label: const Text('Primary Button', style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 10.0),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14.0),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.forum_outlined, size: 15.0, color: AppColors.navy),
                    const SizedBox(width: 5.0),
                    Text(
                      'Outlined',
                      style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.bold, color: AppColors.navy),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImmunityNotice() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          const Icon(Icons.verified_rounded, size: 18.0, color: Color(0xFF0D9488)),
          const SizedBox(width: 10.0),
          Expanded(
            child: Text(
              'Academic Verification Rings remain authentic and unaffected to preserve student credibility.',
              style: TextStyle(
                fontSize: 11.5,
                color: AppColors.textMuted,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPresetTile(ThemePreset preset) {
    final isSelected = !_isCustomMode && _themeService.activePresetId == preset.id;

    return InkWell(
      borderRadius: BorderRadius.circular(14.0),
      onTap: () => _onSelectPreset(preset),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10.0),
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : AppColors.surface,
          borderRadius: BorderRadius.circular(14.0),
          border: Border.all(
            color: isSelected ? AppColors.navy : AppColors.borderLight,
            width: isSelected ? 1.8 : 1.0,
          ),
        ),
        child: Row(
          children: [
            // دوائر الألوان التي تمثل الحزمة
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildColorCircle(preset.primary, 24.0),
                const SizedBox(width: 4.0),
                _buildColorCircle(preset.navy, 24.0),
                const SizedBox(width: 4.0),
                _buildColorCircle(preset.surface, 24.0, border: true),
              ],
            ),
            const SizedBox(width: 14.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    preset.name,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.bold,
                      color: AppColors.navy,
                    ),
                  ),
                  const SizedBox(height: 2.0),
                  Text(
                    preset.description,
                    style: TextStyle(fontSize: 11.0, color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
            Icon(
              isSelected ? Icons.check_circle_rounded : Icons.radio_button_off_rounded,
              size: 20.0,
              color: isSelected ? AppColors.navy : AppColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorPickerSection({
    required String title,
    required Color selectedColor,
    required List<Color> palette,
    required Function(Color) onColorPicked,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.bold,
            color: AppColors.navy,
          ),
        ),
        const SizedBox(height: 10.0),
        Wrap(
          spacing: 10.0,
          runSpacing: 10.0,
          children: palette.map((color) {
            final isPicked = selectedColor.toARGB32() == color.toARGB32();
            return GestureDetector(
              onTap: () => onColorPicked(color),
              child: Container(
                width: 36.0,
                height: 36.0,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isPicked ? AppColors.navy : AppColors.borderLight,
                    width: isPicked ? 2.5 : 1.0,
                  ),
                ),
                child: isPicked
                    ? Icon(
                        Icons.check_rounded,
                        size: 18.0,
                        color: color.computeLuminance() > 0.6 ? Colors.black : Colors.white,
                      )
                    : null,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildColorCircle(Color color, double size, {bool border = false}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: border ? Border.all(color: AppColors.borderLight) : null,
      ),
    );
  }
}
