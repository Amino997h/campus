import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessageModel {
  final String id;
  final String senderId;
  final String senderName;
  final String text;
  final String imageUrl;
  final DateTime? createdAt;

  const ChatMessageModel({
    required this.id,
    this.senderId = '',
    this.senderName = 'Student',
    this.text = '',
    this.imageUrl = '',
    this.createdAt,
  });

  bool isMe(String currentUid) => senderId == currentUid;
  bool get hasImage => imageUrl.trim().isNotEmpty;
  bool get hasText => text.trim().isNotEmpty;

  factory ChatMessageModel.fromMap(Map<String, dynamic> data, {String id = ''}) {
    DateTime? parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is DateTime) return val;
      if (val is int) return DateTime.fromMillisecondsSinceEpoch(val);
      return null;
    }

    return ChatMessageModel(
      id: id.isNotEmpty ? id : (data['id'] ?? ''),
      senderId: data['senderId'] ?? '',
      senderName: data['senderName'] ?? 'Student',
      text: data['text'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      createdAt: parseDate(data['createdAt']),
    );
  }

  factory ChatMessageModel.fromFirestore(DocumentSnapshot doc) {
    final data = (doc.data() as Map<String, dynamic>?) ?? {};
    return ChatMessageModel.fromMap(data, id: doc.id);
  }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'senderName': senderName,
      'text': text,
      'imageUrl': imageUrl,
      if (createdAt != null) 'createdAt': Timestamp.fromDate(createdAt!),
    };
  }

  ChatMessageModel copyWith({
    String? id,
    String? senderId,
    String? senderName,
    String? text,
    String? imageUrl,
    DateTime? createdAt,
  }) {
    return ChatMessageModel(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      text: text ?? this.text,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
