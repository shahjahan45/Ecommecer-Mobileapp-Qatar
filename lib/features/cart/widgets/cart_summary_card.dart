import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/design_system/app_tokens.dart';
import '../../../core/theme/app_colors.dart';
import '../cart_controller.dart';

class CartSummaryCard extends StatelessWidget {
  final CartController cart;

  const CartSummaryCard({
    super.key,
    required this.cart,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final promotion = cart.appliedPromotion;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.receipt_long_rounded,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Order summary',
                style: TextStyle(
                  color: scheme.onSurface,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _SummaryRow(label: 'Subtotal', amount: cart.subtotal),
          if (cart.totalSavings > 0) ...[
            const SizedBox(height: 10),
            _SummaryRow(
              label: 'Product savings',
              amount: -cart.totalSavings,
              amountColor: AppColors.success,
            ),
          ],
          if (promotion != null && cart.promotionSavings > 0) ...[
            const SizedBox(height: 10),
            _SummaryRow(
              label: 'Promo • ${promotion.code}',
              amount: -cart.promotionSavings,
              amountColor: AppColors.success,
            ),
          ],
          const SizedBox(height: 10),
          _SummaryRow(
            label: 'Delivery',
            amount: cart.deliveryFee,
            freeLabel: cart.deliveryFee == 0 ? 'FREE' : null,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Divider(height: 1, color: scheme.outlineVariant),
          ),
          _SummaryRow(
            label: 'Total',
            amount: cart.total,
            strong: true,
          ),
          const SizedBox(height: 14),
          _DeliveryProgress(cart: cart),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final double amount;
  final Color? amountColor;
  final String? freeLabel;
  final bool strong;

  const _SummaryRow({
    required this.label,
    required this.amount,
    this.amountColor,
    this.freeLabel,
    this.strong = false,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: strong ? scheme.onSurface : scheme.onSurfaceVariant,
              fontSize: strong ? 14 : 12,
              fontWeight: strong ? FontWeight.w900 : FontWeight.w700,
            ),
          ),
        ),
        if (freeLabel != null)
          Text(
            freeLabel!,
            style: const TextStyle(
              color: AppColors.success,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          )
        else
          Text(
            '${amount < 0 ? '-' : ''}${AppConstants.currency} ${amount.abs().toStringAsFixed(0)}',
            style: TextStyle(
              color: amountColor ?? scheme.onSurface,
              fontSize: strong ? 17 : 12.5,
              fontWeight: strong ? FontWeight.w900 : FontWeight.w800,
            ),
          ),
      ],
    );
  }
}

class _DeliveryProgress extends StatelessWidget {
  final CartController cart;

  const _DeliveryProgress({required this.cart});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final complete = cart.amountToFreeDelivery <= 0;
    final progress = cart.isEmpty
        ? 0.0
        : (cart.subtotal / CartController.freeDeliveryThreshold)
            .clamp(0.0, 1.0)
            .toDouble();
    final freeByPromo = cart.appliedPromotion?.code == 'FREESHIP' &&
        cart.promotionDeliverySaving > 0;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: complete
            ? (scheme.brightness == Brightness.dark
                ? AppColors.success.withValues(alpha: .12)
                : AppColors.successSoft)
            : scheme.primaryContainer.withValues(alpha: .58),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                complete
                    ? Icons.local_shipping_rounded
                    : Icons.inventory_2_outlined,
                color: complete ? AppColors.success : scheme.primary,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  freeByPromo
                      ? 'Free delivery unlocked with FREESHIP'
                      : complete
                          ? 'You unlocked free delivery'
                          : 'Add ${AppConstants.currency} ${cart.amountToFreeDelivery.toStringAsFixed(0)} more for free delivery',
                  style: TextStyle(
                    color: complete ? AppColors.success : scheme.primary,
                    fontSize: 11,
                    height: 1.35,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.pill),
            child: LinearProgressIndicator(
              minHeight: 5,
              value: complete ? 1 : progress,
              backgroundColor: scheme.surface.withValues(alpha: 0.72),
              valueColor: AlwaysStoppedAnimation<Color>(
                complete ? AppColors.success : scheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
