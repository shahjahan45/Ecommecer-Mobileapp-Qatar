import '../models/app_notification.dart';

class DemoNotifications {
  DemoNotifications._();

  static List<AppNotification> seed() => <AppNotification>[
        AppNotification(
          id: 'notification-order-1',
          type: AppNotificationType.order,
          title: 'Your order is out for delivery',
          message: 'DCX-260829-1048 is on the way and is expected today.',
          createdAt: DateTime(2026, 9, 1, 9, 18),
          orderId: 'DCX-260829-1048',
        ),
        AppNotification(
          id: 'notification-offer-1',
          type: AppNotificationType.promotion,
          title: 'Weekend savings are live',
          message: 'Use WELCOME10 on eligible orders and save up to QAR 50.',
          createdAt: DateTime(2026, 9, 1, 8, 12),
        ),
        AppNotification(
          id: 'notification-payment-1',
          type: AppNotificationType.payment,
          title: 'Card payment confirmed',
          message: 'Payment for DCX-260827-1031 was completed successfully.',
          createdAt: DateTime(2026, 8, 31, 18, 42),
          isRead: true,
          orderId: 'DCX-260827-1031',
        ),
        AppNotification(
          id: 'notification-account-1',
          type: AppNotificationType.account,
          title: 'Your account is ready',
          message: 'Manage delivery addresses, appearance, payments, and security from Account.',
          createdAt: DateTime(2026, 8, 30, 14, 5),
          isRead: true,
        ),
      ];
}
