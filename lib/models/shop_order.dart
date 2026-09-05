import 'payment.dart';
import 'product.dart';

enum ShopOrderStatus {
  processing,
  packed,
  shipped,
  outForDelivery,
  delivered,
  cancelled,
}

class ShopOrderItem {
  final Product product;
  final int quantity;
  final String? variant;
  final double unitPrice;

  ShopOrderItem({
    required this.product,
    required this.quantity,
    this.variant,
    double? unitPrice,
  }) : unitPrice = unitPrice ?? product.price;

  double get lineTotal => unitPrice * quantity;
}

class ShippingEvent {
  final String title;
  final String description;
  final String timestamp;
  final bool completed;

  const ShippingEvent({
    required this.title,
    required this.description,
    required this.timestamp,
    this.completed = true,
  });
}

class ShopOrder {
  final String id;
  final DateTime placedAt;
  final ShopOrderStatus status;
  final List<ShopOrderItem> items;
  final double deliveryFee;
  final double discount;
  final String deliveryLabel;
  final String deliveryWindow;
  final String carrier;
  final String trackingNumber;
  final String deliveryAddress;
  final String paymentMethod;
  final CheckoutPaymentStatus paymentStatus;
  final String? paymentReference;
  final String? promotionCode;
  final List<ShippingEvent> shippingHistory;

  const ShopOrder({
    required this.id,
    required this.placedAt,
    required this.status,
    required this.items,
    required this.deliveryFee,
    this.discount = 0,
    required this.deliveryLabel,
    required this.deliveryWindow,
    required this.carrier,
    required this.trackingNumber,
    required this.deliveryAddress,
    required this.paymentMethod,
    this.paymentStatus = CheckoutPaymentStatus.payOnDelivery,
    this.paymentReference,
    this.promotionCode,
    this.shippingHistory = const [],
  });

  int get totalQuantity => items.fold<int>(
        0,
        (total, item) => total + item.quantity,
      );

  double get subtotal => items.fold<double>(
        0,
        (total, item) => total + item.lineTotal,
      );

  double get total => subtotal + deliveryFee - discount;

  bool get isActive => status != ShopOrderStatus.delivered && status != ShopOrderStatus.cancelled;
  bool get isDelivered => status == ShopOrderStatus.delivered;
  bool get isCancelled => status == ShopOrderStatus.cancelled;
}

extension ShopOrderStatusUi on ShopOrderStatus {
  String get label {
    switch (this) {
      case ShopOrderStatus.processing:
        return 'Processing';
      case ShopOrderStatus.packed:
        return 'Packed';
      case ShopOrderStatus.shipped:
        return 'Shipped';
      case ShopOrderStatus.outForDelivery:
        return 'Out for delivery';
      case ShopOrderStatus.delivered:
        return 'Delivered';
      case ShopOrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  int get progressIndex {
    switch (this) {
      case ShopOrderStatus.processing:
        return 0;
      case ShopOrderStatus.packed:
        return 1;
      case ShopOrderStatus.shipped:
        return 2;
      case ShopOrderStatus.outForDelivery:
        return 3;
      case ShopOrderStatus.delivered:
        return 4;
      case ShopOrderStatus.cancelled:
        return 0;
    }
  }
}
