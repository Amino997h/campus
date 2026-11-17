import 'package:flutter/foundation.dart';
import '../models/post_model.dart';
import 'post_repository.dart';

class FeedStateManager extends ChangeNotifier {
  static final FeedStateManager _instance = FeedStateManager._internal();
  factory FeedStateManager() => _instance;
  FeedStateManager._internal();

  final PostRepository _postRepo = PostRepository();

  List<PostModel> _posts = [];
  bool _isLoading = true;
  String? _error;

  List<PostModel> get posts => _posts;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// تحميل المنشورات للمرة الأولى أو عند السحب للتحديث (Pull-to-refresh)
  Future<void> loadPosts({bool isRefresh = false}) async {
    if (!isRefresh && _posts.isNotEmpty) return;

    if (_posts.isEmpty) {
      _isLoading = true;
      notifyListeners();
    }

    try {
      final fetched = await _postRepo.getPostsFuture();
      _posts = fetched;
      _isLoading = false;
      _error = null;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  /// تحديث تفاؤلي محلي للايك مع إرسال الطلب لفايرستور في الخلفية
  /// دون إعادة بناء قائمة المنشورات بالكامل أو تحريك موضع السكرول
  Future<void> toggleLikeOptimistic({
    required String postId,
    required String currentUid,
    required String authorUid,
    required String content,
  }) async {
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index == -1) return;

    final targetPost = _posts[index];
    final currentLikes = List<String>.from(targetPost.likes);
    final isLiked = currentLikes.contains(currentUid);

    if (isLiked) {
      currentLikes.remove(currentUid);
    } else {
      currentLikes.add(currentUid);
    }

    // تحديث فوري محلي في الذاكرة
    _posts[index] = targetPost.copyWith(
      likes: currentLikes,
      likesCount: currentLikes.length,
    );
    notifyListeners();

    // إرسال التحديث لـ Firestore في الخلفية
    try {
      await _postRepo.toggleLike(
        postId,
        targetPost.likes, // القائمة الأصلية ليقرر الريبوزتوري add أو remove
        authorUid,
        content,
      );
    } catch (e) {
      // في حال فشل الطلب بالخلفية، يتم التراجع عن التعديل
      final rollbackIndex = _posts.indexWhere((p) => p.id == postId);
      if (rollbackIndex != -1) {
        _posts[rollbackIndex] = targetPost;
        notifyListeners();
      }
    }
  }

  /// إضافة منشور جديد فور إنشائه ليظهر في قمة القائمة مباشرة
  void prependPost(PostModel newPost) {
    _posts.insert(0, newPost);
    notifyListeners();
  }

  /// حذف منشور محلياً
  void removePost(String postId) {
    _posts.removeWhere((p) => p.id == postId);
    notifyListeners();
  }
}
