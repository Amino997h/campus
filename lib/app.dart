import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_service.dart';
import 'auth_wrapper.dart';

class CampusApp extends StatelessWidget {
  const CampusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: ThemeService().themeNotifier,
      builder: (context, _, child) {
        return MaterialApp(
          title: 'Campus',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.buildTheme(
            primary: ThemeService().primary,
            navy: ThemeService().navy,
            surface: ThemeService().surface,
          ),
          home: const AuthWrapper(),
        );
      },
    );
  }
}
