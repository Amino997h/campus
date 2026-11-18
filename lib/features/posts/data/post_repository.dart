import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/post_model.dart';
import '../models/comment_model.dart';
import '../../notifications/data/notification_repository.dart';

class PostRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final NotificationRepository _notificationRepo;

  PostRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    NotificationRepository? notificationRepo,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        _notificationRepo = notificationRepo ?? NotificationRepository();

  // جلب تدفق المنشورات لحظياً
  Stream<List<PostModel>> getPostsStream() {
    return _firestore
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PostModel.fromFirestore(doc))
            .toList());
  }

  // جلب المنشورات كـ Future للتحديث بالسحب
  Future<List<PostModel>> getPostsFuture() async {
    final snapshot = await _firestore
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs.map((doc) => PostModel.fromFirestore(doc)).toList();
  }

  // إضافة منشور جديد
  Future<void> createPost({
    required String text,
    String? imageUrl,
    String? projectRefId,
    String? projectRefTitle,
    String? projectRefUrl,
  }) async {
    final user = _auth.currentUser;
    final userDoc = user != null
        ? await _firestore.collection('users').doc(user.uid).get()
        : null;

    final userData = userDoc?.data();
    final authorName = userData?['name'] ?? user?.displayName ?? 'Campus Student';
    final authorPhoto = userData?['photoUrl'] ?? '';
    final major = userData?['major'] ?? 'CS';

    final postRef = await _firestore.collection('posts').add({
      'authorName': authorName,
      'authorUid': user?.uid ?? '',
      'authorPhoto': authorPhoto,
      'major': major,
      'content': text,
      'imageUrl': imageUrl ?? '',
      ...?projectRefId != null ? {'projectRefId': projectRefId} : null,
      ...?projectRefTitle != null ? {'projectRefTitle': projectRefTitle} : null,
      ...?projectRefUrl != null ? {'projectRefUrl': projectRefUrl} : null,
      'likes': <String>[],
      'likesCount': 0,
      'commentsCount': 0,
      'createdAt': FieldValue.serverTimestamp(),
    });

    if (user != null) {
      await _firestore.collection('users').doc(user.uid).update({
        'postsCount': FieldValue.increment(1),
      }).catchError((_) {});

      // إشعار جميع المتابعين بأن شخصاً يتابعونه قد نشر منشوراً جديداً
      try {
        final myDoc = await _firestore.collection('users').doc(user.uid).get();
        final List<String> followers = List<String>.from(myDoc.data()?['followers'] ?? []);
        for (final followerUid in followers) {
          if (followerUid.isNotEmpty && followerUid != user.uid) {
            await _notificationRepo.createNotification(
              targetUid: followerUid,
              title: '$authorName posted an update',
              subtitle: text.length > 30 ? '${text.substring(0, 30)}...' : (text.isNotEmpty ? text : 'Shared a photo'),
              type: 'post',
              relatedId: postRef.id,
            );
          }
        }
      } catch (_) {}
    }
  }

  // تعديل نص المنشور
  Future<void> updatePostText(String postId, String newText) async {
    await _firestore.collection('posts').doc(postId).update({
      'content': newText,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // حذف كامل المنشور
  Future<void> deletePost(String postId) async {
    final user = _auth.currentUser;
    await _firestore.collection('posts').doc(postId).delete();
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).update({
        'postsCount': FieldValue.increment(-1),
      }).catchError((_) {});
    }
  }

  // التفاعل بالإعجاب (Like Toggle)
  Future<void> toggleLike(String postId, List<String> likes, String authorUid, String postSnippet) async {
    final user = _auth.currentUser;
    final uid = user?.uid ?? 'guest_user';
    final myName = user?.displayName ?? 'A student';
    final postRef = _firestore.collection('posts').doc(postId);

    if (likes.contains(uid)) {
      await postRef.update({
        'likes': FieldValue.arrayRemove([uid]),
        'likesCount': FieldValue.increment(-1),
      });
    } else {
      await postRef.update({
        'likes': FieldValue.arrayUnion([uid]),
        'likesCount': FieldValue.increment(1),
      });

      // إشعار صاحب البوست إذا لم يكن المستخدم نفسه
      if (authorUid.isNotEmpty && authorUid != uid) {
        await _notificationRepo.createNotification(
          targetUid: authorUid,
          title: '$myName liked your post',
          subtitle: postSnippet.length > 30 ? '${postSnippet.substring(0, 30)}...' : postSnippet,
          type: 'like',
          relatedId: postId,
        );
      }
    }
  }

  // تدفق تعليقات منشور محدد
  Stream<List<CommentModel>> getCommentsStream(String postId) {
    return _firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CommentModel.fromFirestore(doc))
            .toList());
  }

  // إضافة تعليق مع دعم الرد
  Future<void> addComment({
    required String postId,
    required String commentText,
    required String postAuthorUid,
    String? replyToCommentId,
    String? replyToAuthorName,
  }) async {
    final user = _auth.currentUser;
    final userDoc = user != null
        ? await _firestore.collection('users').doc(user.uid).get()
        : null;
    final userData = userDoc?.data();
    final myName = userData?['name'] ?? user?.displayName ?? 'Student';
    final myPhoto = userData?['photoUrl'] ?? '';
    final myUid = user?.uid ?? 'guest';

    await _firestore.collection('posts').doc(postId).collection('comments').add({
      'authorName': myName,
      'authorUid': myUid,
      'authorPhoto': myPhoto,
      'text': commentText,
      'replyToCommentId': replyToCommentId,
      'replyToAuthorName': replyToAuthorName,
      'likes': <String>[],
      'likesCount': 0,
      'createdAt': FieldValue.serverTimestamp(),
    });

    await _firestore.collection('posts').doc(postId).update({
      'commentsCount': FieldValue.increment(1),
    });

    // إشعار صاحب المنشور أو من تم الرد عليه ومكافأة صاحب التعليق بنقاط الرد الدائمة
    if (replyToCommentId != null && replyToCommentId.isNotEmpty) {
      try {
        final parentCommentDoc = await _firestore
            .collection('posts')
            .doc(postId)
            .collection('comments')
            .doc(replyToCommentId)
            .get();
        final parentAuthorUid = parentCommentDoc.data()?['authorUid'] as String?;
        // إذا كان هناك صاحب للتعليق الأصلي وليس هو نفس الشخص الذي يرد، نكافئه بـ +2 نقطة دائمة
        if (parentAuthorUid != null &&
            parentAuthorUid.isNotEmpty &&
            parentAuthorUid != myUid) {
          await _firestore.collection('users').doc(parentAuthorUid).update({
            'earnedReplyPoints': FieldValue.increment(2),
          });
        }
      } catch (_) {}
    }

    if (postAuthorUid.isNotEmpty && postAuthorUid != myUid) {
      await _notificationRepo.createNotification(
        targetUid: postAuthorUid,
        title: replyToAuthorName != null
            ? '$myName replied to a comment on your post'
            : '$myName commented on your post',
        subtitle: commentText.length > 30 ? '${commentText.substring(0, 30)}...' : commentText,
        type: 'comment',
        relatedId: postId,
      );
    }
  }

  // التفاعل بالإعجاب على تعليق
  Future<void> toggleCommentLike({
    required String postId,
    required String commentId,
    required List<String> likes,
    required String commentAuthorUid,
    required String commentText,
  }) async {
    final user = _auth.currentUser;
    final uid = user?.uid ?? 'guest_user';
    final myName = user?.displayName ?? 'A student';
    final commentRef = _firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .doc(commentId);

    if (likes.contains(uid)) {
      await commentRef.update({
        'likes': FieldValue.arrayRemove([uid]),
        'likesCount': FieldValue.increment(-1),
      });
    } else {
      await commentRef.update({
        'likes': FieldValue.arrayUnion([uid]),
        'likesCount': FieldValue.increment(1),
      });

      if (commentAuthorUid.isNotEmpty && commentAuthorUid != uid) {
        await _notificationRepo.createNotification(
          targetUid: commentAuthorUid,
          title: '$myName liked your comment',
          subtitle: commentText.length > 30 ? '${commentText.substring(0, 30)}...' : commentText,
          type: 'like',
          relatedId: postId,
        );
      }
    }
  }
}
