import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;

  AuthRepository({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    GoogleSignIn? googleSignIn,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _googleSignIn = googleSignIn ??
            GoogleSignIn(
              clientId: kIsWeb
                  ? '256171839420-0lu8lllcla515lgeuhpmo8tsljf9mc8u.apps.googleusercontent.com'
                  : null,
            );

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // تسجيل حساب جديد وحفظ بيانات الطالب في Firestore
  Future<String?> signUp({
    required String email,
    required String password,
    required String name,
    required String username,
    required String major,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      final user = credential.user;
      if (user != null) {
        await user.updateDisplayName(name);
        final cleanUsername = username.trim().replaceAll('@', '');
        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'name': name,
          'username': cleanUsername,
          'username_lower': cleanUsername.toLowerCase(),
          'email': email.trim(),
          'major': major,
          'bio': 'Campus student',
          'photoUrl': '',
          'createdAt': FieldValue.serverTimestamp(),
          'postsCount': 0,
          'followersCount': 0,
          'followingCount': 0,
          'followers': <String>[],
          'following': <String>[],
          'isOnline': true,
          'showOnlineStatus': true,
        });
      }
      return null; // نجاح
    } on FirebaseAuthException catch (e) {
      return e.message ?? 'Sign up failed';
    } catch (e) {
      return e.toString();
    }
  }

  // تسجيل الدخول
  Future<String?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      return null; // نجاح
    } on FirebaseAuthException catch (e) {
      return e.message ?? 'Sign in failed';
    } catch (e) {
      return e.toString();
    }
  }

  // استرجاع كلمة المرور
  Future<String?> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message ?? 'Reset password failed';
    } catch (e) {
      return e.toString();
    }
  }

  // تسجيل الدخول أو إنشاء حساب عبر Google
  Future<String?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return 'Sign in cancelled'; // المستخدم ألغى النافذة
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        final userDocRef = _firestore.collection('users').doc(user.uid);
        final doc = await userDocRef.get();

        // إذا كان مستخدماً جديداً، نحفظ بياناته التلقائية في Firestore
        if (!doc.exists) {
          final displayName = user.displayName ?? 'Campus Student';
          final emailPrefix = (user.email ?? 'student').split('@').first;
          final cleanUsername = emailPrefix.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '');

          await userDocRef.set({
            'uid': user.uid,
            'name': displayName,
            'username': cleanUsername.isNotEmpty ? cleanUsername : 'student_${user.uid.substring(0, 5)}',
            'username_lower': cleanUsername.toLowerCase(),
            'email': user.email ?? '',
            'major': 'CS',
            'bio': 'Campus student',
            'photoUrl': user.photoURL ?? '',
            'createdAt': FieldValue.serverTimestamp(),
            'postsCount': 0,
            'followersCount': 0,
            'followingCount': 0,
            'followers': <String>[],
            'following': <String>[],
            'isOnline': true,
            'showOnlineStatus': true,
            'verificationLevel': 1,
            'verificationRole': 'student',
            'academicEmail': '',
            'verificationDocUrl': '',
            'verificationStatus': 'none',
            'earnedReplyPoints': 0,
          });
        }
      }

      return null; // نجاح
    } on FirebaseAuthException catch (e) {
      return e.message ?? 'Google sign in failed';
    } catch (e) {
      return e.toString();
    }
  }

  // تسجيل الخروج
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
    await _auth.signOut();
  }
}
