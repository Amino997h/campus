import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'app.dart';
import 'core/theme/theme_service.dart';
import 'features/presence/data/presence_service.dart';
import 'features/notifications/data/local_notification_service.dart';

export 'app.dart';
export 'features/posts/presentation/screens/home_feed_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // تهيئة وقراءة ثيم وألوان المستخدم المفضلة
  await ThemeService().init();

  // تهيئة مراقبة حالة الاتصال والتواجد الحي
  PresenceService().init();

  // تهيئة خدمة التنبيهات المحلية في الهاتف
  await LocalNotificationService().init();

  runApp(const CampusApp());
}
