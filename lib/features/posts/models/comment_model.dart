import 'package:cloud_firestore/cloud_firestore.dart';

class CommentModel {
  final String id;
  final String authorName;
  final String authorUid;
  final String authorPhoto;
  final String text;
  final String? replyToCommentId;
  final String? replyToAuthorName;
  final List<String> likes;
  final int likesCount;
  final DateTime? createdAt;

  const CommentModel({
    required this.id,
    this.authorName = 'Student',
    this.authorUid = '',
    this.authorPhoto = '',
    this.text = '',
    this.replyToCommentId,
    this.replyToAuthorName,
    this.likes = const [],
    this.likesCount = 0,
    this.createdAt,
  });

  bool get isReply => replyToAuthorName != null && replyToAuthorName!.isNotEmpty;
  bool isLikedBy(String uid) => likes.contains(uid);
  bool isOwner(String uid) => authorUid == uid;

  factory CommentModel.fromMap(Map<String, dynamic> data, {String id = ''}) {
    DateTime? parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is DateTime) return val;
      if (val is int) return DateTime.fromMillisecondsSinceEpoch(val);
      return null;
    }

    final likesList = List<String>.from(data['likes'] ?? []);
    final rawLikesCount = data['likesCount'];
    final effectiveLikesCount = (rawLikesCount is num)
        ? rawLikesCount.toInt()
        : likesList.length;

    return CommentModel(
      id: id.isNotEmpty ? id : (data['id'] ?? ''),
      authorName: data['authorName'] ?? 'Student',
      authorUid: data['authorUid'] ?? '',
      authorPhoto: data['authorPhoto'] ?? '',
      text: data['text'] ?? '',
      replyToCommentId: data['replyToCommentId'],
      replyToAuthorName: data['replyToAuthorName'],
      likes: likesList,
      likesCount: effectiveLikesCount,
      createdAt: parseDate(data['createdAt']),
    );
  }

  factory CommentModel.fromFirestore(DocumentSnapshot doc) {
    final data = (doc.data() as Map<String, dynamic>?) ?? {};
    return CommentModel.fromMap(data, id: doc.id);
  }

  Map<String, dynamic> toMap() {
    return {
      'authorName': authorName,
      'authorUid': authorUid,
      'authorPhoto': authorPhoto,
      'text': text,
      'replyToCommentId': replyToCommentId,
      'replyToAuthorName': replyToAuthorName,
      'likes': likes,
      'likesCount': likesCount,
      if (createdAt != null) 'createdAt': Timestamp.fromDate(createdAt!),
    };
  }

  CommentModel copyWith({
    String? id,
    String? authorName,
    String? authorUid,
    String? authorPhoto,
    String? text,
    String? replyToCommentId,
    String? replyToAuthorName,
    List<String>? likes,
    int? likesCount,
    DateTime? createdAt,
  }) {
    return CommentModel(
      id: id ?? this.id,
      authorName: authorName ?? this.authorName,
      authorUid: authorUid ?? this.authorUid,
      authorPhoto: authorPhoto ?? this.authorPhoto,
      text: text ?? this.text,
      replyToCommentId: replyToCommentId ?? this.replyToCommentId,
      replyToAuthorName: replyToAuthorName ?? this.replyToAuthorName,
      likes: likes ?? this.likes,
      likesCount: likesCount ?? this.likesCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
