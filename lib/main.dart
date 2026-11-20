import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'app.dart';
import 'core/theme/theme_service.dart';
import 'features/presence/data/presence_service.dart';

export 'app.dart';
export 'features/posts/presentation/screens/home_feed_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // تهيئة Firebase بأمان مع معالجة الأخطاء حتى لا يتجمد التطبيق في شاشة البداية
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase initialization error: $e');
    // محاولة بديلة للتهيئة التلقائية عبر google-services.json على أندرويد
    try {
      await Firebase.initializeApp();
    } catch (e2) {
      debugPrint('Firebase fallback initialization error: $e2');
    }
  }

  // تهيئة وقراءة ثيم وألوان المستخدم المفضلة
  try {
    await ThemeService().init();
  } catch (e) {
    debugPrint('ThemeService init error: $e');
  }

  // تهيئة مراقبة حالة الاتصال والتواجد الحي
  try {
    PresenceService().init();
  } catch (e) {
    debugPrint('PresenceService init error: $e');
  }

  runApp(const CampusApp());
}
