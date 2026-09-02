import 'package:flutter/material.dart';

import '../../../core/widgets/app_icon_button.dart';
import '../notification_controller.dart';

class NotificationBadgeIcon extends StatelessWidget {
  final VoidCallback onTap;

  const NotificationBadgeIcon({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final controller = NotificationController.instance;
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final count = controller.unreadCount;
        return AppIconButton(
          icon: count > 0 ? Icons.notifications_rounded : Icons.notifications_none_rounded,
          showBadge: count > 0,
          badgeText: count > 99 ? '99+' : '$count',
          onTap: onTap,
        );
      },
    );
  }
}
