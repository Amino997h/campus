import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/app_colors.dart';
import '../navigation/transitions.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/presence/data/presence_service.dart';
import 'user_avatar.dart';

class DynamicUserAvatar extends StatelessWidget {
  final String uid;
  final String? initialPhoto;
  final double radius;
  final VoidCallback? onTap;
  final bool showOnlineIndicator;

  const DynamicUserAvatar({
    super.key,
    required this.uid,
    this.initialPhoto,
    this.radius = 20.0,
    this.onTap,
    this.showOnlineIndicator = true,
  });

  @override
  Widget build(BuildContext context) {
    if (uid.isEmpty || uid == 'guest' || uid == 'guest_user') {
      return UserAvatar(
        photoUrl: initialPhoto,
        radius: radius,
        onTap: onTap,
      );
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
      builder: (context, snapshot) {
        String? photoUrl = initialPhoto;
        bool isOnline = false;

        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>?;
          if (data != null) {
            if (data['photoUrl'] != null && data['photoUrl'].toString().isNotEmpty) {
              photoUrl = data['photoUrl'];
            }
            isOnline = PresenceService.computeIsUserOnline(data);
          }
        }

        final avatarWidget = UserAvatar(
          photoUrl: photoUrl,
          radius: radius,
          onTap: onTap ??
              () {
                Navigator.push(
                  context,
                  SlidePageTransition(page: ProfileScreen(viewUid: uid)),
                );
              },
        );

        if (!showOnlineIndicator || !isOnline) {
          return avatarWidget;
        }

        final dotRadius = (radius * 0.32).clamp(5.0, 8.5);

        return Stack(
          clipBehavior: Clip.none,
          children: [
            avatarWidget,
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: dotRadius * 2,
                height: dotRadius * 2,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 2.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.4),
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

