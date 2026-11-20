import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/chat_message_model.dart';
import '../models/chat_conversation_model.dart';

class ChatRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  ChatRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  // إنشاء أو استرجاع محادثة بين مستخدمين
  static String getConversationId(String uid1, String uid2) {
    final list = [uid1, uid2]..sort();
    return '${list[0]}_${list[1]}';
  }

  // التأكد من تهيئة وثيقة المحادثة أو إرجاع الـ chatId
  Future<String> getOrCreateChatId({
    required String currentUid,
    required String recipientUid,
  }) async {
    // 1. أولاً: البحث في المحادثات الحالية عما إذا كانت هناك محادثة سابقة تضم هذين الطرفين
    // سواء تم إنشاؤها بالمعرّف الموحد أو بأي معرف عشوائي سابق في Firestore
    final existingQuery = await _firestore
        .collection('chats')
        .where('participants', arrayContains: currentUid)
        .get();

    for (final doc in existingQuery.docs) {
      final participants = List<String>.from(doc.data()['participants'] ?? []);
      if (participants.contains(recipientUid)) {
        return doc.id; // إرجاع المحادثة القائمة فوراً لمنع التكرار
      }
    }

    // 2. إذا لم تكن هناك محادثة سابقة، ننشئها باستخدام المعرّف الموحد
    final chatId = getConversationId(currentUid, recipientUid);
    final chatDoc = await _firestore.collection('chats').doc(chatId).get();
    if (!chatDoc.exists) {
      await _firestore.collection('chats').doc(chatId).set({
        'chatId': chatId,
        'participants': [currentUid, recipientUid],
        'lastMessage': '',
        'lastSenderId': '',
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
    return chatId;
  }

  // جلب تدفق المحادثات للمستخدم الحالي مع دمج وتصفية أي محادثات مكررة تلقائياً
  Stream<List<ChatConversationModel>> getUserChatsStream(String currentUid) {
    return _firestore
        .collection('chats')
        .where('participants', arrayContains: currentUid)
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs
          .map((doc) => ChatConversationModel.fromFirestore(doc))
          .toList();

      // دمج وتصفية التكرار: إذا كان هناك أكثر من محادثة لنفس الشخص، نحتفظ فقط بالأحدث
      final Map<String, ChatConversationModel> uniqueChatsByPerson = {};
      for (final chat in list) {
        final otherUid = chat.getOtherUid(currentUid);
        if (otherUid.isEmpty) continue;

        if (!uniqueChatsByPerson.containsKey(otherUid)) {
          uniqueChatsByPerson[otherUid] = chat;
        } else {
          final existing = uniqueChatsByPerson[otherUid]!;
          final existingTime = existing.lastMessageTime ?? DateTime.fromMillisecondsSinceEpoch(0);
          final chatTime = chat.lastMessageTime ?? DateTime.fromMillisecondsSinceEpoch(0);
          if (chatTime.isAfter(existingTime)) {
            uniqueChatsByPerson[otherUid] = chat;
          }
        }
      }

      return uniqueChatsByPerson.values.toList();
    });
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
