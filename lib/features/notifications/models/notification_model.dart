import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String id;
  final String targetUid;
  final String title;
  final String subtitle;
  final String type; // 'like' | 'comment' | 'follow' | 'post'
  final String relatedId;
  final bool unread;
  final DateTime? createdAt;

  const NotificationModel({
    required this.id,
    this.targetUid = '',
    this.title = '',
    this.subtitle = '',
    this.type = 'like',
    this.relatedId = '',
    this.unread = true,
    this.createdAt,
  });

  bool get isLike => type == 'like';
  bool get isComment => type == 'comment';
  bool get isFollow => type == 'follow';
  bool get isPost => type == 'post';

  factory NotificationModel.fromMap(Map<String, dynamic> data, {String id = ''}) {
    DateTime? parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is DateTime) return val;
      if (val is int) return DateTime.fromMillisecondsSinceEpoch(val);
      return null;
    }

    return NotificationModel(
      id: id.isNotEmpty ? id : (data['id'] ?? ''),
      targetUid: data['targetUid'] ?? '',
      title: data['title'] ?? '',
      subtitle: data['subtitle'] ?? '',
      type: data['type'] ?? 'like',
      relatedId: data['relatedId'] ?? '',
      unread: data['unread'] ?? true,
      createdAt: parseDate(data['createdAt']),
    );
  }

  factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
    final data = (doc.data() as Map<String, dynamic>?) ?? {};
    return NotificationModel.fromMap(data, id: doc.id);
  }

  Map<String, dynamic> toMap() {
    return {
      'targetUid': targetUid,
      'title': title,
      'subtitle': subtitle,
      'type': type,
      'relatedId': relatedId,
      'unread': unread,
      if (createdAt != null) 'createdAt': Timestamp.fromDate(createdAt!),
    };
  }

  NotificationModel copyWith({
    String? id,
    String? targetUid,
    String? title,
    String? subtitle,
    String? type,
    String? relatedId,
    bool? unread,
    DateTime? createdAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      targetUid: targetUid ?? this.targetUid,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      type: type ?? this.type,
      relatedId: relatedId ?? this.relatedId,
      unread: unread ?? this.unread,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
