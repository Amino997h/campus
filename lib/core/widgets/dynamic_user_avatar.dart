import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/app_colors.dart';
import '../navigation/transitions.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/presence/data/presence_service.dart';
import 'user_avatar.dart';

class DynamicUserAvatar extends StatefulWidget {
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
  State<DynamicUserAvatar> createState() => _DynamicUserAvatarState();
}

class _DynamicUserAvatarState extends State<DynamicUserAvatar> {
  // كاش داخلي لذاكرة الأفاتار لمنع أي وميض عند إعادة اتصال الـ Stream
  static final Map<String, String> _photoCache = {};
  static final Map<String, bool> _onlineCache = {};

  @override
  Widget build(BuildContext context) {
    if (widget.uid.isEmpty || widget.uid == 'guest' || widget.uid == 'guest_user') {
      return UserAvatar(
        photoUrl: widget.initialPhoto,
        radius: widget.radius,
        onTap: widget.onTap,
      );
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(widget.uid).snapshots(),
      builder: (context, snapshot) {
        String? photoUrl = _photoCache[widget.uid] ?? widget.initialPhoto;
        bool isOnline = _onlineCache[widget.uid] ?? false;

        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>?;
          if (data != null) {
            if (data['photoUrl'] != null && data['photoUrl'].toString().isNotEmpty) {
              photoUrl = data['photoUrl'];
              _photoCache[widget.uid] = photoUrl!;
            }
            isOnline = PresenceService.computeIsUserOnline(data);
            _onlineCache[widget.uid] = isOnline;
          }
        }

        final avatarWidget = UserAvatar(
          photoUrl: photoUrl,
          radius: widget.radius,
          onTap: widget.onTap ??
              () {
                Navigator.push(
                  context,
                  SlidePageTransition(page: ProfileScreen(viewUid: widget.uid)),
                );
              },
        );

        if (!widget.showOnlineIndicator || !isOnline) {
          return avatarWidget;
        }

        final dotRadius = (widget.radius * 0.28).clamp(4.5, 7.5);

        return Stack(
          clipBehavior: Clip.none,
          children: [
            avatarWidget,
            Positioned(
              right: 1,
              bottom: 1,
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
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
