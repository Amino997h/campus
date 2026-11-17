import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  final String id;
  final String authorName;
  final String authorUid;
  final String authorPhoto;
  final String major;
  final String content;
  final String imageUrl;
  final String? projectRefId;
  final String? projectRefTitle;
  final String? projectRefUrl;
  final List<String> likes;
  final int likesCount;
  final int commentsCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const PostModel({
    required this.id,
    this.authorName = 'Campus Student',
    this.authorUid = '',
    this.authorPhoto = '',
    this.major = 'CS',
    this.content = '',
    this.imageUrl = '',
    this.projectRefId,
    this.projectRefTitle,
    this.projectRefUrl,
    this.likes = const [],
    this.likesCount = 0,
    this.commentsCount = 0,
    this.createdAt,
    this.updatedAt,
  });

  bool isLikedBy(String uid) => likes.contains(uid);
  bool isOwner(String uid) => authorUid == uid;
  bool get hasImage => imageUrl.trim().isNotEmpty;
  bool get hasContent => content.trim().isNotEmpty;
  bool get hasProjectRef =>
      projectRefTitle != null &&
      projectRefTitle!.trim().isNotEmpty &&
      projectRefUrl != null &&
      projectRefUrl!.trim().isNotEmpty;

  factory PostModel.fromMap(Map<String, dynamic> data, {String id = ''}) {
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

    return PostModel(
      id: id.isNotEmpty ? id : (data['id'] ?? ''),
      authorName: data['authorName'] ?? 'Campus Student',
      authorUid: data['authorUid'] ?? '',
      authorPhoto: data['authorPhoto'] ?? '',
      major: data['major'] ?? 'CS',
      content: data['content'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      projectRefId: data['projectRefId'],
      projectRefTitle: data['projectRefTitle'],
      projectRefUrl: data['projectRefUrl'],
      likes: likesList,
      likesCount: effectiveLikesCount,
      commentsCount: (data['commentsCount'] as num?)?.toInt() ?? 0,
      createdAt: parseDate(data['createdAt']),
      updatedAt: parseDate(data['updatedAt']),
    );
  }

  factory PostModel.fromFirestore(DocumentSnapshot doc) {
    final data = (doc.data() as Map<String, dynamic>?) ?? {};
    return PostModel.fromMap(data, id: doc.id);
  }

  Map<String, dynamic> toMap() {
    return {
      'authorName': authorName,
      'authorUid': authorUid,
      'authorPhoto': authorPhoto,
      'major': major,
      'content': content,
      'imageUrl': imageUrl,
      if (projectRefId != null) 'projectRefId': projectRefId,
      if (projectRefTitle != null) 'projectRefTitle': projectRefTitle,
      if (projectRefUrl != null) 'projectRefUrl': projectRefUrl,
      'likes': likes,
      'likesCount': likesCount,
      'commentsCount': commentsCount,
      if (createdAt != null) 'createdAt': Timestamp.fromDate(createdAt!),
      if (updatedAt != null) 'updatedAt': Timestamp.fromDate(updatedAt!),
    };
  }

  PostModel copyWith({
    String? id,
    String? authorName,
    String? authorUid,
    String? authorPhoto,
    String? major,
    String? content,
    String? imageUrl,
    String? projectRefId,
    String? projectRefTitle,
    String? projectRefUrl,
    List<String>? likes,
    int? likesCount,
    int? commentsCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PostModel(
      id: id ?? this.id,
      authorName: authorName ?? this.authorName,
      authorUid: authorUid ?? this.authorUid,
      authorPhoto: authorPhoto ?? this.authorPhoto,
      major: major ?? this.major,
      content: content ?? this.content,
      imageUrl: imageUrl ?? this.imageUrl,
      projectRefId: projectRefId ?? this.projectRefId,
      projectRefTitle: projectRefTitle ?? this.projectRefTitle,
      projectRefUrl: projectRefUrl ?? this.projectRefUrl,
      likes: likes ?? this.likes,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
