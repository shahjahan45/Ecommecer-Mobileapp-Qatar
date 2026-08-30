import 'package:flutter/material.dart';

import '../../../core/design_system/app_tokens.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_pressable.dart';

class ProductVariantSelector extends StatelessWidget {
  final String title;
  final List<String> options;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final bool showGuide;
  final VoidCallback? onGuideTap;

  const ProductVariantSelector({
    super.key,
    required this.title,
    required this.options,
    required this.selectedIndex,
    required this.onSelected,
    this.showGuide = false,
    this.onGuideTap,
  });

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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
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
          height: 54,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.zero,
            itemCount: options.length,
            separatorBuilder: (_, __) => const SizedBox(width: 9),
            itemBuilder: (context, index) {
              final selected = index == safeSelectedIndex;
              return Semantics(
                button: true,
                selected: selected,
                label: '${title.replaceFirst('Select ', '')} ${options[index]}',
                child: AppPressable(
                  onTap: () => onSelected(index),
                  pressedScale: 0.96,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  child: AnimatedContainer(
                    duration: AppMotion.fast,
                    curve: AppMotion.standardCurve,
                    width: 58,
                    height: 52,
                    decoration: BoxDecoration(
                      color:
                          selected ? AppColors.primarySoft : AppColors.surface,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      border: Border.all(
                        color: selected ? AppColors.primary : AppColors.border,
                        width: selected ? 1.5 : 1,
                      ),
                    ),
                    child: Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.center,
                      children: [
                        Text(
                          options[index],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: selected
                                ? AppColors.primary
                                : AppColors.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        if (selected)
                          Positioned(
                            top: -5,
                            right: -5,
                            child: Container(
                              width: 20,
                              height: 20,
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: const Icon(
                                Icons.check_rounded,
                                size: 13,
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
