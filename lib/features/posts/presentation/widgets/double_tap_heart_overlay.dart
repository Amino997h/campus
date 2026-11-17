import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class DoubleTapHeartOverlay extends StatefulWidget {
  final Widget child;
  final VoidCallback onDoubleTap;

  const DoubleTapHeartOverlay({
    super.key,
    required this.child,
    required this.onDoubleTap,
  });

  @override
  State<DoubleTapHeartOverlay> createState() => _DoubleTapHeartOverlayState();
}

class _DoubleTapHeartOverlayState extends State<DoubleTapHeartOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.2, end: 1.25).chain(CurveTween(curve: Curves.elasticOut)),
        weight: 60,
      ),
      TweenSequenceItem(tween: Tween(begin: 1.25, end: 0.95), weight: 40),
    ]).animate(_animController);

    _opacityAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 30),
    ]).animate(_animController);

    _animController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (mounted) setState(() => _isAnimating = false);
      }
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _handleDoubleTap() {
    widget.onDoubleTap();
    if (mounted) {
      setState(() => _isAnimating = true);
      _animController.forward(from: 0.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTap: _handleDoubleTap,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Child widget (e.g. PostImageWidget) - remains completely untouched during rebuilds
          widget.child,

          // Isolated animating heart layer
          if (_isAnimating)
            IgnorePointer(
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: FadeTransition(
                  opacity: _opacityAnimation,
                  child: Icon(
                    Icons.favorite_rounded,
                    color: AppColors.primary,
                    size: 100,
                    shadows: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.5),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
