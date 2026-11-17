import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import 'post_image_widget.dart';

class UserAvatar extends StatelessWidget {
  final String? photoUrl;
  final double radius;
  final IconData defaultIcon;
  final VoidCallback? onTap;

  const UserAvatar({
    super.key,
    this.photoUrl,
    this.radius = 20.0,
    this.defaultIcon = Icons.person_rounded,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget avatarWidget;

    if (photoUrl != null && photoUrl!.trim().isNotEmpty) {
      avatarWidget = CircleAvatar(
        radius: radius,
        backgroundColor: AppColors.avatarBg,
        child: ClipOval(
          child: SizedBox(
            width: radius * 2,
            height: radius * 2,
            child: PostImageWidget(imageSource: photoUrl!),
          ),
        ),
      );
    } else {
      avatarWidget = CircleAvatar(
        radius: radius,
        backgroundColor: AppColors.avatarBg,
        child: Icon(
          defaultIcon,
          size: radius * 1.15,
          color: AppColors.navy,
        ),
      );
    }

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: avatarWidget,
      );
    }

    return avatarWidget;
  }
}
