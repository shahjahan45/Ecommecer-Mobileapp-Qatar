import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/design_system/app_tokens.dart';
import '../../../core/theme/app_colors.dart';

class CartCheckoutBar extends StatelessWidget {
  final int itemCount;
  final double total;
  final VoidCallback? onCheckout;

  const CartCheckoutBar({
    super.key,
    required this.itemCount,
    required this.total,
    required this.onCheckout,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      child: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: SafeArea(
          top: false,
          minimum: const EdgeInsets.fromLTRB(16, 10, 16, 10),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final stack = constraints.maxWidth < 330;

              final totalBlock = Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$itemCount ${itemCount == 1 ? 'item' : 'items'}',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 10.5,
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
                      fontSize: 19,
                      height: 1,
                      letterSpacing: -0.35,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              );

              final button = SizedBox(
                height: 52,
                child: FilledButton.icon(
                  onPressed: onCheckout,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                  ),
                  iconAlignment: IconAlignment.end,
                  icon: const Icon(Icons.arrow_forward_rounded, size: 19),
                  label: const Text(
                    'Checkout',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              );

              if (stack) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    totalBlock,
                    const SizedBox(height: 9),
                    button,
                  ],
                );
              }

              return Row(
                children: [
                  SizedBox(width: 112, child: totalBlock),
                  const SizedBox(width: 12),
                  Expanded(child: button),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
