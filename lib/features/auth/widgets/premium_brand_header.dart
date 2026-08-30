import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class PremiumBrandHeader extends StatelessWidget {
  const PremiumBrandHeader({super.key});

  static const String _logoAsset = 'assets/icon/app_icon.png';

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 340;
        final logoHeight = compact ? 48.0 : 56.0;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Semantics(
                image: true,
                label: 'DCX Online Store logo',
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Image.asset(
                    _logoAsset,
                    height: logoHeight,
                    fit: BoxFit.contain,
                    alignment: Alignment.centerLeft,
                    filterQuality: FilterQuality.high,
                    isAntiAlias: true,
                  ),
                ),
              ),
            ),
            SizedBox(width: compact ? 8 : 12),
            Container(
              constraints: const BoxConstraints(minHeight: 40),
              padding: EdgeInsets.symmetric(
                horizontal: compact ? 10 : 13,
                vertical: compact ? 8 : 9,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFEAF9F1),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: AppColors.success.withValues(alpha: 0.18),
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.verified_user_rounded,
                    size: 16,
                    color: AppColors.success,
                  ),
                  SizedBox(width: 6),
                  Text(
                    'Secure',
                    style: TextStyle(
                      color: AppColors.success,
                      fontSize: 11.5,
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
