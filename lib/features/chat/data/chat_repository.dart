import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/chat_message_model.dart';
import '../models/chat_conversation_model.dart';
import '../../notifications/data/local_notification_service.dart';

class ChatRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final LocalNotificationService _notifService;

  ChatRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    LocalNotificationService? notifService,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        _notifService = notifService ?? LocalNotificationService();

  // جلب تدفق المحادثات للمستخدم الحالي
  Stream<List<ChatConversationModel>> getUserChatsStream(String currentUid) {
    return _firestore
        .collection('chats')
        .where('participants', arrayContains: currentUid)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ChatConversationModel.fromFirestore(doc))
            .toList());
  }

  // فحص وجود رسائل غير مقروءة للمستخدم كـ Stream
  Stream<bool> hasUnreadMessagesStream(String currentUid) {
    if (currentUid.isEmpty || currentUid == 'guest' || currentUid == 'guest_user') {
      return Stream.value(false);
    }
    return _firestore
        .collection('chats')
        .where('participants', arrayContains: currentUid)
        .where('unreadBy', isEqualTo: currentUid)
        .limit(1)
        .snapshots()
        .map((snapshot) => snapshot.docs.isNotEmpty);
  }

  // جلب تدفق رسائل المحادثة مرتبة بالأحدث أولاً
  Stream<List<ChatMessageModel>> getChatMessagesStream(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ChatMessageModel.fromFirestore(doc))
            .toList());
  }

  // إرسال رسالة نصية أو صورة
  Future<void> sendMessage({
    required String chatId,
    required String recipientName,
    required String recipientUid,
    String text = '',
    String? imageUrl,
  }) async {
    final user = _auth.currentUser;
    final userDoc = user != null
        ? await _firestore.collection('users').doc(user.uid).get()
        : null;
    final userData = userDoc?.data();
    final senderName = userData?['name'] ?? user?.displayName ?? 'Student';
    final senderUid = user?.uid ?? 'guest';

    final messageSnippet = imageUrl != null && imageUrl.isNotEmpty
        ? (text.isNotEmpty ? text : '📷 Photo')
        : text;

    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add({
      'senderId': senderUid,
      'senderName': senderName,
      'text': text,
      'imageUrl': imageUrl ?? '',
      'createdAt': FieldValue.serverTimestamp(),
    });

    await _firestore.collection('chats').doc(chatId).set({
      'chatId': chatId,
      'lastMessage': messageSnippet,
      'lastMessageTime': FieldValue.serverTimestamp(),
      'lastSenderId': senderUid,
      'participants': [senderUid, recipientUid],
      'unreadBy': recipientUid,
    }, SetOptions(merge: true));

    // إرسال تنبيه محلي للهاتف فقط للمستلم، بدون إضافته لمجموعة notifications العامة
    await _notifService.showNotification(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: 'New message from $senderName',
      body: messageSnippet,
      payload: 'chat:$chatId',
    );
  }

  // تعليم المحادثة كمقروءة للمستخدم الحالي
  Future<void> markChatAsRead(String chatId, String currentUid) async {
    try {
      final chatRef = _firestore.collection('chats').doc(chatId);
      final doc = await chatRef.get();
      if (doc.exists && doc.data()?['unreadBy'] == currentUid) {
        await chatRef.update({'unreadBy': null});
      }
    } catch (_) {}
  }

  // حذف المحادثة بالكامل ورسائلها
  Future<void> deleteChat(String chatId) async {
    final messages = await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .get();

    for (var doc in messages.docs) {
      await doc.reference.delete();
    }
    await _firestore.collection('chats').doc(chatId).delete();
  }
}
