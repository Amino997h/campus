import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/dynamic_user_avatar.dart';
import '../../../../core/widgets/post_image_widget.dart';
import '../../models/post_model.dart';
import '../../models/comment_model.dart';
import '../../data/post_repository.dart';
import '../widgets/post_project_badge_widget.dart';
import '../widgets/modern_comment_item_widget.dart';

class PostDetailsScreen extends StatefulWidget {
  final PostModel? post;
  final String? postId;
  final String authorName;
  final String authorUid;
  final String timeAgo;
  final String content;
  final String imageUrl;
  final String initialLikes;
  final String initialComments;

  const PostDetailsScreen({
    super.key,
    this.post,
    this.postId,
    this.authorName = 'Campus Student',
    this.authorUid = '',
    this.timeAgo = 'Recently',
    this.content = '',
    this.imageUrl = '',
    this.initialLikes = '0',
    this.initialComments = '0',
  });

  @override
  State<PostDetailsScreen> createState() => _PostDetailsScreenState();
}

class _PostDetailsScreenState extends State<PostDetailsScreen> {
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _commentFocusNode = FocusNode();
  final PostRepository _postRepo = PostRepository();

  String? _replyToCommentId;
  String? _replyToAuthorName;

  String get effectivePostId => widget.post?.id ?? widget.postId ?? '';
  String get effectiveAuthorUid => widget.post?.authorUid ?? widget.authorUid;
  String get effectiveAuthorName => widget.post?.authorName ?? widget.authorName;
  String get effectiveContent => widget.post?.content ?? widget.content;
  String get effectiveImageUrl => widget.post?.imageUrl ?? widget.imageUrl;
  String get effectiveMajor => widget.post?.major.isNotEmpty == true ? widget.post!.major : 'CS';

  @override
  void dispose() {
    _commentController.dispose();
    _commentFocusNode.dispose();
    super.dispose();
  }

  void _initiateReply({required String commentId, required String authorName}) {
    setState(() {
      _replyToCommentId = commentId;
      _replyToAuthorName = authorName;
    });
    _commentFocusNode.requestFocus();
  }

  void _cancelReply() {
    setState(() {
      _replyToCommentId = null;
      _replyToAuthorName = null;
    });
  }

  /// خوارزمية ترتيب وتنظيم التعليقات والردود هرمياً (Threaded Hierarchy):
  /// تضمن وضع كل رد مباشرة تحت التعليق المستهدف أو سلسلة المحادثة الخاصة به
  List<CommentModel> _organizeThreadedComments(List<CommentModel> rawComments) {
    if (rawComments.isEmpty) return [];

    final commentMap = <String, CommentModel>{};
    for (final c in rawComments) {
      if (c.id.isNotEmpty) {
        commentMap[c.id] = c;
      }
    }

    // التعليقات الجذرية (ليست رداً على أي شيء)
    final rootComments = <CommentModel>[];
    // خريطة الردود المباشرة لكل تعليق
    final directReplies = <String, List<CommentModel>>{};

    for (final c in rawComments) {
      final parentId = c.replyToCommentId;
      if (parentId != null && parentId.isNotEmpty && commentMap.containsKey(parentId)) {
        directReplies.putIfAbsent(parentId, () => []).add(c);
      } else {
        rootComments.add(c);
      }
    }

    // تجميع هرمي عميق (Depth-First) للحفاظ على تسلسل الردود تحت أصحابها
    final result = <CommentModel>[];
    void collectThread(CommentModel node) {
      result.add(node);
      final children = directReplies[node.id];
      if (children != null && children.isNotEmpty) {
        for (final child in children) {
          collectThread(child);
        }
      }
    }

    for (final root in rootComments) {
      collectThread(root);
    }

    // في حال وجود تعليق كان مرسلاً كرد على تعليق محذوف، يضاف في النهاية لضمان عدم ضياعه
    for (final c in rawComments) {
      if (!result.contains(c)) {
        result.add(c);
      }
    }

    return result;
  }

