import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notification_model.dart';
import 'local_notification_service.dart';

class NotificationRepository {
  final FirebaseFirestore _firestore;
  final LocalNotificationService _notifService;

  NotificationRepository({
    FirebaseFirestore? firestore,
    LocalNotificationService? notifService,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _notifService = notifService ?? LocalNotificationService();

  // جلب تدفق إشعارات المستخدم
  Stream<List<NotificationModel>> getMyNotificationsStream(String uid) {
    return _firestore
        .collection('notifications')
        .where('targetUid', isEqualTo: uid)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => NotificationModel.fromFirestore(doc))
            .toList());
  }

  // إنشاء إشعار في Firestore وتنبيه محلي
  Future<void> createNotification({
    required String targetUid,
    required String title,
    required String subtitle,
    required String type,
    required String relatedId,
  }) async {
    await _firestore.collection('notifications').add({
      'targetUid': targetUid,
      'title': title,
      'subtitle': subtitle,
      'type': type,
      'relatedId': relatedId,
      'unread': true,
      'createdAt': FieldValue.serverTimestamp(),
    });

    await _notifService.showNotification(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: 'Campus',
      body: '$title: $subtitle',
      payload: '$type:$relatedId',
    );
  }

  // فحص وجود إشعارات غير مقروءة للمستخدم كـ Stream
  Stream<bool> hasUnreadNotificationsStream(String uid) {
    if (uid.isEmpty || uid == 'guest' || uid == 'guest_user') {
      return Stream.value(false);
    }
    return _firestore
        .collection('notifications')
        .where('targetUid', isEqualTo: uid)
        .where('unread', isEqualTo: true)
        .limit(1)
        .snapshots()
        .map((snapshot) => snapshot.docs.isNotEmpty);
  }

  // تعليم الإشعار كمقروء
  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await _firestore
          .collection('notifications')
          .doc(notificationId)
          .update({'unread': false});
    } catch (_) {}
  }
}
