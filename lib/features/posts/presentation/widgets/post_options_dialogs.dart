import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/ui_helpers.dart';
import '../../models/post_model.dart';
import '../../data/post_repository.dart';

class PostOptionsDialogs {
  static void showOptionsBottomSheet(
    BuildContext context, {
    required PostModel post,
    required String currentUid,
    required PostRepository postRepo,
    VoidCallback? onPostDeleted,
  }) {
    final isOwner = post.isOwner(currentUid);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Wrap(
            children: [
              if (isOwner) ...[
                ListTile(
                  leading: Icon(Icons.edit_outlined, color: AppColors.navy),
                  title: const Text(
                    'Edit Post Text',
                    style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    showEditDialog(context, post: post, postRepo: postRepo);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.delete_outline_rounded, color: AppColors.primary),
                  title: Text(
                    'Delete Post',
                    style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    showDeleteConfirmDialog(
                      context,
                      post: post,
                      postRepo: postRepo,
                      onPostDeleted: onPostDeleted,
                    );
                  },
                ),
              ] else ...[
                ListTile(
                  leading: Icon(Icons.report_outlined, color: AppColors.navy),
                  title: const Text('Report Post', style: TextStyle(color: AppColors.textDark)),
                  onTap: () async {
                    Navigator.pop(ctx);
                    try {
                      await postRepo.reportPost(
                        postId: post.id,
                        postText: post.content,
                        postAuthorUid: post.authorUid,
                        postAuthorName: post.authorName,
                        reportedByUid: currentUid,
                      );
                      if (context.mounted) {
                        UIHelpers.showSnackBar(
                          context,
                          'Post reported to Admin for review.',
                          backgroundColor: AppColors.navy,
                        );
                      }
                    } catch (_) {}
                  },
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  static void showEditDialog(
    BuildContext context, {
    required PostModel post,
    required PostRepository postRepo,
  }) {
    final editController = TextEditingController(text: post.content);
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text(
          'Edit Post',
          style: TextStyle(color: AppColors.navy, fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: editController,
          maxLines: 4,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Update post content...',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              final newText = editController.text.trim();
              if (newText.isNotEmpty && newText != post.content) {
                await postRepo.updatePostText(post.id, newText);
              }
              if (dialogCtx.mounted) Navigator.pop(dialogCtx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  static void showDeleteConfirmDialog(
    BuildContext context, {
    required PostModel post,
    required PostRepository postRepo,
    VoidCallback? onPostDeleted,
  }) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text(
          'Delete Post',
          style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
        ),
        content: const Text('Are you sure you want to delete this post permanently?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              await postRepo.deletePost(post.id);
              if (dialogCtx.mounted) {
                Navigator.pop(dialogCtx);
              }
              if (context.mounted) {
                UIHelpers.showSnackBar(
                  context,
                  'Post deleted successfully',
                  backgroundColor: AppColors.navy,
                );
              }
              onPostDeleted?.call();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
