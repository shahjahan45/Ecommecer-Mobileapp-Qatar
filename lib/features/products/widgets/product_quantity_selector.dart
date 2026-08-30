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
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _QuantityButton(
            icon: Icons.remove_rounded,
            enabled: value > 1,
            onTap: () => onChanged(value - 1),
          ),
          SizedBox(
            width: 38,
            child: AnimatedSwitcher(
              duration: AppMotion.fast,
              child: Text(
                '$value',
                key: ValueKey(value),
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontSize: 13, fontWeight: FontWeight.w900),
              ),
            ),
          ),
          _QuantityButton(
            icon: Icons.add_rounded,
            enabled: value < maxValue,
            onTap: () => onChanged(value + 1),
          ),
        ],
      ),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  const _QuantityButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: enabled ? onTap : null,
      constraints: const BoxConstraints.tightFor(width: 40, height: 40),
      padding: EdgeInsets.zero,
      splashRadius: 20,
      icon: Icon(
        icon,
        size: 19,
        color: enabled ? AppColors.primary : AppColors.textTertiary,
      ),
    );
  }
}
