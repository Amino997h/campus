import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import 'like_button_widget.dart';

class PostActionBar extends StatelessWidget {
  final GlobalKey<LikeButtonWidgetState>? likeKey;
  final String postId;
  final String authorUid;
  final String content;
  final List<String> likesList;
  final int commentsCount;
  final String currentUid;
  final VoidCallback onCommentTap;
  final VoidCallback onShareTap;
  final Function(String, List<String>, String, String) onLikeToggle;

  const PostActionBar({
    super.key,
    this.likeKey,
    required this.postId,
    required this.authorUid,
    required this.content,
    required this.likesList,
    required this.commentsCount,
    required this.currentUid,
    required this.onCommentTap,
    required this.onShareTap,
    required this.onLikeToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 12.0,
        vertical: 4.0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // زر اللايك الأصلي
          LikeButtonWidget(
            key: likeKey,
            postId: postId,
            authorUid: authorUid,
            contentSnippet: content,
            initialLikes: likesList,
            currentUid: currentUid,
            onToggle: onLikeToggle,
          ),

          // زر التعليق الأصلي
          TextButton.icon(
            onPressed: onCommentTap,
            label: Text(
              '$commentsCount',
              style: const TextStyle(color: AppColors.textDark, fontSize: 13.0),
            ),
            icon: const Icon(
              Icons.chat_bubble_outline_rounded,
              size: 21.0,
              color: AppColors.navy,
            ),
          ),

          // زر المشاركة الأصلي
          TextButton.icon(
            onPressed: onShareTap,
            icon: const Icon(
              Icons.share_outlined,
              size: 21.0,
              color: AppColors.navy,
            ),
            label: const Text(
              '',
              style: TextStyle(color: AppColors.textDark),
            ),
          ),
        ],
      ),
    );
  }
}
