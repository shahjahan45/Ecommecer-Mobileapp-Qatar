import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class PremiumBrandHeader extends StatelessWidget {
  const PremiumBrandHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 350;

        return Row(
          children: [
            Container(
              width: compact ? 48 : 54,
              height: compact ? 48 : 54,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6847F5), Color(0xFF8C6BFF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(17),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.24),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(
                Icons.shopping_bag_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
            SizedBox(width: compact ? 11 : 14),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'DCX',
                    maxLines: 1,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: compact ? 22 : 25,
                      height: 1,
                      letterSpacing: -0.7,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'ONLINE STORE',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: compact ? 9.5 : 10.5,
                      letterSpacing: 2.0,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: compact ? 9 : 12,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: AppColors.successSoft.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppColors.success.withValues(alpha: 0.18),
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.shield_rounded,
                    size: 15,
                    color: AppColors.success,
                  ),
                  SizedBox(width: 5),
                  Text(
                    'Secure',
                    style: TextStyle(
                      color: AppColors.success,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
