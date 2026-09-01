import 'package:flutter/material.dart';

import '../../../core/design_system/app_tokens.dart';
import '../../../core/theme/app_colors.dart';

class AccountQuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final String supportingText;
  final Color color;
  final Color softColor;
  final VoidCallback onTap;

  const AccountQuickAction({
    super.key,
    required this.icon,
    required this.label,
    required this.supportingText,
    required this.color,
    required this.softColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 170;
              final padding = compact ? 12.0 : 14.0;
              final iconBox = compact ? 36.0 : 38.0;

              return Container(
                constraints: const BoxConstraints(minHeight: 112),
                padding: EdgeInsets.all(padding),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        SizedBox(
                          width: iconBox,
                          height: iconBox,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: softColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              icon,
                              color: color,
                              size: compact ? 19 : 20,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          Icons.arrow_outward_rounded,
                          color: AppColors.textTertiary,
                          size: compact ? 16 : 18,
                        ),
                      ],
                    ),
                    SizedBox(height: compact ? 10 : 12),
                    Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: compact ? 12.5 : 13,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      supportingText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: compact ? 10 : 10.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
