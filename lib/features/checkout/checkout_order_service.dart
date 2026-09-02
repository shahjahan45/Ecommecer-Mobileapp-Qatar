import '../../data/demo_orders.dart';
import '../../models/payment.dart';
import '../../models/shop_order.dart';
import '../cart/cart_controller.dart';
import '../notifications/notification_controller.dart';

class CheckoutOrderService {
  CheckoutOrderService._();

  static ShopOrder placeOrder({
    required CartController cart,
    required String deliveryAddress,
    required String deliveryMethod,
    required PaymentAuthorizationResult payment,
    DateTime? placedAt,
  }) {
    if (cart.isEmpty) {
      throw StateError('Cannot place an order with an empty cart.');
    }
    if (!payment.succeeded) {
      throw StateError('Cannot place an order after a failed payment.');
    }

    final now = placedAt ?? DateTime.now();
    final cartItems = cart.items;
    final promotionCode = cart.appliedPromotion?.code;
    final order = ShopOrder(
      id: _orderId(now),
      placedAt: now,
      status: ShopOrderStatus.processing,
      items: cartItems
          .map(
            (item) => ShopOrderItem(
              product: item.product,
              quantity: item.quantity,
              variant: item.variant,
            ),
          )
          .toList(growable: false),
      deliveryFee: cart.deliveryFee,
      discount: cart.promotionDiscount,
      deliveryLabel: 'Order confirmed',
      deliveryWindow: deliveryMethod == 'Priority delivery'
          ? 'Priority delivery selected'
          : 'Standard delivery selected',
      carrier: 'DCX Express',
      trackingNumber: 'Pending assignment',
      deliveryAddress: deliveryAddress,
      paymentMethod: payment.method.label,
      paymentStatus: payment.status,
      paymentReference: payment.reference,
      promotionCode: promotionCode,
      shippingHistory: <ShippingEvent>[
        ShippingEvent(
          title: 'Order confirmed',
          description: payment.status == CheckoutPaymentStatus.awaitingTransfer
              ? 'Your order is confirmed and awaiting bank transfer.'
              : 'We received your order successfully.',
          timestamp: _timestamp(now),
        ),
      ],
    );

    DemoOrders.orders.insert(0, order);
    NotificationController.instance.addOrderConfirmation(
      orderId: order.id,
      placedAt: now,
    );
    cart.clear();
    return order;
  }

  static String _orderId(DateTime value) {
    String two(int input) => input.toString().padLeft(2, '0');
    final date = '${two(value.year % 100)}${two(value.month)}${two(value.day)}';
    final suffix = (value.millisecondsSinceEpoch % 10000).toString().padLeft(4, '0');
    return 'DCX-$date-$suffix';
  }

  static String _timestamp(DateTime value) {
    final hour = value.hour == 0 ? 12 : (value.hour > 12 ? value.hour - 12 : value.hour);
    final minute = value.minute.toString().padLeft(2, '0');
    final period = value.hour >= 12 ? 'PM' : 'AM';
    return 'Today, $hour:$minute $period';
  }
}
