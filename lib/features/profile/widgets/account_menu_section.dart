import 'package:flutter/material.dart';

import '../../../core/design_system/app_tokens.dart';

class AccountMenuSection extends StatelessWidget {
  final String title;
  final List<AccountMenuItem> items;

  const AccountMenuSection({
    super.key,
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 9),
          child: Text(
            title,
            style: TextStyle(
              color: scheme.onSurface,
              fontSize: 14.5,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: scheme.outlineVariant),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: List.generate(items.length, (index) {
              final item = items[index];
              return Column(
                children: [
                  _AccountMenuTile(item: item),
                  if (index != items.length - 1)
                    const Divider(height: 1, indent: 66, endIndent: 14),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }
}

class AccountMenuItem {
  final Key? actionKey;
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final Color softColor;
  final String? trailingLabel;
  final VoidCallback onTap;

  const AccountMenuItem({
    this.actionKey,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.softColor,
    required this.onTap,
    this.trailingLabel,
  });
}

class _AccountMenuTile extends StatelessWidget {
  final AccountMenuItem item;

  const _AccountMenuTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final iconSurface = dark
        ? Color.alphaBlend(item.color.withValues(alpha: .16), scheme.surfaceContainer)
        : item.softColor;

    return Semantics(
      key: item.actionKey,
      button: true,
      label: item.title,
      child: InkWell(
        onTap: item.onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: iconSurface,
                  borderRadius: BorderRadius.circular(13),
                ),
                alignment: Alignment.center,
                child: Icon(item.icon, color: item.color, size: 21),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: scheme.onSurface,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      item.subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: scheme.onSurfaceVariant,
                        fontSize: 11,
                        height: 1.35,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              if (item.trailingLabel != null) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  decoration: BoxDecoration(
                    color: scheme.primaryContainer,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                  child: Text(
                    item.trailingLabel!,
                    style: TextStyle(
                      color: scheme.onPrimaryContainer,
                      fontSize: 9.5,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
              const SizedBox(width: 5),
              Icon(
                Icons.chevron_right_rounded,
                color: scheme.onSurfaceVariant.withValues(alpha: .62),
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
