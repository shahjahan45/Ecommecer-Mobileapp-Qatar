import 'package:flutter/material.dart';

import '../../core/design_system/app_tokens.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_pressable.dart';

class DcxNavigationItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;

  const DcxNavigationItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });
}

class DcxBottomNavigationBar extends StatelessWidget {
  static const double barHeight = 72;

  final int currentIndex;
  final double position;
  final List<DcxNavigationItem> items;
  final Map<int, int> badgeCounts;
  final ValueChanged<int> onSelected;

  const DcxBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.position,
    required this.items,
    this.badgeCounts = const <int, int>{},
    required this.onSelected,
  }) : assert(items.length > 1);

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final safePosition = position
        .clamp(0.0, (items.length - 1).toDouble())
        .toDouble();

    return SafeArea(
      top: false,
      minimum: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      child: RepaintBoundary(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: scheme.surface.withValues(alpha: dark ? 0.96 : 0.98),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(
              color: scheme.outlineVariant.withValues(alpha: 0.9),
            ),
            boxShadow: AppShadows.elevated,
          ),
          child: SizedBox(
            height: barHeight,
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final itemWidth = constraints.maxWidth / items.length;

                  return Stack(
                    fit: StackFit.expand,
                    clipBehavior: Clip.none,
                    children: [
                      Positioned(
                        left: itemWidth * safePosition,
                        top: 0,
                        bottom: 0,
                        width: itemWidth,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: dark ? scheme.primaryContainer.withValues(alpha: .46) : AppColors.primarySoft,
                              borderRadius: BorderRadius.circular(19),
                              border: Border.all(
                                color: scheme.primary.withValues(alpha: dark ? 0.20 : 0.08),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned.fill(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: List.generate(items.length, (index) {
                            return Expanded(
                              child: _NavigationButton(
                                key: ValueKey('bottom-nav-$index'),
                                item: items[index],
                                selected: index == currentIndex,
                                badgeCount: badgeCounts[index] ?? 0,
                                onTap: () => onSelected(index),
                              ),
                            );
                          }),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavigationButton extends StatelessWidget {
  final DcxNavigationItem item;
  final bool selected;
  final int badgeCount;
  final VoidCallback onTap;

  const _NavigationButton({
    super.key,
    required this.item,
    required this.selected,
    required this.badgeCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final transitionDuration = reduceMotion
        ? Duration.zero
        : const Duration(milliseconds: 220);

    return AppPressable(
      onTap: onTap,
      pressedScale: 0.96,
      borderRadius: BorderRadius.circular(18),
      child: Semantics(
        selected: selected,
        button: true,
        label: item.label,
        child: SizedBox(
          height: 60,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    AnimatedSwitcher(
                      duration: transitionDuration,
                      switchInCurve: Curves.easeOutBack,
                      switchOutCurve: Curves.easeInCubic,
                      transitionBuilder: (child, animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: ScaleTransition(
                            scale: Tween<double>(begin: 0.82, end: 1).animate(animation),
                            child: child,
                          ),
                        );
                      },
                      child: Icon(
                        selected ? item.selectedIcon : item.icon,
                        key: ValueKey('${item.label}-$selected'),
                        size: 22,
                        color: selected ? scheme.primary : scheme.onSurfaceVariant,
                      ),
                    ),
                    if (badgeCount > 0)
                      Positioned(
                        right: -10,
                        top: -8,
                        child: Container(
                          constraints: const BoxConstraints(minWidth: 17, minHeight: 17),
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            color: AppColors.danger,
                            borderRadius: BorderRadius.circular(AppRadius.pill),
                            border: Border.all(color: scheme.surface, width: 1.5),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            badgeCount > 99 ? '99+' : '$badgeCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                              height: 1,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 3),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 16),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: AnimatedDefaultTextStyle(
                      duration: transitionDuration,
                      curve: Curves.easeOutCubic,
                      style: TextStyle(
                        color: selected ? scheme.primary : scheme.onSurfaceVariant,
                        fontSize: 10.5,
                        fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                      ),
                      child: Text(
                        item.label,
                        maxLines: 1,
                        softWrap: false,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
