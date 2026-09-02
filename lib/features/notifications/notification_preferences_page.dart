import 'package:flutter/material.dart';

import '../../core/design_system/app_tokens.dart';
import '../../models/app_notification.dart';
import 'notification_controller.dart';

class NotificationPreferencesPage extends StatelessWidget {
  const NotificationPreferencesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = NotificationController.instance;
    return Scaffold(
      appBar: AppBar(title: const Text('Notification preferences')),
      body: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          return ListView(
            key: const PageStorageKey<String>('notification-preferences-scroll'),
            padding: EdgeInsets.fromLTRB(
              16,
              10,
              16,
              MediaQuery.paddingOf(context).bottom + 28,
            ),
            children: [
              Text(
                'Choose what you want to hear about',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 6),
              Text(
                'These controls are ready to map to push, email, or backend preferences later.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 18),
              ...AppNotificationType.values.map((type) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _PreferenceTile(
                      type: type,
                      value: controller.preferenceFor(type),
                      onChanged: (value) => controller.updatePreference(type, value),
                    ),
                  )),
            ],
          );
        },
      ),
    );
  }
}

class _PreferenceTile extends StatelessWidget {
  final AppNotificationType type;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _PreferenceTile({required this.type, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: SwitchListTile.adaptive(
        key: ValueKey('notification-preference-${type.name}'),
        value: value,
        onChanged: onChanged,
        secondary: Icon(type.icon, color: scheme.primary),
        title: Text(type.label, style: const TextStyle(fontWeight: FontWeight.w800)),
        subtitle: Text(_subtitle(type)),
      ),
    );
  }

  String _subtitle(AppNotificationType type) {
    switch (type) {
      case AppNotificationType.order:
        return 'Order confirmation, packing, shipping, and delivery.';
      case AppNotificationType.payment:
        return 'Payment confirmations and transfer reminders.';
      case AppNotificationType.promotion:
        return 'Promo codes, seasonal offers, and savings.';
      case AppNotificationType.account:
        return 'Security and important account information.';
    }
  }
}
