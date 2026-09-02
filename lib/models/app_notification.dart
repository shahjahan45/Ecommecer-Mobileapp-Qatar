import 'package:flutter/material.dart';

enum AppNotificationType { order, payment, promotion, account }

class AppNotification {
  final String id;
  final AppNotificationType type;
  final String title;
  final String message;
  final DateTime createdAt;
  final bool isRead;
  final String? orderId;

  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.createdAt,
    this.isRead = false,
    this.orderId,
  });

  AppNotification copyWith({bool? isRead}) => AppNotification(
        id: id,
        type: type,
        title: title,
        message: message,
        createdAt: createdAt,
        isRead: isRead ?? this.isRead,
        orderId: orderId,
      );
}

extension AppNotificationTypeUi on AppNotificationType {
  String get label {
    switch (this) {
      case AppNotificationType.order:
        return 'Orders';
      case AppNotificationType.payment:
        return 'Payments';
      case AppNotificationType.promotion:
        return 'Offers';
      case AppNotificationType.account:
        return 'Account';
    }
  }

  IconData get icon {
    switch (this) {
      case AppNotificationType.order:
        return Icons.local_shipping_outlined;
      case AppNotificationType.payment:
        return Icons.account_balance_wallet_outlined;
      case AppNotificationType.promotion:
        return Icons.local_offer_outlined;
      case AppNotificationType.account:
        return Icons.shield_outlined;
    }
  }
}
