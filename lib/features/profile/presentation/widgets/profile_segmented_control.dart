import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class ProfileSegmentedControl extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabChanged;
  final int postsCount;
  final int projectsCount;

  const ProfileSegmentedControl({
    super.key,
    required this.selectedIndex,
    required this.onTabChanged,
    this.postsCount = 0,
    this.projectsCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
      padding: const EdgeInsets.all(4.0),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: AppColors.borderLight, width: 1.0),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildTabButton(
              index: 0,
              icon: Icons.grid_on_rounded,
              title: 'Posts',
              count: postsCount,
              isSelected: selectedIndex == 0,
            ),
          ),
          const SizedBox(width: 4.0),
          Expanded(
            child: _buildTabButton(
              index: 1,
              icon: Icons.code_rounded,
              title: 'Projects',
              count: projectsCount,
              isSelected: selectedIndex == 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton({
    required int index,
    required IconData icon,
    required String title,
    required int count,
    required bool isSelected,
  }) {
    return InkWell(
      onTap: () => onTabChanged(index),
      borderRadius: BorderRadius.circular(12.0),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 9.0),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 17.0,
              color: isSelected ? AppColors.primary : AppColors.textMuted,
            ),
            const SizedBox(width: 7.0),
            Text(
              title,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected ? AppColors.navy : AppColors.textMuted,
              ),
            ),
            if (count > 0) ...[
              const SizedBox(width: 6.0),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 1.5),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary.withValues(alpha: 0.12) : Colors.black12,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 11.0,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? AppColors.primary : AppColors.textMuted,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
