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
  final ValueChanged<int> onSelected;

  const DcxBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.position,
    required this.items,
    required this.onSelected,
  }) : assert(items.length > 1);

  @override
  Widget build(BuildContext context) {
    final safePosition = position
        .clamp(
          0.0,
          (items.length - 1).toDouble(),
        )
        .toDouble();

    return SafeArea(
      // Status bar safety is handled
      // by the page itself.
      top: false,

      // This automatically adds the
      // system navigation / gesture inset.
      minimum: const EdgeInsets.fromLTRB(
        12,
        0,
        12,
        8,
      ),

      child: RepaintBoundary(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(
              alpha: 0.98,
            ),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(
              color: AppColors.border.withValues(
                alpha: 0.9,
              ),
            ),
            boxShadow: AppShadows.elevated,
          ),

          // Controlled navigation height.
          // It never depends on screen height.
          child: SizedBox(
            height: barHeight,
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: LayoutBuilder(
                builder: (
                  context,
                  constraints,
                ) {
                  final itemWidth = constraints.maxWidth / items.length;

                  return Stack(
                    // Stack itself receives a
                    // guaranteed finite 60px area.
                    fit: StackFit.expand,

                    clipBehavior: Clip.none,

                    children: [
                      // Smooth purple selection.
                      Positioned(
                        left: itemWidth * safePosition,
                        top: 0,
                        bottom: 0,
                        width: itemWidth,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 2,
                          ),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: AppColors.primarySoft,
                              borderRadius: BorderRadius.circular(
                                19,
                              ),
                              border: Border.all(
                                color: AppColors.primary.withValues(
                                  alpha: 0.08,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      Positioned.fill(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: List.generate(
                            items.length,
                            (index) {
                              return Expanded(
                                child: _NavigationButton(
                                  key: ValueKey(
                                    'bottom-nav-$index',
                                  ),
                                  item: items[index],
                                  selected: index == currentIndex,
                                  onTap: () {
                                    onSelected(
                                      index,
                                    );
                                  },
                                ),
                              );
                            },
                          ),
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
  final VoidCallback onTap;

  const _NavigationButton({
    super.key,
    required this.item,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppPressable(
      onTap: onTap,
      pressedScale: 0.96,
      borderRadius: BorderRadius.circular(18),
      child: Semantics(
        selected: selected,
        button: true,
        label: item.label,

        // IMPORTANT:
        // This is a finite height.
        //
        // There is NO SizedBox.expand().
        child: SizedBox(
          height: 60,
          child: Center(
            child: Column(
              // IMPORTANT:
              // The Column only uses the space
              // its children need.
              mainAxisSize: MainAxisSize.min,

              mainAxisAlignment: MainAxisAlignment.center,

              children: [
                AnimatedSwitcher(
                  duration: const Duration(
                    milliseconds: 220,
                  ),
                  switchInCurve: Curves.easeOutBack,
                  switchOutCurve: Curves.easeInCubic,
                  transitionBuilder: (
                    child,
                    animation,
                  ) {
                    return FadeTransition(
                      opacity: animation,
                      child: ScaleTransition(
                        scale: Tween<double>(
                          begin: 0.82,
                          end: 1,
                        ).animate(
                          animation,
                        ),
                        child: child,
                      ),
                    );
                  },
                  child: Icon(
                    selected ? item.selectedIcon : item.icon,
                    key: ValueKey(
                      '${item.label}-$selected',
                    ),
                    size: 22,
                    color:
                        selected ? AppColors.primary : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(
                  height: 3,
                ),
                ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxHeight: 16,
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(
                        milliseconds: 220,
                      ),
                      curve: Curves.easeOutCubic,
                      style: TextStyle(
                        color: selected
                            ? AppColors.primary
                            : AppColors.textSecondary,
                        fontSize: 10.5,
                        fontWeight:
                            selected ? FontWeight.w800 : FontWeight.w600,
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
