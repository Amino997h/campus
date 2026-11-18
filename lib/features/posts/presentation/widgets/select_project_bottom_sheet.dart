import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../profile/models/project_model.dart';
import '../../../profile/data/profile_repository.dart';
import '../../../profile/presentation/widgets/add_project_dialog.dart';

class SelectProjectBottomSheet extends StatelessWidget {
  final ProfileRepository profileRepo;
  final Function(ProjectModel project) onProjectSelected;

  const SelectProjectBottomSheet({
    super.key,
    required this.profileRepo,
    required this.onProjectSelected,
  });

  @override
  Widget build(BuildContext context) {
    final currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
      ),
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 24.0),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.borderLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 14.0),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.code_rounded,
                    color: AppColors.primary,
                    size: 22.0,
                  ),
                ),
                const SizedBox(width: 10.0),
                Expanded(
                  child: Text(
                    'Attach a Project Reference',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      color: AppColors.navy,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    showDialog(
                      context: context,
                      builder: (ctx) => AddProjectDialog(
                        uid: currentUid,
                        profileRepo: profileRepo,
                      ),
                    );
                  },
                  icon: Icon(Icons.add_rounded, size: 16, color: AppColors.primary),
                  label: Text(
                    'New Project',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12.0,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12.0),
            Flexible(
              child: StreamBuilder<List<ProjectModel>>(
                stream: profileRepo.getUserProjectsStream(currentUid),
                builder: (context, snapshot) {
                  final projects = snapshot.data ?? [];

                  if (snapshot.connectionState == ConnectionState.waiting && projects.isEmpty) {
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 24.0),
                      child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
                    );
                  }

                  if (projects.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.folder_open_rounded, size: 44, color: AppColors.textMuted),
                          const SizedBox(height: 8),
                          const Text(
                            'No projects added to your profile yet.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                              showDialog(
                                context: context,
                                builder: (ctx) => AddProjectDialog(
                                  uid: currentUid,
                                  profileRepo: profileRepo,
                                ),
                              );
                            },
                            icon: const Icon(Icons.add_rounded, color: Colors.white, size: 18),
                            label: const Text('Add Project Now', style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    shrinkWrap: true,
                    itemCount: projects.length,
                    separatorBuilder: (_, _) => const Divider(height: 1, color: AppColors.borderLight),
                    itemBuilder: (context, index) {
                      final proj = projects[index];
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                        leading: Container(
                          padding: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            color: AppColors.navy.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Icon(Icons.code_rounded, color: AppColors.navy, size: 20.0),
                        ),
                        title: Text(
                          proj.title,
                          style: const TextStyle(
                            fontSize: 14.0,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                        subtitle: Text(
                          proj.githubUrl,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 12.0, color: AppColors.primary),
                        ),
                        trailing: Icon(Icons.check_circle_outline_rounded, color: AppColors.primary),
                        onTap: () {
                          Navigator.pop(context);
                          onProjectSelected(proj);
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
