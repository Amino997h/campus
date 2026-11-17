import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/navigation/transitions.dart';
import '../../../../core/widgets/user_avatar.dart';
import '../../../presence/data/presence_service.dart';
import '../../../posts/models/post_model.dart';
import '../../models/user_model.dart';
import '../../models/project_model.dart';
import '../../data/profile_repository.dart';
import '../widgets/profile_stats_row.dart';
import '../widgets/profile_action_bar.dart';
import '../widgets/profile_content_tabs.dart';
import '../widgets/followers_count_widget.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  final String? viewUid;

  const ProfileScreen({super.key, this.viewUid});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

// Backward-compatibility alias for lowercase profile
// ignore: camel_case_types
typedef profile = ProfileScreen;

class _ProfileScreenState extends State<ProfileScreen> {
  final ProfileRepository _profileRepo = ProfileRepository();
  final GlobalKey<FollowersCountWidgetState> _followersKey = GlobalKey<FollowersCountWidgetState>();

  UserModel? _user;
  int _followersCount = 0;
  List<PostModel> _userPosts = [];
  List<ProjectModel> _userProjects = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final currentLoggedUser = FirebaseAuth.instance.currentUser;
    final isMe = widget.viewUid == null || widget.viewUid == currentLoggedUser?.uid;
    final uid = isMe ? (currentLoggedUser?.uid ?? 'guest') : widget.viewUid!;

    try {
      final user = await _profileRepo.getUserProfile(uid);
      final posts = await _profileRepo.getUserPosts(uid);
      final projects = await _profileRepo.getUserProjects(uid);

      if (mounted) {
        setState(() {
          _user = user;
          _followersCount = user?.followers.length ?? 0;
          _userPosts = posts;
          _userProjects = projects;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _onRefresh() async {
    await _loadProfileData();
  }

  @override
  Widget build(BuildContext context) {
    final currentLoggedUser = FirebaseAuth.instance.currentUser;
    final isMe = widget.viewUid == null || widget.viewUid == currentLoggedUser?.uid;
    final uid = isMe ? (currentLoggedUser?.uid ?? 'guest') : widget.viewUid!;

    final name = _user?.name.isNotEmpty == true
        ? _user!.name
        : (currentLoggedUser?.displayName ?? 'Campus Student');
    final username = _user?.username.isNotEmpty == true ? _user!.username : 'student';
    final major = _user?.major.isNotEmpty == true ? _user!.major : 'Computer Science';
    final bio = _user?.bio.isNotEmpty == true
        ? _user!.bio
        : 'Illustrations, and graphic elements from the world’s best designers. Want more inspiration? Browse our search results for more great resources.';
    final isFollowing = _user?.isFollowedBy(currentLoggedUser?.uid ?? '') ?? false;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.navy, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_rounded, color: AppColors.navy),
            onPressed: () {
              Navigator.push(
                context,
                SlidePageTransition(page: const SettingsScreen()),
              );
            },
          ),
          const SizedBox(width: 6),
        ],
        title: Text(
          'profile',
          style: GoogleFonts.varelaRound(
            color: AppColors.navy,
            fontSize: 26.0,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Divider(
            height: 1.0,
            thickness: 1.0,
            indent: 8,
            endIndent: 8,
            color: AppColors.borderLight,
          ),
        ),
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        backgroundColor: Colors.white,
        onRefresh: _onRefresh,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
            : ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                children: [
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(
                        top: 20.0,
                        bottom: 8.0,
                      ),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          UserAvatar(
                            photoUrl: _user?.photoUrl,
                            radius: 65.0,
                            defaultIcon: Icons.person_rounded,
                          ),
                          if (PresenceService.computeIsUserOnline(_user?.toMap() ?? {}))
                            Positioned(
                              right: 6,
                              bottom: 6,
                              child: Container(
                                width: 22.0,
                                height: 22.0,
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 3.0,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary.withValues(alpha: 0.5),
                                      blurRadius: 6,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      name,
                      style: const TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      '$major • @$username',
                      style: const TextStyle(
                        fontSize: 12.0,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(40.0, 11.0, 40.0, 20.0),
                    child: Text(
                      bio,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 12.0,
                        height: 1.25,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),

                  // زر المتابعة المعزول ذاتياً بنسبة 100% (بدون عمل setState على شاشة الملف الشخصي)
                  Center(
                    child: ProfileActionBar(
                      isMe: isMe,
                      initialIsFollowing: isFollowing,
                      uid: uid,
                      name: name,
                      profileRepo: _profileRepo,
                      onFollowChanged: (nowFollowing) {
                        // تحديث عنصر العداد المخصص فقط دون إعادة بناء الصورة أو الصفحة
                        _followersKey.currentState?.updateCount(nowFollowing);
                      },
                    ),
                  ),

                  // صف الإحصائيات مع عنصر عداد المتابعين المعزول
                  ProfileStatsRow(
                    followersKey: _followersKey,
                    uid: uid,
                    postsCount: _userPosts.length,
                    initialFollowersCount: _followersCount,
                    profileRepo: _profileRepo,
                  ),

                  // قسم التبويب والمحتوى (المنشورات والمشاريع) المعزول تماماً
                  ProfileContentTabs(
                    uid: uid,
                    isMe: isMe,
                    currentUid: currentLoggedUser?.uid ?? '',
                    posts: _userPosts,
                    projects: _userProjects,
                    profileRepo: _profileRepo,
                    onProjectsUpdated: _loadProfileData,
                  ),
                ],
              ),
      ),
    );
  }
}
