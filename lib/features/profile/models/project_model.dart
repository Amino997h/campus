import 'package:cloud_firestore/cloud_firestore.dart';

class ProjectModel {
  final String id;
  final String uid;
  final String title;
  final String githubUrl;
  final String? description;
  final DateTime? createdAt;

  ProjectModel({
    required this.id,
    required this.uid,
    required this.title,
    required this.githubUrl,
    this.description,
    this.createdAt,
  });

  factory ProjectModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return ProjectModel(
      id: doc.id,
      uid: data['uid'] ?? '',
      title: data['title'] ?? '',
      githubUrl: data['githubUrl'] ?? '',
      description: data['description'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'title': title,
      'githubUrl': githubUrl,
      'description': description,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
    };
  }
}
