import 'package:flutter/material.dart';

import '../../core/design_system/app_tokens.dart';
import '../../core/theme/theme_controller.dart';

class AppearancePage extends StatelessWidget {
  const AppearancePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = ThemeController.instance;

    return Scaffold(
      key: const Key('appearance-page'),
      appBar: AppBar(title: const Text('Appearance')),
      body: SafeArea(
        top: false,
        child: AnimatedBuilder(
          animation: controller,
          builder: (context, child) {
            final scheme = Theme.of(context).colorScheme;
            return ListView(
              key: const PageStorageKey<String>('appearance-scroll'),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        scheme.primaryContainer,
                        scheme.secondaryContainer.withValues(alpha: .78),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(AppRadius.xl),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          color: scheme.surface.withValues(alpha: .86),
                          borderRadius: BorderRadius.circular(17),
                        ),
                        child: Icon(
                          Theme.of(context).brightness == Brightness.dark
                              ? Icons.dark_mode_rounded
                              : Icons.light_mode_rounded,
                          color: scheme.primary,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Make DCX feel like yours',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w900,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Choose a comfortable theme. System mode follows your device automatically.',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    height: 1.4,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Theme',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: 10),
                for (final option in DcxThemePreference.values) ...[
                  _ThemeOptionCard(
                    option: option,
                    selected: controller.preference == option,
                    onTap: () => controller.setPreference(option),
                  ),
                  if (option != DcxThemePreference.values.last)
                    const SizedBox(height: 10),
                ],
                const SizedBox(height: 24),
                Text(
                  'Preview',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: 10),
                const _ThemePreviewCard(),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(color: scheme.outlineVariant),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.visibility_outlined, color: scheme.primary, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'DCX keeps strong text contrast and large touch targets in both light and dark themes.',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                height: 1.45,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ThemeOptionCard extends StatelessWidget {
  final DcxThemePreference option;
  final bool selected;
  final VoidCallback onTap;

  const _ThemeOptionCard({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  IconData get icon {
    switch (option) {
      case DcxThemePreference.system:
        return Icons.brightness_auto_rounded;
      case DcxThemePreference.light:
        return Icons.light_mode_rounded;
      case DcxThemePreference.dark:
        return Icons.dark_mode_rounded;
    }
  }

  String get subtitle {
    switch (option) {
      case DcxThemePreference.system:
        return 'Automatically match Android or iOS appearance';
      case DcxThemePreference.light:
        return 'Bright, clean surfaces for daytime shopping';
      case DcxThemePreference.dark:
        return 'Low-glare premium surfaces for darker environments';
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      key: ValueKey<String>('appearance-theme-${option.storageValue}'),
      container: true,
      excludeSemantics: true,
      button: true,
      selected: selected,
      label: '${option.label} theme',
      hint: subtitle,
      child: Material(
        color: selected ? scheme.primaryContainer.withValues(alpha: .52) : scheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: AnimatedContainer(
            duration: MediaQuery.disableAnimationsOf(context)
                ? Duration.zero
                : const Duration(milliseconds: 260),
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(
                color: selected ? scheme.primary : scheme.outlineVariant,
                width: selected ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: selected ? scheme.primary : scheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    icon,
                    color: selected ? scheme.onPrimary : scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        option.label,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                            ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontSize: 11.5,
                              height: 1.35,
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  child: selected
                      ? Icon(
                          Icons.check_circle_rounded,
                          key: const ValueKey('selected'),
                          color: scheme.primary,
                        )
                      : Icon(
                          Icons.circle_outlined,
                          key: const ValueKey('not-selected'),
                          color: scheme.outline,
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

class _ThemePreviewCard extends StatelessWidget {
  const _ThemePreviewCard();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(Icons.shopping_bag_outlined, color: scheme.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Premium shopping surface',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Theme changes animate smoothly across the app.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 10,
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 72,
                height: 34,
                decoration: BoxDecoration(
                  color: scheme.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
