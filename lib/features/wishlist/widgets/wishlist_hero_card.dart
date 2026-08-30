import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/design_system/app_tokens.dart';
import '../../../core/theme/app_colors.dart';

class WishlistHeroCard extends StatelessWidget {
  final int count;
  final double totalSavings;

  const WishlistHeroCard({
    super.key,
    required this.count,
    required this.totalSavings,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 340;

        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(compact ? AppSpacing.lg : AppSpacing.xl),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFF7657FF),
                Color(0xFF5A39DE),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AppRadius.xxl),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.24),
                blurRadius: 30,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                right: -38,
                top: -54,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                ),
              ),
              Positioned(
                right: 42,
                bottom: -72,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.06),
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        width: compact ? 44 : 48,
                        height: compact ? 44 : 48,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.16),
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.favorite_rounded,
                          color: Colors.white,
                          size: compact ? 23 : 25,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 11,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.lock_outline_rounded,
                              color: Colors.white,
                              size: 14,
                            ),
                            SizedBox(width: 5),
                            Text(
                              'Private list',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: compact ? AppSpacing.md : AppSpacing.lg,
                  ),
                  Text(
                    'Your saved favourites',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: compact ? 21 : 24,
                      height: 1.08,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.6,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    count == 1
                        ? '1 product is waiting for you.'
                        : '$count products are waiting for you.',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.78),
                      fontSize: 12.5,
                      height: 1.45,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(
                    height: compact ? AppSpacing.md : AppSpacing.lg,
                  ),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _MetricPill(
                        icon: Icons.bookmark_added_rounded,
                        label: 'Saved',
                        value: '$count',
                      ),
                      _MetricPill(
                        icon: Icons.savings_outlined,
                        label: 'Potential savings',
                        value:
                            '${AppConstants.currency} ${totalSavings.toStringAsFixed(0)}',
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MetricPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _MetricPill({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 17),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.70),
                  fontSize: 9.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
