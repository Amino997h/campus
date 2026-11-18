import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/user_avatar.dart';

class ProfileVerificationAvatar extends StatelessWidget {
  final String? photoUrl;
  final double radius;
  final int verificationLevel; // 1, 2, or 3
  final String verificationRole; // 'student' or 'professor'
  final bool isOnline;
  final VoidCallback? onTap;

  const ProfileVerificationAvatar({
    super.key,
    required this.photoUrl,
    this.radius = 65.0,
    this.verificationLevel = 1,
    this.verificationRole = 'student',
    this.isOnline = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // تحديد لون الإطار أو التدرج بحسب المستوى والدور
    // Level 1: وردي التطبيق الناعم (Default)
    // Level 2: كحلي رصين (Campus Email)
    // Level 3 Student: تدرج فاخر بين الوردي والكحلي
    // Level 3 Professor: ذهبي أكاديمي مات
    final isProfessor = verificationRole.toLowerCase() == 'professor';

    BoxDecoration ringDecoration;
    if (verificationLevel == 3 && isProfessor) {
      // Level 3 - Professor (Matte Academic Gold - Flat & Protected)
      ringDecoration = const BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.verificationGold,
      );
    } else if (verificationLevel == 3) {
      // Level 3 - Verified Student (Campus Emerald Green - Flat & Protected)
      ringDecoration = const BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.verificationEmerald,
      );
    } else if (verificationLevel == 2) {
      // Level 2 - University Email (Solid Campus Navy - Flat & Protected)
      ringDecoration = const BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.verificationNavy,
      );
    } else {
      // Level 1 - Default Pink (Unverified - Flat & Protected)
      ringDecoration = const BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.verificationDefault,
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // الحلقة الخارجية
          Container(
            width: (radius + 4.5) * 2,
            height: (radius + 4.5) * 2,
            padding: const EdgeInsets.all(3.0),
            decoration: ringDecoration,
            child: Container(
              padding: const EdgeInsets.all(2.5),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: ClipOval(
                child: UserAvatar(
                  photoUrl: photoUrl,
                  radius: radius,
                  defaultIcon: Icons.person_rounded,
                ),
              ),
            ),
          ),

          // نقطة الاتصال بالإنترنت إذا كان متصلاً بتصميم مسطح نظيف متناسق مع حلقة الملف
          if (isOnline)
            Positioned(
              right: 8,
              bottom: 8,
              child: Container(
                width: 18.0,
                height: 18.0,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 2.5,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
