import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/navigation/transitions.dart';
import '../../../../core/utils/date_time_utils.dart';
import '../../../../core/utils/ui_helpers.dart';
import '../../../../core/widgets/dynamic_user_avatar.dart';
import '../../../../core/widgets/expandable_text.dart';
import '../../../../core/widgets/post_image_widget.dart';
import '../../models/post_model.dart';
import '../../data/post_repository.dart';
import '../screens/post_details_screen.dart';
import 'post_action_bar.dart';
import 'post_options_dialogs.dart';
import 'post_project_badge_widget.dart';
import 'like_button_widget.dart';
import 'double_tap_heart_overlay.dart';

class PostCardWidget extends StatelessWidget {
  final PostModel post;
  final String currentUid;
  final Function(PostModel post)? onShowOptions;
  final Function(String text)? onShare;
  final VoidCallback? onPostDeleted;

  PostCardWidget({
    super.key,
    required this.post,
    required this.currentUid,
    this.onShowOptions,
    this.onShare,
    this.onPostDeleted,
  });

  final PostRepository _postRepo = PostRepository();
  final GlobalKey<LikeButtonWidgetState> _likeKey = GlobalKey<LikeButtonWidgetState>();

  void _triggerDoubleTapLike() {
    _likeKey.currentState?.triggerLikeFromExternal();
  }

  void _handleShowOptions(BuildContext context) {
    if (onShowOptions != null) {
      onShowOptions!(post);
    } else {
      PostOptionsDialogs.showOptionsBottomSheet(
        context,
        post: post,
        currentUid: currentUid,
        postRepo: _postRepo,
        onPostDeleted: onPostDeleted,
      );
    }
  }

  void _handleShare(BuildContext context, String text) {
    if (onShare != null) {
      onShare!(text);
    } else {
      UIHelpers.showSnackBar(
        context,
        'Post link copied to clipboard!',
        backgroundColor: AppColors.primary,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final timeAgo = DateTimeUtils.timeAgo(post.createdAt);

    return SizedBox(
      width: double.infinity,
      child: Card(
        color: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
        margin: const EdgeInsets.only(bottom: 2.0),
        elevation: 2.0,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Header Row
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  DynamicUserAvatar(
                    uid: post.authorUid,
                    initialPhoto: post.authorPhoto,
                    radius: 20.0,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post.authorName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 1.5),
                        Row(
                          children: [
                            if (post.major.isNotEmpty) ...[
                              Flexible(
                                child: Text(
                                  post.major,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 5.0),
                                child: Text(
                                  '•',
                                  style: TextStyle(
                                    fontSize: 11.0,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ),
                            ],
                            Text(
                              timeAgo,
                              style: const TextStyle(
                                fontSize: 11.0,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    iconSize: 20.0,
                    icon: const Icon(Icons.more_horiz_rounded),
                    color: AppColors.textMuted,
                    onPressed: () => _handleShowOptions(context),
                  ),
                ],
              ),
            ),

            // Post Text
            if (post.hasContent)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14.0),
                child: ExpandableText(
                  text: post.content,
                  trimLength: 160,
                ),
              ),

            // Post Project Reference Badge (مشروع مرجعي من GitHub)
            if (post.hasProjectRef)
              PostProjectBadgeWidget(
                title: post.projectRefTitle!,
                githubUrl: post.projectRefUrl!,
              ),

            // Post Image with completely isolated Double-Tap Heart animation
            if (post.hasImage) ...[
              const SizedBox(height: 10.0),
              DoubleTapHeartOverlay(
                onDoubleTap: _triggerDoubleTapLike,
                child: PostImageWidget(imageSource: post.imageUrl),
              ),
            ],

            const SizedBox(height: 4.0),

            // Action Bar with completely isolated Like Button
            PostActionBar(
              likeKey: _likeKey,
              postId: post.id,
              authorUid: post.authorUid,
              content: post.content,
              likesList: post.likes,
              commentsCount: post.commentsCount,
              currentUid: currentUid,
              onCommentTap: () {
                Navigator.push(
                  context,
                  SlidePageTransition(
                    page: PostDetailsScreen(
                      post: post,
                      postId: post.id,
                      authorName: post.authorName,
                      authorUid: post.authorUid,
                      timeAgo: timeAgo,
                      content: post.content,
                      imageUrl: post.imageUrl,
                      initialLikes: '${_likeKey.currentState?.likesCount ?? post.likesCount}',
                      initialComments: '${post.commentsCount}',
                    ),
                  ),
                );
              },
              onShareTap: () => _handleShare(context, post.content),
              onLikeToggle: (postId, likes, authorUid, snippet) {
                _postRepo.toggleLike(postId, likes, authorUid, snippet);
              },
            ),
          ],
        ),
      ),
    );
  }
}
