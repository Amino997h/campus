import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class SearchCategoryFilter extends StatelessWidget {
  final List<String> categories;
  final int selectedIndex;
  final Function(int) onSelected;

  const SearchCategoryFilter({
    super.key,
    required this.categories,
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final isSelected = selectedIndex == index;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(categories[index]),
              selected: isSelected,
              selectedColor: AppColors.primaryLight,
              backgroundColor: Colors.white,
              labelStyle: TextStyle(
                fontSize: 12.0,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? AppColors.primary : AppColors.textDark,
              ),
              side: BorderSide(
                color: isSelected ? AppColors.primary : AppColors.borderLight,
                width: 1.0,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              onSelected: (selected) {
                if (selected) {
                  onSelected(index);
                }
              },
            ),
          );
        },
      ),
    );
  }
}
