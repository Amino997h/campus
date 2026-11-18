import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_colors.dart';

class PostProjectBadgeWidget extends StatelessWidget {
  final String title;
  final String githubUrl;

  const PostProjectBadgeWidget({
    super.key,
    required this.title,
    required this.githubUrl,
  });

  Future<void> _launchUrl(BuildContext context) async {
    final uri = Uri.tryParse(githubUrl);
    if (uri != null) {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تعذر فتح رابط المشروع على GitHub.'),
            backgroundColor: AppColors.primary,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: AppColors.borderLight.withValues(alpha: 0.8),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16.0),
          onTap: () => _launchUrl(context),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
            child: Row(
              children: [
                // GitHub / Code Icon Container
                Container(
                  width: 40.0,
                  height: 40.0,
                  decoration: BoxDecoration(
                    color: AppColors.navy.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.code_rounded,
                      color: AppColors.navy,
                      size: 20.0,
                    ),
                  ),
                ),
                const SizedBox(width: 12.0),
                // Text details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.bold,
                                color: AppColors.navy,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8.0),
                          // Simple minimal pill badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7.0, vertical: 2.0),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(6.0),
                              border: Border.all(
                                color: AppColors.borderLight,
                                width: 1.0,
                              ),
                            ),
                            child: const Text(
                              'Project',
                              style: TextStyle(
                                fontSize: 10.0,
                                color: AppColors.textMuted,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        githubUrl,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: AppColors.textMuted,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8.0),
                // Arrow external icon
                Container(
                  width: 32.0,
                  height: 32.0,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.arrow_outward_rounded,
                      size: 15.0,
                      color: AppColors.navy,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
