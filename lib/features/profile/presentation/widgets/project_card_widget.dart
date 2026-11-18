import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_colors.dart';
import '../../models/project_model.dart';
import '../../data/profile_repository.dart';

class ProjectCardWidget extends StatelessWidget {
  final ProjectModel project;
  final bool isOwner;
  final ProfileRepository profileRepo;

  const ProjectCardWidget({
    super.key,
    required this.project,
    required this.isOwner,
    required this.profileRepo,
  });

  Future<void> _launchUrl(BuildContext context) async {
    final uri = Uri.tryParse(project.githubUrl);
    if (uri != null) {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open link. Please verify URL.'),
            backgroundColor: AppColors.primary,
          ),
        );
      }
    }
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Delete Project', style: TextStyle(color: AppColors.navy, fontWeight: FontWeight.bold)),
        content: const Text('Are you sure you want to remove this project from your list?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await profileRepo.deleteProject(project.id);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16.0),
          onTap: () => _launchUrl(context),
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(10.0),
                        border: Border.all(color: AppColors.borderLight, width: 0.8),
                      ),
                      child: Icon(
                        Icons.code_rounded,
                        color: AppColors.navy,
                        size: 20.0,
                      ),
                    ),
                    const SizedBox(width: 10.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            project.title,
                            style: TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.bold,
                              color: AppColors.navy,
                            ),
                          ),
                          const SizedBox(height: 3.0),
                          Row(
                            children: [
                              const Icon(
                                Icons.link_rounded,
                                size: 13.0,
                                color: AppColors.textMuted,
                              ),
                              const SizedBox(width: 4.0),
                              Expanded(
                                child: Text(
                                  project.githubUrl,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 11.5,
                                    color: AppColors.textMuted,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (isOwner)
                      IconButton(
                        icon: const Icon(Icons.delete_outline_rounded, color: AppColors.textMuted, size: 19.0),
                        onPressed: () => _confirmDelete(context),
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                  ],
                ),
                if (project.description != null && project.description!.trim().isNotEmpty) ...[
                  const SizedBox(height: 8.0),
                  Text(
                    project.description!.trim(),
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: AppColors.textDark,
                      height: 1.35,
                    ),
                  ),
                ],
                const SizedBox(height: 10.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        foregroundColor: AppColors.primary,
                      ),
                      onPressed: () => _launchUrl(context),
                      icon: Text(
                        'Open on GitHub',
                        style: TextStyle(
                          fontSize: 11.5,
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      label: Icon(
                        Icons.arrow_outward_rounded,
                        size: 13.0,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
