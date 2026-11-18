import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../models/notification_model.dart';

class NotificationTile extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;

  const NotificationTile({
    super.key,
    required this.notification,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final type = notification.type;
    final isUnread = notification.unread;

    final Color bgColor;
    final IconData iconData;
    final Color iconColor;

    if (type == 'like') {
      bgColor = AppColors.primaryLight;
      iconData = Icons.favorite_rounded;
      iconColor = AppColors.primary;
    } else if (type == 'follow') {
      bgColor = const Color(0xFFE8F0FE);
      iconData = Icons.person_add_alt_1_rounded;
      iconColor = const Color(0xFF1A73E8);
    } else if (type == 'post') {
      bgColor = const Color(0xFFE6F4EA);
      iconData = Icons.article_rounded;
      iconColor = const Color(0xFF137333);
    } else {
      bgColor = AppColors.avatarBg;
      iconData = Icons.chat_bubble_rounded;
      iconColor = AppColors.navy;
    }

    return Container(
      color: isUnread ? AppColors.primaryLight.withValues(alpha: 0.4) : Colors.white,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 6.0,
        ),
        leading: CircleAvatar(
          radius: 20,
          backgroundColor: bgColor,
          child: Icon(iconData, size: 19, color: iconColor),
        ),
        title: Text(
          notification.title,
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
            color: AppColors.textDark,
          ),
        ),
        subtitle: notification.subtitle.isNotEmpty
            ? Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  notification.subtitle,
                  style: TextStyle(
                    fontSize: 11.5,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
            : null,
        trailing: isUnread
            ? Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              )
            : null,
        onTap: onTap,
      ),
    );
  }
}
