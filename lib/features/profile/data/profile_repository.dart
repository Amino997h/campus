import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../models/project_model.dart';
import '../models/resume_model.dart';
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

  // جلب منشورات مستخدم معين كـ Future ثابت لمنع إعادة البناء اللحظية
  Future<List<PostModel>> getUserPosts(String uid) async {
    if (uid.isEmpty) return [];
    final snapshot = await _firestore
        .collection('posts')
        .where('authorUid', isEqualTo: uid)
        .get();
    return snapshot.docs.map((doc) => PostModel.fromFirestore(doc)).toList();
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

  // جلب مشاريع مستخدم معين كـ Future ثابت
  Future<List<ProjectModel>> getUserProjects(String uid) async {
    if (uid.isEmpty) return [];
    final snapshot = await _firestore
        .collection('projects')
        .where('uid', isEqualTo: uid)
        .get();
    final list = snapshot.docs.map((doc) => ProjectModel.fromFirestore(doc)).toList();
    list.sort((a, b) {
      final aTime = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bTime = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bTime.compareTo(aTime);
    });
    return list;
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

  // جلب السيرة الذاتية للمستخدم لحظياً
  Stream<ResumeModel?> getResumeStream(String uid) {
    if (uid.isEmpty) return Stream.value(null);
    return _firestore.collection('users').doc(uid).collection('resume').doc('profile').snapshots().map((doc) {
      if (!doc.exists) return null;
      return ResumeModel.fromFirestore(doc);
    });
  }

  // جلب السيرة الذاتية للمستخدم لمرة واحدة
  Future<ResumeModel?> getResume(String uid) async {
    if (uid.isEmpty) return null;
    final doc = await _firestore.collection('users').doc(uid).collection('resume').doc('profile').get();
    if (!doc.exists) return null;
    return ResumeModel.fromFirestore(doc);
  }

  // حفظ أو تحديث السيرة الذاتية
  Future<void> saveResume(ResumeModel resume) async {
    if (resume.uid.isEmpty) return;
    await _firestore
        .collection('users')
        .doc(resume.uid)
        .collection('resume')
        .doc('profile')
        .set(resume.toMap(), SetOptions(merge: true));
  }

  // تحديث إعداد خصوصية عرض السيرة الذاتية (CV)
  Future<void> setShowResume(String uid, bool show) async {
    if (uid.isEmpty) return;
    await _firestore.collection('users').doc(uid).set({
      'showResume': show,
    }, SetOptions(merge: true));
  }

  // حساب نقاط الكارما الجامعية بدقة وتوازن تام وفق القواعد المعتمدة
  Stream<int> getUserPointsStream(String uid) {
    if (uid.isEmpty) return Stream.value(0);

    // ندمج تدفق بيانات المستخدم (للمتابعين والتوثيق والسيرة) مع تدفق المنشورات (للمشاريع واللايكات)
    return _firestore.collection('users').doc(uid).snapshots().asyncMap((userDoc) async {
      int totalPoints = 0;
      final userData = userDoc.data() ?? {};

      // 1. نقاط الموثوقية والتحقق (Trust Levels)
      final level = (userData['verificationLevel'] as num?)?.toInt() ?? 1;
      if (level == 2) {
        totalPoints += 15; // توثيق بريد جامعي
      } else if (level >= 3) {
        totalPoints += 30; // توثيق رسمي بوثيقة سنوية أو أستاذ
      }

      // 2. إظهار السيرة الذاتية للجميع (مشروطة بإظهارها showResume مع وجود محتوى)
      final showResume = userData['showResume'] == true;
      if (showResume) {
        try {
          final resumeDoc = await _firestore.collection('users').doc(uid).collection('resume').doc('data').get();
          if (resumeDoc.exists) {
            totalPoints += 10;
          }
        } catch (_) {}
      }

      // 3. شبكة المتابعين الحقيقيين (2 نقطة لكل متابع - تخصم فوراً عند إلغاء المتابعة)
      final followers = (userData['followers'] as List?) ?? [];
      totalPoints += (followers.length * 2);

      // 4. النقاط الدائمة المكتسبة من ردود الآخرين على تعليقاتك (لا تخصم أبداً لو حذفوا ردهم)
      final earnedReplies = (userData['earnedReplyPoints'] as num?)?.toInt() ?? 0;
      totalPoints += earnedReplies;

      // 5. نقاط المنشورات والمشاريع والتفاعل المباشر (تخصم تلقائياً إذا حذفت منشورك)
      try {
        final postsSnapshot = await _firestore
            .collection('posts')
            .where('authorUid', isEqualTo: uid)
            .get();

        int totalLikes = 0;
        int totalComments = 0;

        for (var doc in postsSnapshot.docs) {
          final pData = doc.data();
          // فحص هل المنشور يحمل مشروع GitHub مرجعي (+6 نقاط) أم منشور عادي (+1 نقطة)
          final hasProject = (pData['projectTitle'] != null && (pData['projectTitle'] as String).isNotEmpty) ||
              (pData['projectGithubUrl'] != null && (pData['projectGithubUrl'] as String).isNotEmpty);

          if (hasProject) {
            totalPoints += 6;
          } else {
            totalPoints += 1;
          }

          final likes = (pData['likes'] as List?)?.length ?? (pData['likesCount'] as int? ?? 0);
          final comments = (pData['commentsCount'] as int? ?? 0);

          totalLikes += likes;
          totalComments += comments;
        }

        // كل تعليق تلقيته على منشورك = +1 نقطة
        totalPoints += totalComments;

        // كل 3 إعجابات = +1 نقطة (تخصم إذا أزالوا الإعجاب)
        totalPoints += (totalLikes ~/ 3);
      } catch (_) {}

      return totalPoints;
    });
  }

  // تقديم طلب التحقق الأكاديمي أو تحديث الحالة
  Future<void> submitVerificationRequest({
    required String uid,
    required int requestedLevel,
    required String role, // 'student' or 'professor'
    String academicEmail = '',
    String documentBase64 = '',
  }) async {
    final batch = _firestore.batch();
    final userRef = _firestore.collection('users').doc(uid);
    final requestRef = _firestore.collection('verification_requests').doc(uid);

    final isEmailOnly = requestedLevel == 2;

    batch.set(
      requestRef,
      {
        'uid': uid,
        'requestedLevel': requestedLevel,
        'role': role,
        'academicEmail': academicEmail,
        'documentUrl': documentBase64,
        'status': isEmailOnly ? 'approved' : 'pending',
        'submittedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );

    batch.update(userRef, {
      if (isEmailOnly) 'verificationLevel': 2,
      'academicEmail': academicEmail,
      if (documentBase64.isNotEmpty) 'verificationDocUrl': documentBase64,
      'verificationStatus': isEmailOnly ? 'approved' : 'pending',
      'verificationRole': role,
    });

    await batch.commit();
  }

  // الموافقة على التحقق فوراً (للتطبيق المباشر)
  Future<void> approveVerification({
    required String uid,
    required int level,
    required String role,
  }) async {
    await _firestore.collection('users').doc(uid).update({
      'verificationLevel': level,
      'verificationRole': role,
      'verificationStatus': 'approved',
      'verificationExpiry': DateTime.now().add(const Duration(days: 365)),
    });
  }
}
