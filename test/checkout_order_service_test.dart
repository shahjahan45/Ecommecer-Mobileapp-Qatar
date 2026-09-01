import 'package:ecommerce_mobile/data/demo_orders.dart';
import 'package:ecommerce_mobile/features/cart/cart_controller.dart';
import 'package:ecommerce_mobile/features/checkout/checkout_order_service.dart';
import 'package:ecommerce_mobile/models/payment.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final cart = CartController.instance;
  late int initialOrders;

  setUp(() {
    cart.resetForTesting(withDemoItems: true);
    initialOrders = DemoOrders.orders.length;
  });

  tearDown(() {
    cart.resetForTesting();
    while (DemoOrders.orders.length > initialOrders) {
      DemoOrders.orders.removeAt(0);
    }
  });

  test('placing an order snapshots cart, promo, payment and clears cart', () {
    expect(cart.applyPromotion('WELCOME10').applied, isTrue);
    final expectedTotal = cart.total;

    const payment = PaymentAuthorizationResult(
      method: CheckoutPaymentMethod.card,
      status: CheckoutPaymentStatus.paid,
      reference: 'CARD-TEST-01',
      message: 'Authorized',
    );

    final order = CheckoutOrderService.placeOrder(
      cart: cart,
      deliveryAddress: 'Test Customer • 55512345 • Doha, Qatar',
      deliveryMethod: 'Standard delivery',
      payment: payment,
      placedAt: DateTime(2026, 9, 1, 18, 30),
    );

    expect(order.id, startsWith('DCX-260901-'));
    expect(order.paymentStatus, CheckoutPaymentStatus.paid);
    expect(order.paymentReference, 'CARD-TEST-01');
    expect(order.promotionCode, 'WELCOME10');
    expect(order.total, expectedTotal);
    expect(order.items, isNotEmpty);
    expect(cart.isEmpty, isTrue);
    expect(DemoOrders.orders.first.id, order.id);
  });

  test('empty cart cannot create an order', () {
    cart.resetForTesting();

    const payment = PaymentAuthorizationResult(
      method: CheckoutPaymentMethod.cashOnDelivery,
      status: CheckoutPaymentStatus.payOnDelivery,
      reference: 'COD-TEST',
      message: 'Confirmed',
    );

    expect(
      () => CheckoutOrderService.placeOrder(
        cart: cart,
        deliveryAddress: 'Doha, Qatar',
        deliveryMethod: 'Standard delivery',
        payment: payment,
      ),
      throwsStateError,
    );
  });
}
