import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class FollowersCountWidget extends StatefulWidget {
  final int initialCount;

  const FollowersCountWidget({
    super.key,
    required this.initialCount,
  });

  @override
  State<FollowersCountWidget> createState() => FollowersCountWidgetState();
}

class FollowersCountWidgetState extends State<FollowersCountWidget> {
  late int _count;

  @override
  void initState() {
    super.initState();
    _count = widget.initialCount;
  }

  @override
  void didUpdateWidget(covariant FollowersCountWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialCount != widget.initialCount) {
      _count = widget.initialCount;
    }
  }

  void updateCount(bool increment) {
    setState(() {
      _count = (_count + (increment ? 1 : -1)).clamp(0, 99999999);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'Followers',
          style: TextStyle(
            fontSize: 12.0,
            color: AppColors.textMuted,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '$_count',
          style: const TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
      ],
    );
  }
}
