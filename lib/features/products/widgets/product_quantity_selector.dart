import 'package:flutter/material.dart';

import '../../../core/design_system/app_tokens.dart';
import '../../../core/theme/app_colors.dart';

class ProductQuantitySelector extends StatelessWidget {
  final int value;
  final int maxValue;
  final ValueChanged<int> onChanged;

  const ProductQuantitySelector({
    super.key,
    required this.value,
    required this.maxValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Quantity $value',
      child: Container(
        height: 46,
        decoration: BoxDecoration(
          color: AppColors.surfaceMuted.withValues(alpha: 0.72),
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _QuantityButton(
              tooltip: 'Decrease quantity',
              icon: Icons.remove_rounded,
              enabled: value > 1,
              onTap: () => onChanged(value - 1),
            ),
            SizedBox(
              width: 42,
              child: AnimatedSwitcher(
                duration: AppMotion.fast,
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: ScaleTransition(scale: animation, child: child),
                ),
                child: Text(
                  '$value',
                  key: ValueKey(value),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
            _QuantityButton(
              tooltip: 'Increase quantity',
              icon: Icons.add_rounded,
              enabled: value < maxValue,
              onTap: () => onChanged(value + 1),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  final String tooltip;
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  const _QuantityButton({
    required this.tooltip,
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed: enabled ? onTap : null,
      constraints: const BoxConstraints.tightFor(width: 42, height: 42),
      padding: EdgeInsets.zero,
      splashRadius: 20,
      icon: Icon(
        icon,
        size: 20,
        color: enabled ? AppColors.primary : AppColors.textTertiary,
      ),
    );
  }
}
