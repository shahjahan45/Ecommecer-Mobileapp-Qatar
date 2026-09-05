import 'package:flutter/material.dart';

import '../../../core/design_system/app_tokens.dart';
import '../../../core/persistence/customer_session_persistence.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme_context.dart';

class ShoppingContinuityCard extends StatelessWidget {
  final CustomerSessionPersistence persistence;

  const ShoppingContinuityCard({
    super.key,
    required this.persistence,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = context.dcxScheme;
    final status = _statusText();
    final statusColor = persistence.lastError == null
        ? AppColors.success
        : AppColors.warning;

    return Material(
      key: const Key('shopping-continuity-card'),
      color: scheme.surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: BorderSide(color: scheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final details = Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: scheme.primaryContainer,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.offline_pin_outlined,
                    color: scheme.primary,
                    size: 23,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Shopping continuity',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w900,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Cart, wishlist, notification choices, support activity and recent orders can resume on this device.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                              height: 1.45,
                            ),
                      ),
                      const SizedBox(height: 9),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            decoration: BoxDecoration(
                              color: statusColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 7),
                          Flexible(
                            child: Text(
                              status,
                              key: const Key('shopping-continuity-status'),
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                    color: statusColor,
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            );

            final saveButton = OutlinedButton.icon(
              key: const Key('shopping-continuity-save-now'),
              onPressed: persistence.isSaving ? null : persistence.save,
              icon: persistence.isSaving
                  ? const SizedBox(
                      width: 15,
                      height: 15,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save_outlined, size: 18),
              label: Text(persistence.isSaving ? 'Saving' : 'Save now'),
            );

            if (constraints.maxWidth < 520) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  details,
                  const SizedBox(height: 14),
                  Align(alignment: Alignment.centerRight, child: saveButton),
                ],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(child: details),
                const SizedBox(width: 18),
                saveButton,
              ],
            );
          },
        ),
      ),
    );
  }

  String _statusText() {
    if (!persistence.isLoaded) return 'Preparing local session';
    if (persistence.isSaving) return 'Saving on this device';
    if (persistence.lastError != null) return 'Using this session in memory';
    final savedAt = persistence.lastSavedAt;
    if (savedAt == null) return 'Ready to resume after restart';
    final hour = savedAt.hour == 0
        ? 12
        : savedAt.hour > 12
            ? savedAt.hour - 12
            : savedAt.hour;
    final minute = savedAt.minute.toString().padLeft(2, '0');
    final period = savedAt.hour >= 12 ? 'PM' : 'AM';
    return 'Saved at $hour:$minute $period';
  }
}
