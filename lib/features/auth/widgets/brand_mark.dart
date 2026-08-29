import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';

class BrandMark extends StatelessWidget {
  final bool compact;
  final Color? foregroundColor;

  const BrandMark({
    super.key,
    this.compact = false,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final foreground = foregroundColor ?? AppColors.textPrimary;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: compact ? 38 : 46,
          height: compact ? 38 : 46,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, Color(0xFF9C83FF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(compact ? 12 : 15),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.22),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Icon(
            Icons.shopping_bag_rounded,
            color: Colors.white,
            size: compact ? 20 : 24,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          AppConstants.appName,
          style: TextStyle(
            color: foreground,
            fontSize: compact ? 18 : 22,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.4,
          ),
        ),
      ],
    );
  }
}
