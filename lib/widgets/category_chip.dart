import 'package:flutter/material.dart';

import '../models/category_item.dart';
import '../utils/formatters.dart';
import '../utils/theme_colors.dart';

class CategoryChip extends StatelessWidget {
  const CategoryChip({
    super.key,
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  final CategoryItem category;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 96,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? ThemeColors.primary
              : ThemeColors.surfaceFor(brightness),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 18,
                backgroundColor: isSelected
                  ? Colors.white
                  : ThemeColors.backgroundFor(brightness),
              child: Icon(
                category.icon,
                color: isSelected ? ThemeColors.primary : ThemeColors.textPrimary,
                size: 18,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              category.name,
              textAlign: TextAlign.center,
              maxLines: 2,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: isSelected ? Colors.white : ThemeColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              formatCurrency(category.amount),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: isSelected
                      ? Colors.white70
                      : ThemeColors.textSecondaryFor(brightness),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
