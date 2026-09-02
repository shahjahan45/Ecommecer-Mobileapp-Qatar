import 'package:flutter/foundation.dart';

import '../../data/demo_notifications.dart';
import '../../models/app_notification.dart';

class NotificationController extends ChangeNotifier {
  NotificationController._() : _items = DemoNotifications.seed();

  static final NotificationController instance = NotificationController._();

  List<AppNotification> _items;
  bool orderUpdatesEnabled = true;
  bool paymentUpdatesEnabled = true;
  bool offersEnabled = true;
  bool accountUpdatesEnabled = true;

  List<AppNotification> get items => List.unmodifiable(_items);
  int get unreadCount => _items.where((item) => !item.isRead).length;

  List<AppNotification> filtered(AppNotificationType? type) => type == null
      ? items
      : List.unmodifiable(_items.where((item) => item.type == type));

  void markRead(String id) {
    final index = _items.indexWhere((item) => item.id == id);
    if (index < 0 || _items[index].isRead) return;
    _items[index] = _items[index].copyWith(isRead: true);
    notifyListeners();
  }

  void markAllRead() {
    if (unreadCount == 0) return;
    _items = _items.map((item) => item.copyWith(isRead: true)).toList();
    notifyListeners();
  }

  void dismiss(String id) {
    _items.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  void addOrderConfirmation({required String orderId, required DateTime placedAt}) {
    if (!orderUpdatesEnabled) return;
    _items.insert(
      0,
      AppNotification(
        id: 'order-confirmed-${placedAt.microsecondsSinceEpoch}',
        type: AppNotificationType.order,
        title: 'Order confirmed',
        message: '$orderId has been placed successfully. We will keep you updated here.',
        createdAt: placedAt,
        orderId: orderId,
      ),
    );
    notifyListeners();
  }

  void updatePreference(AppNotificationType type, bool enabled) {
    switch (type) {
      case AppNotificationType.order:
        orderUpdatesEnabled = enabled;
        break;
      case AppNotificationType.payment:
        paymentUpdatesEnabled = enabled;
        break;
      case AppNotificationType.promotion:
        offersEnabled = enabled;
        break;
      case AppNotificationType.account:
        accountUpdatesEnabled = enabled;
        break;
    }
    notifyListeners();
  }

  bool preferenceFor(AppNotificationType type) {
    switch (type) {
      case AppNotificationType.order:
        return orderUpdatesEnabled;
      case AppNotificationType.payment:
        return paymentUpdatesEnabled;
      case AppNotificationType.promotion:
        return offersEnabled;
      case AppNotificationType.account:
        return accountUpdatesEnabled;
    }
  }

  @visibleForTesting
  void resetForTesting() {
    _items = DemoNotifications.seed();
    orderUpdatesEnabled = true;
    paymentUpdatesEnabled = true;
    offersEnabled = true;
    accountUpdatesEnabled = true;
    notifyListeners();
  }
}
