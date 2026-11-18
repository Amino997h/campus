import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'core/constants/app_colors.dart';
import 'features/auth/data/auth_repository.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/posts/presentation/screens/home_feed_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authRepo = AuthRepository();

    return StreamBuilder<User?>(
      stream: authRepo.authStateChanges,
      builder: (context, snapshot) {
        // حالة انتظار التحقق من الجلسة المخزنة
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        }

        // إذا كان مسجل دخول ومحفوظ في الجلسة ينتقل مباشرة لـ HomeFeedScreen
        if (snapshot.hasData && snapshot.data != null) {
          return const HomeFeedScreen();
        }

        // إذا لم يسجل دخوله بعد، تقابله شاشة تسجيل الدخول
        return const LoginScreen();
      },
    );
  }
}
