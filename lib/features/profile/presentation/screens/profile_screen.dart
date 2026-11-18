import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/navigation/transitions.dart';
import '../../../presence/data/presence_service.dart';
import '../../../posts/models/post_model.dart';
import '../../models/user_model.dart';
import '../../models/project_model.dart';
import '../../data/profile_repository.dart';
import '../widgets/profile_stats_row.dart';
import '../widgets/profile_action_bar.dart';
import '../widgets/profile_content_tabs.dart';
import '../widgets/followers_count_widget.dart';
import '../widgets/profile_verification_avatar.dart';
import '../../models/resume_model.dart';
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
  ResumeModel? _resume;
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
      final resume = await _profileRepo.getResume(uid);

      if (mounted) {
        setState(() {
          _user = user;
          _resume = resume;
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

  void _showVerificationExplanationSheet(BuildContext context, UserModel? user) {
    if (user == null) return;
    final level = user.verificationLevel;
    final role = user.verificationRole;

    String title = 'Level 1 • Standard Account';
    String description =
        'This user registered with standard credentials. Academic affiliation and major are self-reported.';
    String ringDesc = 'Pink Ring (Default)';
    Color badgeColor = AppColors.primary;
    IconData icon = Icons.person_outline_rounded;

    if (level == 2) {
      title = 'Level 2 • Institutional Verified';
      description =
          'Verified via official university/institutional email (${user.academicEmail.isNotEmpty ? user.academicEmail : "academic domain"}).';
      ringDesc = 'Navy Ring';
      badgeColor = AppColors.navy;
      icon = Icons.mark_email_read_rounded;
    } else if (level == 3) {
      if (role == 'professor') {
        title = 'Level 3 • Certified Professor / Faculty';
        description =
            'Formally verified professor or lecturer with official academic credentials and faculty accreditation.';
        ringDesc = 'Academic Gold Ring';
        badgeColor = const Color(0xFFC59B27);
        icon = Icons.military_tech_rounded;
      } else {
        title = 'Level 3 • Formally Enrolled Student';
        description =
            'Highest student trust level. Enrolled in this major with official student certificate or university card for this academic year.';
        ringDesc = 'Emerald Green Ring';
        badgeColor = const Color(0xFF0D9488);
        icon = Icons.verified_user_rounded;
      }
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22.0)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40.0,
                height: 4.0,
                decoration: BoxDecoration(
                  color: AppColors.borderLight,
                  borderRadius: BorderRadius.circular(2.0),
                ),
              ),
              const SizedBox(height: 20.0),
              Container(
                padding: const EdgeInsets.all(14.0),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: badgeColor, size: 32.0),
              ),
              const SizedBox(height: 14.0),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16.5,
                  fontWeight: FontWeight.bold,
                  color: AppColors.navy,
                ),
              ),
              const SizedBox(height: 6.0),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 3.0),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12.0),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Text(
                  'Profile Ring: $ringDesc',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
                    color: badgeColor,
                  ),
                ),
              ),
              const SizedBox(height: 14.0),
              Text(
                description,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13.0,
                  color: AppColors.textMuted,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 20.0),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.surface,
                    foregroundColor: AppColors.navy,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      side: const BorderSide(color: AppColors.borderLight),
                    ),
                  ),
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Close', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        );
      },
    );
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
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.navy, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings_rounded, color: AppColors.navy),
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
            ? Center(child: CircularProgressIndicator(color: AppColors.primary))
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
                      child: ProfileVerificationAvatar(
                        photoUrl: _user?.photoUrl,
                        radius: 65.0,
                        verificationLevel: _user?.verificationLevel ?? 1,
                        verificationRole: _user?.verificationRole ?? 'student',
                        isOnline: PresenceService.computeIsUserOnline(_user?.toMap() ?? {}),
                        onTap: () {
                          _showVerificationExplanationSheet(context, _user);
                        },
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
                      style: TextStyle(
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

                  // زر المتابعة والمراسلة المعزول ذاتياً
                  Center(
                    child: ProfileActionBar(
                      isMe: isMe,
                      initialIsFollowing: isFollowing,
                      uid: uid,
                      name: name,
                      major: major,
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

                  // قسم التبويب والمحتوى (المنشورات والمشاريع والسيرة الذاتية)
                  ProfileContentTabs(
                    uid: uid,
                    isMe: isMe,
                    currentUid: currentLoggedUser?.uid ?? '',
                    userProfile: _user,
                    posts: _userPosts,
                    projects: _userProjects,
                    resume: _resume,
                    profileRepo: _profileRepo,
                    onProjectsUpdated: _loadProfileData,
                    onResumeUpdated: _loadProfileData,
                  ),
                ],
              ),
      ),
    );
  }
}
