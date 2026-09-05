import 'product.dart';

class CartItem {
  final String key;
  final Product product;
  final int quantity;
  final String? variant;

  const CartItem({
    required this.key,
    required this.product,
    required this.quantity,
    this.variant,
  });

  double get lineTotal => product.price * quantity;

  double get lineSavings {
    final regularPrice = product.oldPrice ?? product.price;
    return (regularPrice - product.price) * quantity;
  }

  CartItem copyWith({
    Product? product,
    int? quantity,
  }) {
    return CartItem(
      key: key,
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      variant: variant,
    );
  }
}
