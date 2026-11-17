import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/navigation/transitions.dart';
import '../../../../core/widgets/user_avatar.dart';
import '../../../presence/data/presence_service.dart';
import '../../../posts/models/post_model.dart';
import '../../../posts/presentation/widgets/post_card_widget.dart';
import '../../models/user_model.dart';
import '../../data/profile_repository.dart';
import '../widgets/profile_stats_row.dart';
import '../widgets/profile_action_bar.dart';
import '../widgets/profile_segmented_control.dart';
import '../widgets/project_card_widget.dart';
import '../widgets/add_project_dialog.dart';
import '../../models/project_model.dart';
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
  int _selectedTabIndex = 0; // 0 = Posts (Default), 1 = Projects

  Future<void> _onRefresh() async {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final currentLoggedUser = FirebaseAuth.instance.currentUser;
    final isMe = widget.viewUid == null || widget.viewUid == currentLoggedUser?.uid;
    final uid = isMe ? (currentLoggedUser?.uid ?? 'guest') : widget.viewUid!;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.navy),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: AppColors.navy),
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
        child: StreamBuilder<UserModel?>(
          stream: _profileRepo.getUserProfileStream(uid),
          builder: (context, userSnap) {
            final user = userSnap.data;

            final name = user?.name.isNotEmpty == true
                ? user!.name
                : (currentLoggedUser?.displayName ?? 'Campus Student');
            final username = user?.username.isNotEmpty == true ? user!.username : 'student';
            final major = user?.major.isNotEmpty == true ? user!.major : 'Computer Science';
            final bio = user?.bio.isNotEmpty == true
                ? user!.bio
                : 'Illustrations, and graphic elements from the world’s best designers. Want more inspiration? Browse our search results for more great resources.';
            final isFollowing = user?.isFollowedBy(currentLoggedUser?.uid ?? '') ?? false;

            return StreamBuilder<List<PostModel>>(
              stream: _profileRepo.getUserPostsStream(uid),
              builder: (context, postsSnapshot) {
                final userPosts = postsSnapshot.data ?? [];

                return StreamBuilder<List<ProjectModel>>(
                  stream: _profileRepo.getUserProjectsStream(uid),
                  builder: (context, projectsSnapshot) {
                    final userProjects = projectsSnapshot.data ?? [];

                    return ListView(
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
                                  photoUrl: user?.photoUrl,
                                  radius: 65.0,
                                  defaultIcon: Icons.person_rounded,
                                ),
                                if (PresenceService.computeIsUserOnline(user?.toMap() ?? {}))
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
                        Center(
                          child: ProfileActionBar(
                            isMe: isMe,
                            isFollowing: isFollowing,
                            uid: uid,
                            name: name,
                            profileRepo: _profileRepo,
                          ),
                        ),
                        ProfileStatsRow(
                          uid: uid,
                          postsCount: userPosts.length,
                          followersCount: user?.followers.length ?? 0,
                          profileRepo: _profileRepo,
                        ),

                        // التبديل بين المنشورات والمشاريع
                        ProfileSegmentedControl(
                          selectedIndex: _selectedTabIndex,
                          postsCount: userPosts.length,
                          projectsCount: userProjects.length,
                          onTabChanged: (index) {
                            setState(() {
                              _selectedTabIndex = index;
                            });
                          },
                        ),

                        // محتوى التبويب المختار
                        if (_selectedTabIndex == 0) ...[
                          // المنشورات
                          if (userPosts.isEmpty)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 36.0),
                              child: Center(
                                child: Text(
                                  'لا توجد منشورات حتى الآن.',
                                  style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                                ),
                              ),
                            )
                          else
                            ...userPosts.map(
                              (post) => PostCardWidget(
                                key: ValueKey(post.id),
                                post: post,
                                currentUid: currentLoggedUser?.uid ?? '',
                              ),
                            ),
                        ] else ...[
                          // المشاريع / ريبوهات GitHub
                          if (isMe)
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (ctx) => AddProjectDialog(
                                      uid: uid,
                                      profileRepo: _profileRepo,
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.add_rounded, color: AppColors.primary, size: 20),
                                label: const Text(
                                  'إضافة مشروع / ريبو جديد من GitHub',
                                  style: TextStyle(
                                    color: AppColors.navy,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13.0,
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: AppColors.primary, width: 1.2),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14.0),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                                  backgroundColor: AppColors.primary.withValues(alpha: 0.04),
                                ),
                              ),
                            ),
                          if (userProjects.isEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 24.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.folder_special_outlined,
                                    size: 52.0,
                                    color: AppColors.navy.withValues(alpha: 0.3),
                                  ),
                                  const SizedBox(height: 12.0),
                                  Text(
                                    isMe
                                        ? 'لم تقم بإضافة مشاريع تخرج أو مستودعات بعد.\nشارك مشاريعك البرمجية من GitHub ليراها زملاؤك!'
                                        : 'لم يقم هذا المستخدم بإضافة أي مشاريع تخرج أو مستودعات بعد.',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: AppColors.textMuted,
                                      fontSize: 13.0,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else
                            ...userProjects.map(
                              (proj) => ProjectCardWidget(
                                key: ValueKey(proj.id),
                                project: proj,
                                isOwner: isMe,
                                profileRepo: _profileRepo,
                              ),
                            ),
                        ],
                      ],
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
