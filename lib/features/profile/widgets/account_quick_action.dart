import 'package:flutter/material.dart';

import '../../../core/design_system/app_tokens.dart';

class AccountQuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final String supportingText;
  final Color color;
  final Color softColor;
  final VoidCallback onTap;

  const AccountQuickAction({
    super.key,
    required this.icon,
    required this.label,
    required this.supportingText,
    required this.color,
    required this.softColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final iconSurface = dark
        ? Color.alphaBlend(color.withValues(alpha: .16), scheme.surfaceContainer)
        : softColor;

    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 170;
              final padding = compact ? 12.0 : 14.0;
              final iconBox = compact ? 36.0 : 38.0;

              return Container(
                constraints: const BoxConstraints(minHeight: 112),
                padding: EdgeInsets.all(padding),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(color: scheme.outlineVariant),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        SizedBox(
                          width: iconBox,
                          height: iconBox,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: iconSurface,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(icon, color: color, size: compact ? 19 : 20),
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          Icons.arrow_outward_rounded,
                          color: scheme.onSurfaceVariant.withValues(alpha: .62),
                          size: compact ? 16 : 18,
                        ),
                      ],
                    ),
                    SizedBox(height: compact ? 10 : 12),
                    Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: scheme.onSurface,
                        fontSize: compact ? 12.5 : 13,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      supportingText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: scheme.onSurfaceVariant,
                        fontSize: compact ? 10 : 10.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
