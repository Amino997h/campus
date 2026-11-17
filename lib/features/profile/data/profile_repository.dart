import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../models/project_model.dart';
import '../../posts/models/post_model.dart';
import '../../notifications/data/notification_repository.dart';

class ProfileRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final NotificationRepository _notificationRepo;

  ProfileRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    NotificationRepository? notificationRepo,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        _notificationRepo = notificationRepo ?? NotificationRepository();

  // جلب تدفق بيانات الملف الشخصي
  Stream<UserModel?> getUserProfileStream(String uid) {
    if (uid.isEmpty) return Stream.value(null);
    return _firestore.collection('users').doc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      return UserModel.fromFirestore(doc);
    });
  }

  // جلب بيانات الحساب لمرة واحدة
  Future<UserModel?> getUserProfile(String uid) async {
    if (uid.isEmpty) return null;
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromFirestore(doc);
  }

  // جلب تدفق منشورات مستخدم معين
  Stream<List<PostModel>> getUserPostsStream(String uid) {
    return _firestore
        .collection('posts')
        .where('authorUid', isEqualTo: uid)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PostModel.fromFirestore(doc))
            .toList());
  }

  // تحديث بيانات الملف الشخصي
  Future<void> updateProfile({
    required String name,
    required String username,
    required String major,
    required String bio,
    String? photoUrl,
  }) async {
    final user = _auth.currentUser;
    if (user != null) {
      await user.updateDisplayName(name);
      final cleanUsername = username.trim().replaceAll('@', '');
      final updateData = <String, dynamic>{
        'name': name,
        'username': cleanUsername,
        'username_lower': cleanUsername.toLowerCase(),
        'major': major,
        'bio': bio,
      };
      if (photoUrl != null) {
        updateData['photoUrl'] = photoUrl;
      }
      await _firestore
          .collection('users')
          .doc(user.uid)
          .set(updateData, SetOptions(merge: true));
    }
  }

  // التحقق من توفر اسم المستخدم الفريد
  Future<bool> isUsernameAvailable(String username, {String? excludeUid}) async {
    final cleanUsername = username.trim().replaceAll('@', '').toLowerCase();
    if (cleanUsername.isEmpty) return false;

    final query = await _firestore
        .collection('users')
        .where('username_lower', isEqualTo: cleanUsername)
        .get();

    final queryNormal = await _firestore
        .collection('users')
        .where('username', isEqualTo: cleanUsername)
        .get();

    final allDocs = {...query.docs, ...queryNormal.docs}.toList();

    if (allDocs.isEmpty) return true;
    if (excludeUid != null && allDocs.every((d) => d.id == excludeUid)) {
      return true;
    }
    return false;
  }

  // تبديل حالة المتابعة (Follow / Unfollow)
  Future<bool> toggleFollow(String targetUid) async {
    final user = _auth.currentUser;
    if (user == null || targetUid.isEmpty || targetUid == user.uid) return false;

    final myRef = _firestore.collection('users').doc(user.uid);
    final targetRef = _firestore.collection('users').doc(targetUid);

    final targetDoc = await targetRef.get();
    final targetData = targetDoc.data();
    final List<String> followers = List<String>.from(targetData?['followers'] ?? []);

    final isFollowing = followers.contains(user.uid);

    if (isFollowing) {
      await targetRef.update({
        'followers': FieldValue.arrayRemove([user.uid]),
        'followersCount': FieldValue.increment(-1),
      });
      await myRef.update({
        'following': FieldValue.arrayRemove([targetUid]),
        'followingCount': FieldValue.increment(-1),
      });
      return false;
    } else {
      await targetRef.update({
        'followers': FieldValue.arrayUnion([user.uid]),
        'followersCount': FieldValue.increment(1),
      });
      await myRef.update({
        'following': FieldValue.arrayUnion([targetUid]),
        'followingCount': FieldValue.increment(1),
      });

      final myName = user.displayName ?? 'A student';
      await _notificationRepo.createNotification(
        targetUid: targetUid,
        title: '$myName started following you',
        subtitle: 'Tap to view their profile',
        type: 'follow',
        relatedId: user.uid,
      );
      return true;
    }
  }

  // جلب تدفق مشاريع مستخدم معين (مشاريع التخرج وروابط GitHub)
  Stream<List<ProjectModel>> getUserProjectsStream(String uid) {
    if (uid.isEmpty) return Stream.value([]);
    return _firestore
        .collection('projects')
        .where('uid', isEqualTo: uid)
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs.map((doc) => ProjectModel.fromFirestore(doc)).toList();
      // ترتيب تنازلي حسب تاريخ الإنشاء
      list.sort((a, b) {
        final aTime = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bTime = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bTime.compareTo(aTime);
      });
      return list;
    });
  }

  // إضافة مشروع جديد
  Future<void> addProject({
    required String uid,
    required String title,
    required String githubUrl,
    String? description,
  }) async {
    await _firestore.collection('projects').add({
      'uid': uid,
      'title': title,
      'githubUrl': githubUrl,
      'description': description ?? '',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // حذف مشروع
  Future<void> deleteProject(String projectId) async {
    await _firestore.collection('projects').doc(projectId).delete();
  }

  // حساب نقاط الكارما الجامعية (Campus Karma Points)
  Stream<int> getUserPointsStream(String uid) {
    return _firestore
        .collection('posts')
        .where('authorUid', isEqualTo: uid)
        .snapshots()
        .map((snapshot) {
      int totalPoints = 0;
      // كل منشور = 3 نقاط
      totalPoints += snapshot.docs.length * 3;

      int totalLikes = 0;
      int totalComments = 0;
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final likes = (data['likes'] as List?)?.length ??
            (data['likesCount'] as int? ?? 0);
        final comments = data['commentsCount'] as int? ?? 0;
        totalLikes += likes;
        totalComments += comments;
      }
      // كل 10 لايكات = نقطة
      totalPoints += (totalLikes ~/ 10);
      // كل تعليق = نقطة
      totalPoints += totalComments;

      return totalPoints;
    });
  }
}
