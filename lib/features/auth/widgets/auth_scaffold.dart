import 'package:flutter/material.dart';

import '../../../core/design_system/app_tokens.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/fade_slide_in.dart';
import 'brand_mark.dart';

class AuthScaffold extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;
  final Widget? footer;
  final bool showBackButton;

  const AuthScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
    this.footer,
    this.showBackButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final horizontalPadding = constraints.maxWidth >= 700
                ? 48.0
                : constraints.maxWidth < 360
                    ? 14.0
                    : 20.0;
            final compactHeight = constraints.maxHeight < 680;
            final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;

            return Stack(
              children: [
                const Positioned(
                  top: -95,
                  right: -70,
                  child: _SoftOrb(size: 250, opacity: .12),
                ),
                const Positioned(
                  top: 210,
                  left: -105,
                  child: _SoftOrb(size: 210, opacity: .07),
                ),
                Positioned(
                  bottom: -120,
                  right: -85,
                  child: Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.secondary.withValues(alpha: .05),
                    ),
                  ),
                ),
                SingleChildScrollView(
                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    compactHeight ? 10 : 18,
                    horizontalPadding,
                    32 + keyboardInset,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 520),
                      child: FadeSlideIn(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                if (showBackButton) ...[
                                  IconButton.filledTonal(
                                    onPressed: () => Navigator.maybePop(context),
                                    style: IconButton.styleFrom(
                                      backgroundColor: AppColors.surface,
                                      foregroundColor: AppColors.textPrimary,
                                      side: const BorderSide(color: AppColors.border),
                                    ),
                                    icon: const Icon(Icons.arrow_back_rounded),
                                  ),
                                  const SizedBox(width: 12),
                                ],
                                const Expanded(child: BrandMark(compact: true)),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: AppColors.successSoft,
                                    borderRadius: BorderRadius.circular(AppRadius.pill),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.lock_rounded, size: 12, color: AppColors.success),
                                      SizedBox(width: 4),
                                      Text(
                                        'Secure',
                                        style: TextStyle(
                                          color: AppColors.success,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: compactHeight ? 24 : 38),
                            Text(
                              title,
                              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                    fontSize: constraints.maxWidth < 390 ? 28 : 32,
                                  ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              subtitle,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    height: 1.6,
                                    fontSize: 14.5,
                                  ),
                            ),
                            SizedBox(height: compactHeight ? 20 : 28),
                            Container(
                              clipBehavior: Clip.antiAlias,
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(AppRadius.xxl),
                                border: Border.all(color: AppColors.border),
                                boxShadow: AppShadows.elevated,
                              ),
                              child: Column(
                                children: [
                                  Container(
                                    height: 4,
                                    decoration: const BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [AppColors.primary, AppColors.secondary],
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(
                                      constraints.maxWidth < 390 ? 18 : 22,
                                    ),
                                    child: child,
                                  ),
                                ],
                              ),
                            ),
                            if (footer != null) ...[
                              const SizedBox(height: 22),
                              footer!,
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SoftOrb extends StatelessWidget {
  final double size;
  final double opacity;

  const _SoftOrb({required this.size, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primary.withValues(alpha: opacity),
      ),
    );
  }
}
