import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String username;
  final String usernameLower;
  final String email;
  final String major;
  final String bio;
  final String photoUrl;
  final DateTime? createdAt;
  final int postsCount;
  final int followersCount;
  final int followingCount;
  final List<String> followers;
  final List<String> following;
  final bool isOnline;
  final bool showOnlineStatus;
  final bool showResume;
  final DateTime? lastSeen;

  const UserModel({
    required this.uid,
    this.name = 'Campus Student',
    this.username = '',
    this.usernameLower = '',
    this.email = '',
    this.major = 'CS',
    this.bio = 'Campus student',
    this.photoUrl = '',
    this.createdAt,
    this.postsCount = 0,
    this.followersCount = 0,
    this.followingCount = 0,
    this.followers = const [],
    this.following = const [],
    this.isOnline = false,
    this.showOnlineStatus = true,
    this.showResume = false,
    this.lastSeen,
  });

  bool isFollowing(String targetUid) => following.contains(targetUid);
  bool isFollowedBy(String targetUid) => followers.contains(targetUid);
  String get displayHandle => username.isNotEmpty ? '@$username' : '';

  factory UserModel.fromMap(Map<String, dynamic> data, {String? id}) {
    DateTime? parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is DateTime) return val;
      if (val is int) return DateTime.fromMillisecondsSinceEpoch(val);
      return null;
    }

    return UserModel(
      uid: id ?? data['uid'] ?? '',
      name: data['name'] ?? 'Campus Student',
      username: data['username'] ?? '',
      usernameLower: data['username_lower'] ?? '',
      email: data['email'] ?? '',
      major: data['major'] ?? 'CS',
      bio: data['bio'] ?? 'Campus student',
      photoUrl: data['photoUrl'] ?? '',
      createdAt: parseDate(data['createdAt']),
      postsCount: (data['postsCount'] as num?)?.toInt() ?? 0,
      followersCount: (data['followersCount'] as num?)?.toInt() ?? 0,
      followingCount: (data['followingCount'] as num?)?.toInt() ?? 0,
      followers: List<String>.from(data['followers'] ?? []),
      following: List<String>.from(data['following'] ?? []),
      isOnline: data['isOnline'] == true,
      showOnlineStatus: data['showOnlineStatus'] ?? true,
      showResume: data['showResume'] ?? false,
      lastSeen: parseDate(data['lastSeen']),
    );
  }

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = (doc.data() as Map<String, dynamic>?) ?? {};
    return UserModel.fromMap(data, id: doc.id);
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'username': username,
      'username_lower': usernameLower.isNotEmpty ? usernameLower : username.toLowerCase(),
      'email': email,
      'major': major,
      'bio': bio,
      'photoUrl': photoUrl,
      'postsCount': postsCount,
      'followersCount': followersCount,
      'followingCount': followingCount,
      'followers': followers,
      'following': following,
      'isOnline': isOnline,
      'showOnlineStatus': showOnlineStatus,
      'showResume': showResume,
      if (createdAt != null) 'createdAt': Timestamp.fromDate(createdAt!),
      if (lastSeen != null) 'lastSeen': Timestamp.fromDate(lastSeen!),
    };
  }

  UserModel copyWith({
    String? uid,
    String? name,
    String? username,
    String? usernameLower,
    String? email,
    String? major,
    String? bio,
    String? photoUrl,
    DateTime? createdAt,
    int? postsCount,
    int? followersCount,
    int? followingCount,
    List<String>? followers,
    List<String>? following,
    bool? isOnline,
    bool? showOnlineStatus,
    bool? showResume,
    DateTime? lastSeen,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      username: username ?? this.username,
      usernameLower: usernameLower ?? this.usernameLower,
      email: email ?? this.email,
      major: major ?? this.major,
      bio: bio ?? this.bio,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      postsCount: postsCount ?? this.postsCount,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
      followers: followers ?? this.followers,
      following: following ?? this.following,
      isOnline: isOnline ?? this.isOnline,
      showOnlineStatus: showOnlineStatus ?? this.showOnlineStatus,
      showResume: showResume ?? this.showResume,
      lastSeen: lastSeen ?? this.lastSeen,
    );
  }
}
