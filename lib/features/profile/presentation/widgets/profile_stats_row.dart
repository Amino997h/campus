import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/profile_repository.dart';
import 'followers_count_widget.dart';

class ProfileStatsRow extends StatelessWidget {
  final GlobalKey<FollowersCountWidgetState>? followersKey;
  final String uid;
  final int postsCount;
  final int initialFollowersCount;
  final ProfileRepository profileRepo;

  const ProfileStatsRow({
    super.key,
    this.followersKey,
    required this.uid,
    required this.postsCount,
    required this.initialFollowersCount,
    required this.profileRepo,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 18.0,
        left: 30.0,
        right: 30.0,
        bottom: 14.0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Posts Count
          Column(
            children: [
              const Text(
                'Posts',
                style: TextStyle(
                  fontSize: 12.0,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '$postsCount',
                style: const TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          Container(
            height: 25.0,
            width: 1.0,
            color: AppColors.borderLight,
          ),

          // Followers Count (عنصر معزول يتغير دون إعادة رسم الشاشة)
          FollowersCountWidget(
            key: followersKey,
            initialCount: initialFollowersCount,
          ),

          Container(
            height: 25.0,
            width: 1.0,
            color: AppColors.borderLight,
          ),

          // Campus Karma Points (محسوبة مسبقاً بناءً على المنشورات دون Stream نشط يهز الشاشة)
          Column(
            children: [
              const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.stars_rounded, size: 14, color: AppColors.primary),
                  SizedBox(width: 3),
                  Text(
                    'Points',
                    style: TextStyle(
                      fontSize: 12.0,
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                '${postsCount * 3}',
                style: const TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
