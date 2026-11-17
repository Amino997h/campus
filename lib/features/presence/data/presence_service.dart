import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PresenceService with WidgetsBindingObserver {
  static final PresenceService _instance = PresenceService._internal();
  factory PresenceService() => _instance;
  PresenceService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Timer? _heartbeatTimer;

  void init() {
    WidgetsBinding.instance.addObserver(this);
    setOnline(true);
    _startHeartbeat();
  }

  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    // تحديث النبض الدوري كل 45 ثانية لتأكيد أن التطبيق متصل ونشط
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 45), (_) {
      if (_auth.currentUser != null) {
        setOnline(true);
      }
    });
  }

  void dispose() {
    _heartbeatTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      setOnline(true);
      _startHeartbeat();
    } else {
      _heartbeatTimer?.cancel();
      setOnline(false);
    }
  }

  Future<void> setOnline(bool isOnline) async {
    final uid = _auth.currentUser?.uid;
    if (uid != null) {
      try {
        await _firestore.collection('users').doc(uid).set({
          'isOnline': isOnline,
          'lastSeen': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      } catch (_) {}
    }
  }

  Future<void> setShowOnlineStatus(bool show) async {
    final uid = _auth.currentUser?.uid;
    if (uid != null) {
      try {
        await _firestore.collection('users').doc(uid).set({
          'showOnlineStatus': show,
        }, SetOptions(merge: true));
      } catch (_) {}
    }
  }

  // فحص ما إذا كان المستخدم يعتبر متصلاً بالفعل (نشط خلال آخر دقيقتين مع حقل isOnline)
  static bool computeIsUserOnline(Map<String, dynamic>? data) {
    if (data == null) return false;
    final canShow = data['showOnlineStatus'] ?? true;
    if (!canShow) return false;
    final isOnline = data['isOnline'] == true;
    if (!isOnline) return false;

    final lastSeen = data['lastSeen'];
    if (lastSeen is Timestamp) {
      final diff = DateTime.now().difference(lastSeen.toDate());
      // إذا انقطع الاتصال أو أُغلق التطبيق فجأة دون إشعار، يعتبر غير متصل بعد دقيقتين
      return diff.inMinutes < 2;
    }
    return isOnline;
  }
}
