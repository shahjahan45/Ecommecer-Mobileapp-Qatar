import 'package:flutter/material.dart';

import '../../../core/design_system/app_tokens.dart';
import '../../../core/theme/app_colors.dart';

class AccountHeroCard extends StatelessWidget {
  final int ordersCount;
  final int activeOrdersCount;
  final int wishlistCount;

  const AccountHeroCard({
    super.key,
    required this.ordersCount,
    required this.activeOrdersCount,
    required this.wishlistCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6847F5), Color(0xFF5334DB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.22),
            blurRadius: 30,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Stack(
        children: [
          const Positioned(
            right: -54,
            top: -58,
            child: _DecorativeCircle(size: 180, opacity: 0.08),
          ),
          const Positioned(
            right: 38,
            bottom: -52,
            child: _DecorativeCircle(size: 118, opacity: 0.06),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.75),
                        ),
                      ),
                      child: Image.asset(
                        'assets/icon/app_icon.png',
                        fit: BoxFit.contain,
                        filterQuality: FilterQuality.high,
                        semanticLabel: 'DCX Online Store official logo',
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'My DCX account',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              height: 1.1,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.4,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Shopping, orders and account settings in one place.',
                            style: TextStyle(
                              color: Color(0xFFE7E1FF),
                              fontSize: 12.5,
                              height: 1.45,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final compactStatus = constraints.maxWidth < 300;
                    return Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        horizontal: compactStatus ? 10 : 11,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.18),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.shield_rounded,
                            color: Colors.white,
                            size: compactStatus ? 15 : 16,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Secure account center',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: compactStatus ? 10.5 : 11.5,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 18),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final compact = constraints.maxWidth < 330;
                    return Row(
                      children: [
                        Expanded(
                          child: _AccountMetric(
                            value: '$ordersCount',
                            label: 'Orders',
                            compact: compact,
                          ),
                        ),
                        _MetricDivider(compact: compact),
                        Expanded(
                          child: _AccountMetric(
                            value: '$activeOrdersCount',
                            label: 'Active',
                            compact: compact,
                          ),
                        ),
                        _MetricDivider(compact: compact),
                        Expanded(
                          child: _AccountMetric(
                            value: '$wishlistCount',
                            label: 'Saved',
                            compact: compact,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AccountMetric extends StatelessWidget {
  final String value;
  final String label;
  final bool compact;

  const _AccountMetric({
    required this.value,
    required this.label,
    required this.compact,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: compact ? 17 : 19,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: const Color(0xFFDCD4FF),
            fontSize: compact ? 9.5 : 10.5,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _MetricDivider extends StatelessWidget {
  final bool compact;

  const _MetricDivider({required this.compact});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: compact ? 32 : 36,
      color: Colors.white.withValues(alpha: 0.18),
    );
  }
}

class _DecorativeCircle extends StatelessWidget {
  final double size;
  final double opacity;

  const _DecorativeCircle({required this.size, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: opacity),
      ),
    );
  }
}
