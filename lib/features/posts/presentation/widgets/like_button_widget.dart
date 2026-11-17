import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class LikeButtonWidget extends StatefulWidget {
  final String postId;
  final String authorUid;
  final String contentSnippet;
  final List<String> initialLikes;
  final String currentUid;
  final Function(String postId, List<String> likes, String authorUid, String snippet) onToggle;

  const LikeButtonWidget({
    super.key,
    required this.postId,
    required this.authorUid,
    required this.contentSnippet,
    required this.initialLikes,
    required this.currentUid,
    required this.onToggle,
  });

  @override
  State<LikeButtonWidget> createState() => LikeButtonWidgetState();
}

class LikeButtonWidgetState extends State<LikeButtonWidget> with SingleTickerProviderStateMixin {
  late bool _isLiked;
  late int _likesCount;
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;

  bool get isLiked => _isLiked;
  int get likesCount => _likesCount;

  @override
  void initState() {
    super.initState();
    _isLiked = widget.initialLikes.contains(widget.currentUid);
    _likesCount = widget.initialLikes.length;

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.35), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.35, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _animController, curve: Curves.easeInOut));
  }

  @override
  void didUpdateWidget(covariant LikeButtonWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // تحديث فقط إذا كان هناك تغيير حقيقي من السيرفر
    final serverLiked = widget.initialLikes.contains(widget.currentUid);
    if (serverLiked != _isLiked || widget.initialLikes.length != _likesCount) {
      _isLiked = serverLiked;
      _likesCount = widget.initialLikes.length;
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  /// تنفيذ اللايك عند النقر المزدوج على الصورة دون عمل setState على الكرت بالكامل
  void triggerLikeFromExternal() {
    if (!_isLiked) {
      setState(() {
        _isLiked = true;
        _likesCount += 1;
        _animController.forward(from: 0.0);
      });

      widget.onToggle(
        widget.postId,
        widget.initialLikes,
        widget.authorUid,
        widget.contentSnippet,
      );
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
        _animController.forward(from: 0.0);
      }
    });

    widget.onToggle(
      widget.postId,
      widget.initialLikes,
      widget.authorUid,
      widget.contentSnippet,
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: _handleTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ScaleTransition(
              scale: _scaleAnimation,
              child: Icon(
                _isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                size: 22.0,
                color: _isLiked ? AppColors.primary : AppColors.navy,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '$_likesCount',
              style: TextStyle(
                fontSize: 13.0,
                color: _isLiked ? AppColors.primary : AppColors.textDark,
                fontWeight: _isLiked ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
