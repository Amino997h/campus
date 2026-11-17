import 'package:cloud_firestore/cloud_firestore.dart';
import '../../profile/models/user_model.dart';
import '../../posts/models/post_model.dart';

class SearchRepository {
  final FirebaseFirestore _firestore;

  SearchRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // استعلام تدفق الطلاب وفلترتهم بالاسم أو اسم المستخدم أو التخصص
  Stream<List<UserModel>> searchStudents(String query) {
    final cleanQuery = query.trim().toLowerCase();
    return _firestore.collection('users').snapshots().map((snapshot) {
      if (cleanQuery.isEmpty) return <UserModel>[];
      return snapshot.docs
          .map((doc) => UserModel.fromFirestore(doc))
          .where((user) {
            final name = user.name.toLowerCase();
            final username = user.username.toLowerCase();
            final major = user.major.toLowerCase();
            return name.contains(cleanQuery) ||
                username.contains(cleanQuery) ||
                major.contains(cleanQuery);
          })
          .toList();
    });
  }

  // استعلام تدفق المنشورات وفلترتها بالنص أو اسم الكاتب
  Stream<List<PostModel>> searchPosts(String query) {
    final cleanQuery = query.trim().toLowerCase();
    return _firestore
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      if (cleanQuery.isEmpty) return <PostModel>[];
      return snapshot.docs
          .map((doc) => PostModel.fromFirestore(doc))
          .where((post) {
            final content = post.content.toLowerCase();
            final author = post.authorName.toLowerCase();
            return content.contains(cleanQuery) || author.contains(cleanQuery);
          })
          .toList();
    });
  }
}
