import 'package:ecommerce_mobile/data/demo_catalog.dart';
import 'package:ecommerce_mobile/features/wishlist/wishlist_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final wishlist = WishlistController.instance;

  setUp(wishlist.resetToDemoDefaults);
  tearDown(wishlist.resetToDemoDefaults);

  test('toggle synchronizes wishlist membership', () {
    final product = DemoCatalog.products.first;
    expect(wishlist.contains(product), isFalse);

    expect(wishlist.toggle(product), isTrue);
    expect(wishlist.contains(product), isTrue);

    expect(wishlist.toggle(product), isFalse);
    expect(wishlist.contains(product), isFalse);
  });

  test('wishlist filters in-stock and sale products', () {
    final inStock = wishlist.visibleProducts(filter: WishlistFilter.inStock);
    final onSale = wishlist.visibleProducts(filter: WishlistFilter.onSale);

    expect(inStock.every((product) => product.inStock), isTrue);
    expect(onSale.every((product) => product.onSale), isTrue);
  });

  test('clear and restore round trip keeps saved products', () {
    final before = wishlist.products.map((product) => product.id).toSet();
    final snapshot = wishlist.clear();

    expect(wishlist.isEmpty, isTrue);
    expect(snapshot, before);

    wishlist.restore(snapshot);
    expect(wishlist.products.map((product) => product.id).toSet(), before);
  });
}
