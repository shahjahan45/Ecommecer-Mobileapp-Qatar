import 'package:flutter_test/flutter_test.dart';
import 'package:ecommerce_mobile/features/notifications/notification_controller.dart';
import 'package:ecommerce_mobile/models/app_notification.dart';

void main() {
  final controller = NotificationController.instance;

  setUp(controller.resetForTesting);

  test('notification center tracks unread state and preferences', () {
    expect(controller.unreadCount, 2);

    final firstUnread = controller.items.firstWhere((item) => !item.isRead);
    controller.markRead(firstUnread.id);
    expect(controller.unreadCount, 1);

    controller.markAllRead();
    expect(controller.unreadCount, 0);

    controller.updatePreference(AppNotificationType.promotion, false);
    expect(controller.preferenceFor(AppNotificationType.promotion), isFalse);
  });

  test('order confirmation creates a new unread notification', () {
    final before = controller.items.length;
    controller.addOrderConfirmation(
      orderId: 'DCX-TEST-1001',
      placedAt: DateTime(2026, 9, 1, 19, 0),
    );

    expect(controller.items.length, before + 1);
    expect(controller.items.first.orderId, 'DCX-TEST-1001');
    expect(controller.items.first.isRead, isFalse);
  });
}
