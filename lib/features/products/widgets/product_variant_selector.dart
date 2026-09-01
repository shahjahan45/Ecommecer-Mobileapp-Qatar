import 'package:flutter/material.dart';

import '../../../core/design_system/app_tokens.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_pressable.dart';

class ProductVariantSelector extends StatelessWidget {
  final String title;
  final List<String> options;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final List<Color>? colorValues;
  final bool showGuide;
  final VoidCallback? onGuideTap;

  const ProductVariantSelector({
    super.key,
    required this.title,
    required this.options,
    required this.selectedIndex,
    required this.onSelected,
    this.colorValues,
    this.showGuide = false,
    this.onGuideTap,
  });

  bool get _usesColorSwatches =>
      colorValues != null &&
      colorValues!.length == options.length &&
      colorValues!.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    if (options.isEmpty) return const SizedBox.shrink();

    final safeSelectedIndex = selectedIndex.clamp(0, options.length - 1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.15,
                ),
              ),
            ),
            if (showGuide)
              TextButton.icon(
                onPressed: onGuideTap,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  minimumSize: const Size(0, 40),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 6,
                  ),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                icon: const Icon(Icons.straighten_rounded, size: 17),
                label: const Text(
                  'Size guide',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: _usesColorSwatches ? 58 : 54,
          child: _usesColorSwatches
              ? ListView.separated(
                  key: const Key('product-variant-scroll'),
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 1),
                  itemCount: options.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 9),
                  itemBuilder: (context, index) {
                    final selected = index == safeSelectedIndex;
                    return _ColorVariantButton(
                      key: ValueKey('color-variant-${options[index]}'),
                      name: options[index],
                      color: colorValues![index],
                      selected: selected,
                      onTap: () => onSelected(index),
                    );
                  },
                )
              : SingleChildScrollView(
                  key: const Key('product-variant-scroll'),
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 1),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (var index = 0; index < options.length; index++) ...[
                        _TextVariantButton(
                          key: ValueKey('variant-option-${options[index]}'),
                          title: title,
                          value: options[index],
                          selected: index == safeSelectedIndex,
                          onTap: () => onSelected(index),
                        ),
                        if (index != options.length - 1)
                          const SizedBox(width: 9),
                      ],
                    ],
                  ),
                ),
        ),
      ],
    );
  }
}

class _ColorVariantButton extends StatelessWidget {
  final String name;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _ColorVariantButton({
    super.key,
    required this.name,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final checkColor =
        color.computeLuminance() > 0.58 ? AppColors.textPrimary : Colors.white;

    return Semantics(
      container: true,
      excludeSemantics: true,
      button: true,
      selected: selected,
      label: 'Color $name',
      onTap: onTap,
      child: AppPressable(
        onTap: onTap,
        pressedScale: 0.95,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: AnimatedContainer(
          duration: AppMotion.fast,
          curve: AppMotion.standardCurve,
          width: 54,
          height: 54,
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: selected ? AppColors.primarySoft : AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.border,
              width: selected ? 1.7 : 1,
            ),
          ),
          child: AnimatedContainer(
            duration: AppMotion.fast,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: color.computeLuminance() > 0.92
                    ? AppColors.border
                    : Colors.transparent,
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.20),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: AnimatedSwitcher(
              duration: AppMotion.fast,
              child: selected
                  ? Icon(
                      Icons.check_rounded,
                      key: const ValueKey('selected-color'),
                      size: 19,
                      color: checkColor,
                    )
                  : const SizedBox(
                      key: ValueKey('unselected-color'),
                      width: 19,
                      height: 19,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TextVariantButton extends StatelessWidget {
  final String title;
  final String value;
  final bool selected;
  final VoidCallback onTap;

  const _TextVariantButton({
    super.key,
    required this.title,
    required this.value,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final semanticGroup = title
        .replaceFirst(RegExp(r'^Select\s+', caseSensitive: false), '')
        .trim()
        .toLowerCase();

    return Semantics(
      container: true,
      excludeSemantics: true,
      button: true,
      selected: selected,
      label: '$semanticGroup $value',
      onTap: onTap,
      child: AppPressable(
        onTap: onTap,
        pressedScale: 0.96,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: AnimatedContainer(
          duration: AppMotion.fast,
          curve: AppMotion.standardCurve,
          height: 52,
          constraints: const BoxConstraints(
            minWidth: 58,
            maxWidth: 116,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: selected ? AppColors.primarySoft : AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.border,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: selected ? AppColors.primary : AppColors.textPrimary,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (selected) ...[
                const SizedBox(width: 6),
                const Icon(
                  Icons.check_circle_rounded,
                  size: 16,
                  color: AppColors.primary,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
