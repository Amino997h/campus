import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/navigation/transitions.dart';
import '../../../../core/utils/ui_helpers.dart';
import '../../data/profile_repository.dart';
import '../screens/edit_profile_screen.dart';

class ProfileActionBar extends StatelessWidget {
  final bool isMe;
  final bool isFollowing;
  final String uid;
  final String name;
  final ProfileRepository profileRepo;
  final VoidCallback? onFollowChanged;

  const ProfileActionBar({
    super.key,
    required this.isMe,
    required this.isFollowing,
    required this.uid,
    required this.name,
    required this.profileRepo,
    this.onFollowChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (isMe) {
      return ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.fromLTRB(28.0, 10.0, 28.0, 10.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          elevation: 0,
        ),
        onPressed: () {
          Navigator.push(
            context,
            SlidePageTransition(page: const EditProfileScreen()),
          );
        },
        child: const Text(
          'Edit Profile',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
        ),
      );
    }

    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: isFollowing ? const Color(0xFFF3F5F9) : AppColors.primary,
        foregroundColor: isFollowing ? AppColors.navy : Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
          side: BorderSide(
            color: isFollowing ? AppColors.borderLight : AppColors.primary,
          ),
        ),
        elevation: 0,
      ),
      onPressed: () async {
        final nowFollowing = await profileRepo.toggleFollow(uid);
        if (context.mounted) {
          UIHelpers.showSnackBar(
            context,
            nowFollowing ? 'You are now following $name!' : 'Unfollowed $name',
            backgroundColor: AppColors.primary,
          );
          onFollowChanged?.call();
        }
      },
      icon: Icon(
        isFollowing ? Icons.check_rounded : Icons.person_add_rounded,
        size: 18,
      ),
      label: Text(
        isFollowing ? 'Following' : 'Follow',
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
      ),
    );
  }
}
