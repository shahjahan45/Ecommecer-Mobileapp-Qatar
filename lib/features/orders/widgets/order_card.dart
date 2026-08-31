import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/design_system/app_tokens.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/shop_order.dart';
import 'order_status_chip.dart';

class OrderCard extends StatelessWidget {
  final ShopOrder order;
  final VoidCallback onOpen;
  final VoidCallback onReorder;

  const OrderCard({
    super.key,
    required this.order,
    required this.onOpen,
    required this.onReorder,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.id,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_formatDate(order.placedAt)} • ${order.totalQuantity} ${order.totalQuantity == 1 ? 'item' : 'items'}',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                OrderStatusChip(status: order.status),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: order.isCancelled
                    ? AppColors.dangerSoft.withValues(alpha: 0.72)
                    : order.isDelivered
                        ? AppColors.successSoft.withValues(alpha: 0.72)
                        : AppColors.primarySoft.withValues(alpha: 0.66),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Icon(
                    order.isCancelled
                        ? Icons.cancel_outlined
                        : order.isDelivered
                            ? Icons.inventory_2_outlined
                            : Icons.local_shipping_outlined,
                    size: 19,
                    color: order.isCancelled
                        ? AppColors.danger
                        : order.isDelivered
                            ? AppColors.success
                            : AppColors.primary,
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.deliveryLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          order.deliveryWindow,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 9.5,
                            height: 1.35,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 13),
            _PackagePreview(order: order),
            const SizedBox(height: 13),
            Row(
              children: [
                const Text(
                  'Order total',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                Text(
                  '${AppConstants.currency} ${order.total.toStringAsFixed(0)}',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 13),
            LayoutBuilder(
              builder: (context, constraints) {
                final stacked = constraints.maxWidth < 300;
                final primaryLabel = order.isActive ? 'Track order' : 'View details';

                final primary = FilledButton.icon(
                  onPressed: onOpen,
                  icon: Icon(
                    order.isActive ? Icons.local_shipping_outlined : Icons.receipt_long_outlined,
                    size: 17,
                  ),
                  label: Text(primaryLabel),
                );
                final secondary = OutlinedButton.icon(
                  onPressed: onReorder,
                  icon: const Icon(Icons.refresh_rounded, size: 17),
                  label: const Text('Buy again'),
                );

                if (stacked) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: 48, child: primary),
                      const SizedBox(height: 8),
                      SizedBox(height: 48, child: secondary),
                    ],
                  );
                }

                return Row(
                  children: [
                    Expanded(child: SizedBox(height: 48, child: primary)),
                    const SizedBox(width: 8),
                    Expanded(child: SizedBox(height: 48, child: secondary)),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime value) {
    const months = <String>[
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[value.month - 1]} ${value.day}, ${value.year}';
  }
}

class _PackagePreview extends StatelessWidget {
  final ShopOrder order;

  const _PackagePreview({required this.order});

  @override
  Widget build(BuildContext context) {
    final visibleItems = order.items.take(3).toList(growable: false);

    return Row(
      children: [
        SizedBox(
          width: 36.0 + ((visibleItems.length - 1).clamp(0, 2).toDouble() * 25.0),
          height: 40,
          child: Stack(
            children: List.generate(visibleItems.length, (index) {
              final product = visibleItems[index].product;
              return Positioned(
                left: index * 25.0,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: product.softColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.surface, width: 2.5),
                  ),
                  alignment: Alignment.center,
                  child: Icon(product.icon, color: product.accent, size: 19),
                ),
              );
            }),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            order.items.length == 1
                ? order.items.first.product.name
                : '${order.items.first.product.name} + ${order.items.length - 1} more',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 10.5,
              height: 1.3,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