  void _addComment() {
    final text = _commentController.text.trim();
    if (text.isNotEmpty && effectivePostId.isNotEmpty) {
      _postRepo.addComment(
        postId: effectivePostId,
        commentText: text,
        postAuthorUid: effectiveAuthorUid,
        replyToCommentId: _replyToCommentId,
        replyToAuthorName: _replyToAuthorName,
      );
      _commentController.clear();
      _cancelReply();
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.navy, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          'post',
          style: GoogleFonts.varelaRound(
            color: AppColors.navy,
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Divider(
            height: 1.0,
            thickness: 1.0,
            indent: 8,
            endIndent: 8,
            color: AppColors.borderLight,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Author Header
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        DynamicUserAvatar(
                          uid: effectiveAuthorUid,
                          radius: 20.0,
                        ),
                        const SizedBox(width: 8),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 2.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                effectiveAuthorName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textDark,
                                ),
                              ),
                              const SizedBox(height: 1.5),
                              Row(
                                children: [
                                  if (effectiveMajor.isNotEmpty) ...[
                                    Flexible(
                                      child: Text(
                                        effectiveMajor,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 12.0,
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
                                    widget.timeAgo,
                                    style: const TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Post Text
                  if (effectiveContent.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14.0),
                      child: Text(
                        effectiveContent,
                        style: const TextStyle(fontSize: 15.0, height: 1.35, color: AppColors.textDark),
                      ),
                    ),

                  // Post Project Reference Badge
                  if (widget.post != null && widget.post!.hasProjectRef)
                    PostProjectBadgeWidget(
                      title: widget.post!.projectRefTitle!,
                      githubUrl: widget.post!.projectRefUrl!,
                    ),
                  const SizedBox(height: 12.0),

                  // Post Image
                  if (effectiveImageUrl.isNotEmpty) ...[
                    const SizedBox(height: 10.0),
                    PostImageWidget(imageSource: effectiveImageUrl),
                  ],

                  const SizedBox(height: 8.0),
                  const Divider(
                    height: 1.0,
                    thickness: 1.0,
                    color: AppColors.borderLight,
                  ),

                  // Comments section title
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 14.0, 16.0, 8.0),
                    child: Row(
                      children: const [
                        Icon(Icons.forum_outlined, size: 18, color: AppColors.navy),
                        SizedBox(width: 6),
                        Text(
                          'Comments',
                          style: TextStyle(
                            fontSize: 14.0,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Comments List from Firestore Realtime
                  if (effectivePostId.isNotEmpty)
                    StreamBuilder<List<CommentModel>>(
                      stream: _postRepo.getCommentsStream(effectivePostId),
                      builder: (context, snapshot) {
                        final comments = snapshot.data ?? [];

                        if (snapshot.connectionState == ConnectionState.waiting && comments.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 20.0),
                            child: Center(
                              child: CircularProgressIndicator(color: AppColors.primary),
                            ),
                          );
                        }

                        if (comments.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
                            child: Center(
                              child: Text(
                                'No comments yet. Be the first to share your thoughts!',
                                style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                              ),
                            ),
                          );
                        }

                        // تنظيم وترتيب التعليقات هرمياً (Threaded Hierarchy):
                        // التعليق الأب يتبعه جميع الردود المتسلسلة التابعة له زمنياً
                        final orderedComments = _organizeThreadedComments(comments);

                        return ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          itemCount: orderedComments.length,
                          separatorBuilder: (context, index) {
                            final nextComment = orderedComments[index + 1 < orderedComments.length ? index + 1 : index];
                            return Divider(
                              height: 1.0,
                              thickness: 0.6,
                              indent: nextComment.isReply ? 76.0 : 64.0,
                              endIndent: 16.0,
                              color: AppColors.borderLight,
                            );
                          },
                          itemBuilder: (context, index) {
                            final comment = orderedComments[index];
                            return ModernCommentItemWidget(
                              key: ValueKey(comment.id),
                              comment: comment,
                              currentUid: currentUid,
                              postId: effectivePostId,
                              postRepo: _postRepo,
                              onReplyTap: () {
                                _initiateReply(
                                  commentId: comment.id,
                                  authorName: comment.authorName,
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // Bottom Comment Input Field with Reply Bar
          Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(
                  color: AppColors.borderLight,
                  width: 1.0,
                ),
              ),
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_replyToAuthorName != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 6.0),
                      color: AppColors.primaryLight,
                      child: Row(
                        children: [
                          const Icon(Icons.reply_rounded, size: 16, color: AppColors.primary),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Replying to @$_replyToAuthorName',
                              style: const TextStyle(
                                fontSize: 12.0,
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            constraints: const BoxConstraints(),
                            padding: EdgeInsets.zero,
                            icon: const Icon(Icons.close_rounded, size: 18, color: AppColors.primary),
                            onPressed: _cancelReply,
                          ),
                        ],
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _commentController,
                            focusNode: _commentFocusNode,
                            decoration: InputDecoration(
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                              hintText: _replyToAuthorName != null ? 'Write a reply...' : 'Add a thoughtful comment...',
                              hintStyle: const TextStyle(fontSize: 13.0, color: AppColors.textMuted),
                              filled: true,
                              fillColor: const Color(0xFFF6F8FA),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(24.0),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.send_rounded, color: AppColors.primary),
                          onPressed: _addComment,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
