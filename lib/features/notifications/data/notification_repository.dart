import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notification_model.dart';

class NotificationRepository {
  final FirebaseFirestore _firestore;

  NotificationRepository({
    FirebaseFirestore? firestore,
  })  : _firestore = firestore ?? FirebaseFirestore.instance;

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

  // تعليم جميع إشعارات المستخدم كمقروءة دفعة واحدة (Batch Write) بأمان
  Future<void> markAllNotificationsAsRead(String uid) async {
    if (uid.isEmpty || uid == 'guest' || uid == 'guest_user') return;

    try {
      final unreadDocs = await _firestore
          .collection('notifications')
          .where('targetUid', isEqualTo: uid)
          .where('unread', isEqualTo: true)
          .get();

      if (unreadDocs.docs.isEmpty) return;

      // استخدام WriteBatch لضمان تحديث كل الإشعارات دفعة واحدة ذرية وسريعة
      final batch = _firestore.batch();
      for (final doc in unreadDocs.docs) {
        batch.update(doc.reference, {'unread': false});
      }
      await batch.commit();
    } catch (_) {}
  }
}
