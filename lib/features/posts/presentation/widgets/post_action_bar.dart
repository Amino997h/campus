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
        horizontal: 4.0,
        vertical: 2.0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // زر اللايك بمساحة نقر مريحة وواسعة
          LikeButtonWidget(
            key: likeKey,
            postId: postId,
            authorUid: authorUid,
            contentSnippet: content,
            initialLikes: likesList,
            currentUid: currentUid,
            onToggle: onLikeToggle,
          ),

          // زر التعليق بمساحة نقر أوسع وأسهل للمس
          InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: onCommentTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.chat_bubble_outline_rounded,
                    size: 21.0,
                    color: AppColors.navy,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '$commentsCount',
                    style: const TextStyle(
                      color: AppColors.textDark,
                      fontSize: 13.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // زر المشاركة بمساحة نقر أوسع للمس
          InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: onShareTap,
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Icon(
                Icons.share_rounded,
                size: 21.0,
                color: AppColors.navy,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
