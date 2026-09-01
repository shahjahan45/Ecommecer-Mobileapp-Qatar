import 'package:flutter/material.dart';

import '../design_system/app_tokens.dart';
import '../theme/app_colors.dart';
import 'app_pressable.dart';

class AppIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final bool showBadge;
  final String? badgeText;
  final Color? backgroundColor;
  final Color? iconColor;

  const AppIconButton({
    super.key,
    required this.icon,
    this.onTap,
    this.showBadge = false,
    this.badgeText,
    this.backgroundColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    return AppPressable(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: backgroundColor ?? scheme.surface,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: scheme.outlineVariant),
              boxShadow: dark ? null : AppShadows.soft,
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 21, color: iconColor ?? scheme.onSurface),
          ),
          if (showBadge)
            Positioned(
              top: -4,
              right: -4,
              child: Container(
                constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                padding: const EdgeInsets.symmetric(horizontal: 5),
                decoration: BoxDecoration(
                  color: AppColors.danger,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  border: Border.all(color: scheme.surface, width: 2),
                ),
                alignment: Alignment.center,
                child: Text(
                  badgeText ?? '',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    height: 1,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
