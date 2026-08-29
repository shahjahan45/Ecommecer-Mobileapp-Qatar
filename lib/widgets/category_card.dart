import 'package:flutter/material.dart';

import '../core/design_system/app_tokens.dart';
import '../core/theme/app_colors.dart';
import '../core/widgets/app_pressable.dart';
import '../models/category.dart';

class CategoryCard extends StatelessWidget {
  final ShopCategory category;
  final bool selected;
  final VoidCallback? onTap;

  const CategoryCard({
    super.key,
    required this.category,
    this.selected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppPressable(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppMotion.standard,
        curve: AppMotion.standardCurve,
        width: 92,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 13),
        decoration: BoxDecoration(
          color: selected ? category.softColor : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: selected
                ? category.accent.withValues(alpha: 0.28)
                : AppColors.border,
          ),
          boxShadow: selected ? AppShadows.soft : const [],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: AppMotion.standard,
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: selected ? AppColors.surface : category.softColor,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              alignment: Alignment.center,
              child: Icon(category.icon, color: category.accent, size: 24),
            ),
            const SizedBox(height: 10),
            Text(
              category.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w700,
                color: selected ? category.accent : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
