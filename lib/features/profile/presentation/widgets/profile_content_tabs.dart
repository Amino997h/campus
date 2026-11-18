import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../posts/models/post_model.dart';
import '../../../posts/presentation/widgets/post_card_widget.dart';
import '../../models/project_model.dart';
import '../../data/profile_repository.dart';
import 'profile_segmented_control.dart';
import 'project_card_widget.dart';
import 'add_project_dialog.dart';

class ProfileContentTabs extends StatefulWidget {
  final String uid;
  final bool isMe;
  final String currentUid;
  final List<PostModel> posts;
  final List<ProjectModel> projects;
  final ProfileRepository profileRepo;
  final VoidCallback? onProjectsUpdated;

  const ProfileContentTabs({
    super.key,
    required this.uid,
    required this.isMe,
    required this.currentUid,
    required this.posts,
    required this.projects,
    required this.profileRepo,
    this.onProjectsUpdated,
  });

  @override
  State<ProfileContentTabs> createState() => _ProfileContentTabsState();
}

class _ProfileContentTabsState extends State<ProfileContentTabs> {
  int _selectedTabIndex = 0; // 0 = Posts, 1 = Projects

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        // شريط التبديل بين المنشورات والمشاريع
        ProfileSegmentedControl(
          selectedIndex: _selectedTabIndex,
          postsCount: widget.posts.length,
          projectsCount: widget.projects.length,
          onTabChanged: (index) {
            setState(() {
              _selectedTabIndex = index;
            });
          },
        ),

        // تبويب المنشورات (معزول تماماً عن التعديلات العلوية للملف الشخصي)
        if (_selectedTabIndex == 0) ...[
          if (widget.posts.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 36.0),
              child: Center(
                child: Text(
                  'No posts yet.',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                ),
              ),
            )
          else
            ...widget.posts.map(
              (post) => PostCardWidget(
                key: ValueKey(post.id),
                post: post,
                currentUid: widget.currentUid,
              ),
            ),
        ] else ...[
          // تبويب المشاريع
          if (widget.isMe)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: ElevatedButton.icon(
                onPressed: () async {
                  await showDialog(
                    context: context,
                    builder: (ctx) => AddProjectDialog(
                      uid: widget.uid,
                      profileRepo: widget.profileRepo,
                    ),
                  );
                  widget.onProjectsUpdated?.call();
                },
                icon: const Icon(Icons.add_rounded, color: Colors.white, size: 18),
                label: const Text(
                  'Add New Project / GitHub Repo',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13.0,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                ),
              ),
            ),
          if (widget.projects.isEmpty)
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
                    widget.isMe
                        ? 'No projects or repositories added yet.\nShowcase your GitHub projects to classmates!'
                        : 'No projects or repositories added yet.',
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
            ...widget.projects.map(
              (proj) => ProjectCardWidget(
                key: ValueKey(proj.id),
                project: proj,
                isOwner: widget.isMe,
                profileRepo: widget.profileRepo,
              ),
            ),
        ],
      ],
    );
  }
}
