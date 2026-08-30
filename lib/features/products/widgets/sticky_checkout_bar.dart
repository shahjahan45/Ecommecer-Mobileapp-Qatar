import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/design_system/app_tokens.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_pressable.dart';
import '../../../models/product.dart';

class StickyCheckoutBar extends StatelessWidget {
  final Product product;
  final int quantity;
  final VoidCallback? onAddToCart;
  final VoidCallback? onBuyNow;

  const StickyCheckoutBar({
    super.key,
    required this.product,
    required this.quantity,
    required this.onAddToCart,
    required this.onBuyNow,
  });

  @override
  Widget build(BuildContext context) {
    final total = product.price * quantity;

    return Material(
      color: AppColors.surface,
      elevation: 0,
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(
            top: BorderSide(color: AppColors.border),
          ),
        ),
        child: SafeArea(
          top: false,
          minimum: const EdgeInsets.fromLTRB(14, 10, 14, 10),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final stackActions = constraints.maxWidth < 350;

              final totalBlock = Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Total',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${AppConstants.currency} ${total.toStringAsFixed(0)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      height: 1.05,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.35,
                    ),
                  ),
                ],
              );

              final actions = Row(
                children: [
                  Expanded(
                    child: _CheckoutButton(
                      label: 'Add to cart',
                      icon: Icons.shopping_cart_outlined,
                      outlined: true,
                      onTap: onAddToCart,
                    ),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: _CheckoutButton(
                      label: 'Buy now',
                      icon: Icons.arrow_forward_rounded,
                      onTap: onBuyNow,
                    ),
                  ),
                ],
              );

              if (stackActions) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    totalBlock,
                    const SizedBox(height: 9),
                    actions,
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(width: 92, child: totalBlock),
                  const SizedBox(width: 10),
                  Expanded(child: actions),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _CheckoutButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool outlined;
  final VoidCallback? onTap;

  const _CheckoutButton({
    required this.label,
    required this.icon,
    this.outlined = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;

    return Semantics(
      button: true,
      enabled: enabled,
      label: enabled ? label : '$label unavailable',
      child: AppPressable(
        onTap: onTap,
        pressedScale: 0.98,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: AnimatedContainer(
          duration: AppMotion.fast,
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: outlined
                ? AppColors.surface
                : enabled
                    ? AppColors.primary
                    : AppColors.surfaceStrong,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: outlined
                  ? enabled
                      ? AppColors.primary.withValues(alpha: 0.55)
                      : AppColors.border
                  : Colors.transparent,
              width: outlined ? 1.2 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: outlined
                    ? enabled
                        ? AppColors.primary
                        : AppColors.textTertiary
                    : enabled
                        ? Colors.white
                        : AppColors.textTertiary,
              ),
              const SizedBox(width: 7),
              Flexible(
                child: Text(
                  enabled ? label : 'Unavailable',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: outlined
                        ? enabled
                            ? AppColors.primary
                            : AppColors.textTertiary
                        : enabled
                            ? Colors.white
                            : AppColors.textTertiary,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
