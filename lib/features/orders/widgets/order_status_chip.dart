import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../models/shop_order.dart';

class OrderStatusChip extends StatelessWidget {
  final ShopOrderStatus status;

  const OrderStatusChip({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final (foreground, background) = _colorsFor(status);

    return Semantics(
      label: 'Order status ${status.label}',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: foreground.withValues(alpha: 0.14)),
        ),
        child: Text(
          status.label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: foreground,
            fontSize: 10,
            height: 1,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }

  (Color, Color) _colorsFor(ShopOrderStatus status) {
    switch (status) {
      case ShopOrderStatus.processing:
      case ShopOrderStatus.packed:
        return (AppColors.primary, AppColors.primarySoft);
      case ShopOrderStatus.shipped:
      case ShopOrderStatus.outForDelivery:
        return (AppColors.info, AppColors.infoSoft);
      case ShopOrderStatus.delivered:
        return (AppColors.success, AppColors.successSoft);
      case ShopOrderStatus.cancelled:
        return (AppColors.danger, AppColors.dangerSoft);
    }
  }
}
