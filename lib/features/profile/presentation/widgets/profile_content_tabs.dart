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
                  'لا توجد منشورات حتى الآن.',
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
              child: OutlinedButton.icon(
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
