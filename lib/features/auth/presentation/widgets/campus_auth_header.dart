import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';

class CampusAuthHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const CampusAuthHeader({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: CircleAvatar(
            radius: 46.0,
            backgroundColor: AppColors.avatarBg,
            child: Icon(
              icon,
              size: 46,
              color: AppColors.navy,
            ),
          ),
        ),
        const SizedBox(height: 20),
        Center(
          child: Text(
            title,
            style: GoogleFonts.varelaRound(
              fontSize: 22.0,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Center(
          child: Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13.0,
              color: AppColors.textMuted,
            ),
          ),
        ),
      ],
    );
  }
}
