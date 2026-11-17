import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/post_repository.dart';

class CommentLikeButtonWidget extends StatefulWidget {
  final String postId;
  final String commentId;
  final String commentAuthorUid;
  final String commentText;
  final List<String> initialLikes;
  final String currentUid;
  final PostRepository postRepo;

  const CommentLikeButtonWidget({
    super.key,
    required this.postId,
    required this.commentId,
    required this.commentAuthorUid,
    required this.commentText,
    required this.initialLikes,
    required this.currentUid,
    required this.postRepo,
  });

  @override
  State<CommentLikeButtonWidget> createState() => _CommentLikeButtonWidgetState();
}

class _CommentLikeButtonWidgetState extends State<CommentLikeButtonWidget> {
  late bool _isLiked;
  late int _likesCount;

  @override
  void initState() {
    super.initState();
    _isLiked = widget.initialLikes.contains(widget.currentUid);
    _likesCount = widget.initialLikes.length;
  }

  @override
  void didUpdateWidget(covariant CommentLikeButtonWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    final serverLiked = widget.initialLikes.contains(widget.currentUid);
    if (serverLiked != _isLiked || widget.initialLikes.length != _likesCount) {
      _isLiked = serverLiked;
      _likesCount = widget.initialLikes.length;
    }
  }

  void _handleTap() {
    setState(() {
      if (_isLiked) {
        _isLiked = false;
        _likesCount = (_likesCount > 0) ? _likesCount - 1 : 0;
      } else {
        _isLiked = true;
        _likesCount += 1;
      }
    });

    widget.postRepo.toggleCommentLike(
      postId: widget.postId,
      commentId: widget.commentId,
      likes: widget.initialLikes,
      commentAuthorUid: widget.commentAuthorUid,
      commentText: widget.commentText,
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: _handleTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              size: 15.0,
              color: _isLiked ? AppColors.primary : AppColors.textMuted,
            ),
            if (_likesCount > 0) ...[
              const SizedBox(width: 4),
              Text(
                '$_likesCount',
                style: TextStyle(
                  fontSize: 11.0,
                  fontWeight: _isLiked ? FontWeight.bold : FontWeight.normal,
                  color: _isLiked ? AppColors.primary : AppColors.textMuted,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
