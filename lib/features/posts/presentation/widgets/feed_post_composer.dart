import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/navigation/transitions.dart';
import '../../../../core/widgets/dynamic_user_avatar.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import '../screens/create_post_screen.dart';

class FeedPostComposer extends StatelessWidget {
  final String currentUid;
  final VoidCallback? onPostCreated;

  const FeedPostComposer({
    super.key,
    required this.currentUid,
    this.onPostCreated,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 10.0,
        left: 10.0,
        right: 10.0,
        bottom: 14.0,
      ),
      child: Row(
        children: [
          DynamicUserAvatar(
            uid: currentUid,
            radius: 20.0,
            onTap: () {
              Navigator.push(
                context,
                SlidePageTransition(page: const ProfileScreen()),
              );
            },
          ),
          const SizedBox(width: 10.0),
          Flexible(
            fit: FlexFit.tight,
            child: TextField(
              readOnly: true,
              onTap: () async {
                await Navigator.push(
                  context,
                  SlidePageTransition(page: const CreatePostScreen()),
                );
                onPostCreated?.call();
              },
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14.0,
                  vertical: 11.0,
                ),
                hintText: "what's on your mind?",
                hintStyle: const TextStyle(color: AppColors.textMuted),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  borderSide: const BorderSide(
                    color: AppColors.borderLight,
                    width: 1.0,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  borderSide: const BorderSide(
                    color: Color(0xFFD0D7E2),
                    width: 1.0,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 4.0),
          IconButton(
            iconSize: 28.0,
            icon: const Icon(Icons.add_photo_alternate_rounded),
            color: AppColors.primary,
            onPressed: () {
              Navigator.push(
                context,
                SlidePageTransition(page: const CreatePostScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}
