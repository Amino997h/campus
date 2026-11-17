import 'dart:convert';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

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

  Widget _buildAvatarImage(String url) {
    if (url.startsWith('data:image')) {
      try {
        final base64String = url.split(',').last;
        final bytes = base64Decode(base64String);
        return Image.memory(
          bytes,
          width: radius * 2,
          height: radius * 2,
          fit: BoxFit.cover,
          gaplessPlayback: true,
          errorBuilder: (context, error, stackTrace) => Icon(
            defaultIcon,
            size: radius * 1.15,
            color: AppColors.navy,
          ),
        );
      } catch (_) {
        return Icon(
          defaultIcon,
          size: radius * 1.15,
          color: AppColors.navy,
        );
      }
    }

    return Image.network(
      url,
      width: radius * 2,
      height: radius * 2,
      fit: BoxFit.cover,
      gaplessPlayback: true,
      errorBuilder: (context, error, stackTrace) => Icon(
        defaultIcon,
        size: radius * 1.15,
        color: AppColors.navy,
      ),
    );
  }

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
            child: _buildAvatarImage(photoUrl!),
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
