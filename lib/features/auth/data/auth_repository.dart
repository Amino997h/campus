import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthRepository({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

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

  // تسجيل الخروج
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
