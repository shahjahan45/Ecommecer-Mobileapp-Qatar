import 'package:flutter/material.dart';

import '../design_system/app_tokens.dart';
import '../theme/app_colors.dart';

class EmptyStateCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyStateCard({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 380;
        final outerMargin = compact ? AppSpacing.sm : AppSpacing.lg;
        final innerPadding = compact ? AppSpacing.xl : AppSpacing.xxl;
        final iconSize = compact ? 68.0 : 82.0;

        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Container(
              width: double.infinity,
              margin: EdgeInsets.all(outerMargin),
              padding: EdgeInsets.all(innerPadding),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.xxl),
                border: Border.all(color: AppColors.border),
                boxShadow: AppShadows.soft,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: iconSize,
                    height: iconSize,
                    decoration: const BoxDecoration(
                      color: AppColors.primarySoft,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      icon,
                      size: compact ? 31 : 38,
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(height: compact ? AppSpacing.md : AppSpacing.lg),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontSize: compact ? 18 : null,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          height: 1.45,
                        ),
                  ),
                  if (actionLabel != null) ...[
                    SizedBox(height: compact ? AppSpacing.lg : AppSpacing.xl),
                    FilledButton.icon(
                      onPressed: onAction,
                      icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                      label: Text(actionLabel!),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
