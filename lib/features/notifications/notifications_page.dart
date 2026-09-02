import 'package:flutter/material.dart';

import '../../core/design_system/app_tokens.dart';
import '../../core/navigation/app_page_route.dart';
import '../../data/demo_orders.dart';
import '../../models/app_notification.dart';
import '../orders/order_details_page.dart';
import 'notification_controller.dart';
import 'notification_preferences_page.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  AppNotificationType? _filter;

  @override
  Widget build(BuildContext context) {
    final controller = NotificationController.instance;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(
            tooltip: 'Notification preferences',
            onPressed: () => Navigator.of(context).push(
              AppPageRoute(page: const NotificationPreferencesPage()),
            ),
            icon: const Icon(Icons.tune_rounded),
          ),
          AnimatedBuilder(
            animation: controller,
            builder: (context, _) => TextButton(
              onPressed: controller.unreadCount == 0 ? null : controller.markAllRead,
              child: const Text('Mark all read'),
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          final items = controller.filtered(_filter);
          return CustomScrollView(
            key: const PageStorageKey<String>('notifications-scroll'),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                sliver: SliverToBoxAdapter(
                  child: _FilterRail(
                    selected: _filter,
                    onChanged: (value) => setState(() => _filter = value),
                  ),
                ),
              ),
              if (items.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'No notifications in this category yet.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(
                    16,
                    4,
                    16,
                    MediaQuery.paddingOf(context).bottom + 28,
                  ),
                  sliver: SliverList.separated(
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return Dismissible(
                        key: ValueKey(item.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.errorContainer,
                            borderRadius: BorderRadius.circular(AppRadius.lg),
                          ),
                          padding: const EdgeInsets.only(right: 20),
                          alignment: Alignment.centerRight,
                          child: Icon(
                            Icons.delete_outline_rounded,
                            color: Theme.of(context).colorScheme.onErrorContainer,
                          ),
                        ),
                        onDismissed: (_) => controller.dismiss(item.id),
                        child: _NotificationCard(
                          item: item,
                          onTap: () => _openNotification(context, item),
                        ),
                      );
                    },
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  void _openNotification(BuildContext context, AppNotification item) {
    NotificationController.instance.markRead(item.id);
    if (item.orderId == null) return;
    final matches = DemoOrders.orders.where((order) => order.id == item.orderId);
    if (matches.isEmpty || !mounted) return;
    Navigator.of(context).push(
      AppPageRoute(page: OrderDetailsPage(order: matches.first)),
    );
  }
}

class _FilterRail extends StatelessWidget {
  final AppNotificationType? selected;
  final ValueChanged<AppNotificationType?> onChanged;

  const _FilterRail({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _FilterChip(label: 'All', selected: selected == null, onTap: () => onChanged(null)),
          const SizedBox(width: 8),
          ...AppNotificationType.values.expand((type) => [
                _FilterChip(
                  label: type.label,
                  selected: selected == type,
                  onTap: () => onChanged(type),
                ),
                const SizedBox(width: 8),
              ]),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(label: Text(label), selected: selected, onSelected: (_) => onTap());
  }
}

class _NotificationCard extends StatelessWidget {
  final AppNotification item;
  final VoidCallback onTap;

  const _NotificationCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final unread = !item.isRead;
    return Semantics(
      button: true,
      label: '${item.title}. ${unread ? 'Unread notification' : 'Read notification'}',
      child: Material(
        color: unread ? scheme.primaryContainer.withValues(alpha: .34) : scheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: BorderSide(color: unread ? scheme.primary.withValues(alpha: .24) : scheme.outlineVariant),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(13),
                  ),
                  alignment: Alignment.center,
                  child: Icon(item.type.icon, color: scheme.primary, size: 21),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              item.title,
                              style: TextStyle(
                                color: scheme.onSurface,
                                fontSize: 13.5,
                                fontWeight: unread ? FontWeight.w900 : FontWeight.w800,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _relativeTime(item.createdAt),
                            style: TextStyle(
                              color: scheme.onSurfaceVariant,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(
                        item.message,
                        style: TextStyle(
                          color: scheme.onSurfaceVariant,
                          fontSize: 11.5,
                          height: 1.45,
                        ),
                      ),
                      if (item.orderId != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          'View order',
                          style: TextStyle(
                            color: scheme.primary,
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (unread) ...[
                  const SizedBox(width: 8),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(color: scheme.primary, shape: BoxShape.circle),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _relativeTime(DateTime value) {
    final now = DateTime(2026, 9, 1, 19, 42);
    final difference = now.difference(value);
    if (difference.inMinutes < 60) return '${difference.inMinutes}m';
    if (difference.inHours < 24) return '${difference.inHours}h';
    return '${difference.inDays}d';
  }
}
