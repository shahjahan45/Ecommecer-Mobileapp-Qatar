import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/design_system/app_tokens.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_pressable.dart';
import '../../../models/cart_item.dart';

class CartItemCard extends StatelessWidget {
  final CartItem item;
  final VoidCallback onTap;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onRemove;
  final VoidCallback onMoveToWishlist;

  const CartItemCard({
    super.key,
    required this.item,
    required this.onTap,
    required this.onIncrement,
    required this.onDecrement,
    required this.onRemove,
    required this.onMoveToWishlist,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 350;
        final product = item.product;

        return Container(
          padding: EdgeInsets.all(compact ? 11 : 14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppPressable(
                    onTap: onTap,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    child: Container(
                      width: compact ? 76 : 88,
                      height: compact ? 82 : 94,
                      decoration: BoxDecoration(
                        color: product.softColor,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        product.icon,
                        size: compact ? 38 : 44,
                        color: product.accent,
                      ),
                    ),
                  ),
                  SizedBox(width: compact ? 10 : 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: AppPressable(
                                onTap: onTap,
                                child: Text(
                                  product.name,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: compact ? 13 : 14,
                                    height: 1.25,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Semantics(
                              button: true,
                              label: 'Remove ${product.name} from cart',
                              child: AppPressable(
                                onTap: onRemove,
                                borderRadius: BorderRadius.circular(AppRadius.pill),
                                child: const Padding(
                                  padding: EdgeInsets.all(4),
                                  child: Icon(
                                    Icons.close_rounded,
                                    size: 19,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Text(
                          [
                            if (product.brand.isNotEmpty) product.brand,
                            if (item.variant != null && item.variant!.isNotEmpty)
                              item.variant!,
                          ].join(' • '),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 7),
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              '${AppConstants.currency} ${product.price.toStringAsFixed(0)}',
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            if (product.oldPrice != null)
                              Text(
                                '${AppConstants.currency} ${product.oldPrice!.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  color: AppColors.textTertiary,
                                  decoration: TextDecoration.lineThrough,
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.check_circle_rounded,
                              size: 14,
                              color: AppColors.success,
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                '${product.stockQuantity} in stock',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: AppColors.success,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: compact ? 10 : 12),
              const Divider(height: 1, color: AppColors.border),
              SizedBox(height: compact ? 9 : 11),
              Row(
                children: [
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: onMoveToWishlist,
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          minimumSize: const Size(44, 40),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        icon: const Icon(Icons.favorite_border_rounded, size: 17),
                        label: Text(
                          compact ? 'Save' : 'Save for later',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _CartQuantityStepper(
                    quantity: item.quantity,
                    canIncrement: item.quantity < product.stockQuantity,
                    onIncrement: onIncrement,
                    onDecrement: onDecrement,
                  ),
                ],
              ),
              const SizedBox(height: 9),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Item total',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Text(
                    '${AppConstants.currency} ${item.lineTotal.toStringAsFixed(0)}',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
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

class _CartQuantityStepper extends StatelessWidget {
  final int quantity;
  final bool canIncrement;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const _CartQuantityStepper({
    required this.quantity,
    required this.canIncrement,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepperButton(
            icon: quantity > 1 ? Icons.remove_rounded : Icons.delete_outline_rounded,
            label: quantity > 1 ? 'Decrease quantity' : 'Remove item',
            onTap: onDecrement,
          ),
          SizedBox(
            width: 36,
            child: Text(
              '$quantity',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          _StepperButton(
            icon: Icons.add_rounded,
            label: 'Increase quantity',
            onTap: canIncrement ? onIncrement : null,
          ),
        ],
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _StepperButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      child: IconButton(
        onPressed: onTap,
        constraints: const BoxConstraints.tightFor(width: 40, height: 40),
        padding: EdgeInsets.zero,
        splashRadius: 20,
        icon: Icon(
          icon,
          size: 18,
          color: enabled ? AppColors.primary : AppColors.textTertiary,
        ),
      ),
    );
  }
}
