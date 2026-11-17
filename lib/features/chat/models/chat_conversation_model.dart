import 'package:cloud_firestore/cloud_firestore.dart';

class ChatConversationModel {
  final String chatId;
  final String lastMessage;
  final DateTime? lastMessageTime;
  final String lastSenderId;
  final List<String> participants;
  final String? unreadBy;

  const ChatConversationModel({
    required this.chatId,
    this.lastMessage = '',
    this.lastMessageTime,
    this.lastSenderId = '',
    this.participants = const [],
    this.unreadBy,
  });

  bool isUnreadFor(String currentUid) => unreadBy == currentUid;

  String getOtherUid(String myUid) {
    return participants.firstWhere(
      (id) => id != myUid,
      orElse: () => '',
    );
  }

  factory ChatConversationModel.fromMap(Map<String, dynamic> data, {String id = ''}) {
    DateTime? parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is DateTime) return val;
      if (val is int) return DateTime.fromMillisecondsSinceEpoch(val);
      return null;
    }

    return ChatConversationModel(
      chatId: id.isNotEmpty ? id : (data['chatId'] ?? ''),
      lastMessage: data['lastMessage'] ?? '',
      lastMessageTime: parseDate(data['lastMessageTime']),
      lastSenderId: data['lastSenderId'] ?? '',
      participants: List<String>.from(data['participants'] ?? []),
      unreadBy: data['unreadBy'],
    );
  }

  factory ChatConversationModel.fromFirestore(DocumentSnapshot doc) {
    final data = (doc.data() as Map<String, dynamic>?) ?? {};
    return ChatConversationModel.fromMap(data, id: doc.id);
  }

  Map<String, dynamic> toMap() {
    return {
      'chatId': chatId,
      'lastMessage': lastMessage,
      'lastSenderId': lastSenderId,
      'participants': participants,
      'unreadBy': unreadBy,
      if (lastMessageTime != null)
        'lastMessageTime': Timestamp.fromDate(lastMessageTime!),
    };
  }

  ChatConversationModel copyWith({
    String? chatId,
    String? lastMessage,
    DateTime? lastMessageTime,
    String? lastSenderId,
    List<String>? participants,
    String? unreadBy,
  }) {
    return ChatConversationModel(
      chatId: chatId ?? this.chatId,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      lastSenderId: lastSenderId ?? this.lastSenderId,
      participants: participants ?? this.participants,
      unreadBy: unreadBy ?? this.unreadBy,
    );
  }
}
