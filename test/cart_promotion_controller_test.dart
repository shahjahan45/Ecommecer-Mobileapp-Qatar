import 'package:ecommerce_mobile/data/demo_catalog.dart';
import 'package:ecommerce_mobile/features/cart/cart_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final cart = CartController.instance;

  setUp(cart.resetForTesting);
  tearDown(cart.resetForTesting);

  test('percentage promotion is case-insensitive and respects its cap', () {
    cart.resetForTesting(withDemoItems: true);

    final result = cart.applyPromotion(' welcome10 ');

    expect(result.applied, isTrue);
    expect(cart.appliedPromotion?.code, 'WELCOME10');
    expect(cart.promotionDiscount, 50);
    expect(cart.promotionSavings, 50);
    expect(cart.total, cart.subtotal - 50 + cart.deliveryFee);
  });

  test('fixed promotion enforces minimum basket value', () {
    final product = DemoCatalog.products.firstWhere((item) => item.id == 5);
    cart.add(product);

    final result = cart.applyPromotion('DCX25');

    expect(result.applied, isFalse);
    expect(cart.appliedPromotion, isNull);
    expect(result.message, contains('QAR 200'));
  });

  test('free delivery promotion removes the standard delivery charge', () {
    final product = DemoCatalog.products.firstWhere((item) => item.id == 5);
    cart.add(product);

    expect(cart.baseDeliveryFee, CartController.standardDeliveryFee);
    expect(cart.deliveryFee, CartController.standardDeliveryFee);

    final result = cart.applyPromotion('FREESHIP');

    expect(result.applied, isTrue);
    expect(cart.deliveryFee, 0);
    expect(
      cart.promotionDeliverySaving,
      CartController.standardDeliveryFee,
    );
    expect(cart.total, cart.subtotal);
  });

  test('promotion is removed when basket no longer meets eligibility', () {
    final product = DemoCatalog.products.firstWhere((item) => item.id == 5);
    cart.add(product, quantity: 2);
    expect(cart.subtotal, greaterThanOrEqualTo(200));
    expect(cart.applyPromotion('DCX25').applied, isTrue);

    final key = cart.keyFor(product);
    cart.setQuantity(key, 1);

    expect(cart.appliedPromotion, isNull);
    expect(cart.promotionDiscount, 0);
  });

  test('unknown promotion does not change totals', () {
    cart.resetForTesting(withDemoItems: true);
    final before = cart.total;

    final result = cart.applyPromotion('NOT-A-CODE');

    expect(result.applied, isFalse);
    expect(cart.appliedPromotion, isNull);
    expect(cart.total, before);
  });
}
