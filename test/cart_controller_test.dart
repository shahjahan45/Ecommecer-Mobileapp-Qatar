import 'package:ecommerce_mobile/data/demo_catalog.dart';
import 'package:ecommerce_mobile/features/cart/cart_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final cart = CartController.instance;

  setUp(cart.resetForTesting);
  tearDown(cart.resetForTesting);

  test('add merges identical product and respects stock limit', () {
    final product = DemoCatalog.products.first;

    expect(cart.isEmpty, isTrue);
    cart.add(product, quantity: 2);
    cart.add(product, quantity: 3);

    expect(cart.itemCount, 1);
    expect(cart.quantityFor(product), 5);

    cart.add(product, quantity: product.stockQuantity + 20);
    expect(cart.quantityFor(product), product.stockQuantity);
  });

  test('different variants remain separate cart lines', () {
    final product = DemoCatalog.products.firstWhere(
      (item) => item.category == 'Sports',
    );

    cart.add(product, variant: '39');
    cart.add(product, variant: '40');

    expect(cart.itemCount, 2);
    expect(cart.quantityFor(product, variant: '39'), 1);
    expect(cart.quantityFor(product, variant: '40'), 1);
  });

  test('remove and restore preserve a cart item', () {
    final product = DemoCatalog.products.first;
    cart.add(product, quantity: 2);
    final key = cart.keyFor(product);

    final removed = cart.remove(key);
    expect(removed, isNotNull);
    expect(cart.isEmpty, isTrue);

    cart.restore(removed!);
    expect(cart.quantityFor(product), 2);
  });

  test('totals and free-delivery state stay consistent', () {
    cart.resetForTesting(withDemoItems: true);

    expect(cart.subtotal, greaterThan(0));
    expect(cart.total, cart.subtotal + cart.deliveryFee);
    expect(cart.totalQuantity, 3);
    expect(cart.totalSavings, greaterThanOrEqualTo(0));
  });
}
