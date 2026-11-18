import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/date_time_utils.dart';
import '../../../../core/widgets/dynamic_user_avatar.dart';
import '../../models/comment_model.dart';
import '../../data/post_repository.dart';
import 'comment_like_button_widget.dart';

class ModernCommentItemWidget extends StatelessWidget {
  final CommentModel comment;
  final String currentUid;
  final String postId;
  final PostRepository postRepo;
  final VoidCallback onReplyTap;

  const ModernCommentItemWidget({
    super.key,
    required this.comment,
    required this.currentUid,
    required this.postId,
    required this.postRepo,
    required this.onReplyTap,
  });

  @override
  Widget build(BuildContext context) {
    final isReply = comment.isReply;
    final timeStr = DateTimeUtils.timeAgo(comment.createdAt);

    return Padding(
      padding: EdgeInsets.only(
        left: isReply ? 46.0 : 16.0,
        right: 16.0,
        top: 8.0,
        bottom: 8.0,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          DynamicUserAvatar(
            uid: comment.authorUid,
            initialPhoto: comment.authorPhoto,
            radius: isReply ? 15.0 : 18.0,
            showOnlineIndicator: false,
          ),
          const SizedBox(width: 12.0),

          // Comment Body & Actions
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Author row + time
                Row(
                  children: [
                    Text(
                      comment.authorName,
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.bold,
                        color: AppColors.navy,
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    Text(
                      timeStr,
                      style: const TextStyle(
                        fontSize: 11.0,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),

                // If Reply indicator tag
                if (isReply) ...[
                  const SizedBox(height: 2.0),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.reply_rounded,
                        size: 13.0,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 3.0),
                      Text(
                        'رد على @${comment.replyToAuthorName}',
                        style: TextStyle(
                          fontSize: 11.0,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 4.0),

                // Comment Text - clean typography
                Text(
                  comment.text,
                  style: const TextStyle(
                    fontSize: 13.5,
                    height: 1.38,
                    color: AppColors.textDark,
                  ),
                ),

                const SizedBox(height: 6.0),

                // Sub-Actions: Reply text button + Like comment
                Row(
                  children: [
                    InkWell(
                      borderRadius: BorderRadius.circular(8.0),
                      onTap: onReplyTap,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4.0, vertical: 3.0),
                        child: Text(
                          'Reply',
                          style: TextStyle(
                            fontSize: 12.0,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14.0),
                    CommentLikeButtonWidget(
                      postId: postId,
                      commentId: comment.id,
                      commentAuthorUid: comment.authorUid,
                      commentText: comment.text,
                      initialLikes: comment.likes,
                      currentUid: currentUid,
                      postRepo: postRepo,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
