import 'package:flutter/foundation.dart';

import '../../data/demo_catalog.dart';
import '../../data/demo_promotions.dart';
import '../../models/cart_item.dart';
import '../../models/product.dart';
import '../../models/promotion.dart';

class CartController extends ChangeNotifier {
  CartController._();

  static final CartController instance = CartController._();

  static const double freeDeliveryThreshold = 200;
  static const double standardDeliveryFee = 15;

  final Map<String, CartItem> _items = <String, CartItem>{};
  Promotion? _appliedPromotion;

  List<CartItem> get items => List<CartItem>.unmodifiable(_items.values);

  bool get isEmpty => _items.isEmpty;

  int get itemCount => _items.length;

  int get totalQuantity => _items.values.fold<int>(
        0,
        (total, item) => total + item.quantity,
      );

  double get subtotal => _items.values.fold<double>(
        0,
        (total, item) => total + item.lineTotal,
      );

  double get totalSavings => _items.values.fold<double>(
        0,
        (total, item) => total + item.lineSavings,
      );

  Promotion? get appliedPromotion => _appliedPromotion;

  bool get hasPromotion => _appliedPromotion != null;

  double get promotionDiscount {
    final promotion = _appliedPromotion;
    if (promotion == null || promotion.type == PromotionType.freeDelivery) {
      return 0;
    }
    return promotion.discountFor(subtotal);
  }

  double get baseDeliveryFee {
    if (isEmpty || subtotal >= freeDeliveryThreshold) return 0;
    return standardDeliveryFee;
  }

  bool get _promotionUnlocksDelivery {
    final promotion = _appliedPromotion;
    return promotion != null &&
        promotion.type == PromotionType.freeDelivery &&
        promotion.isEligible(subtotal);
  }

  double get deliveryFee {
    if (_promotionUnlocksDelivery) return 0;
    return baseDeliveryFee;
  }

  double get promotionDeliverySaving {
    if (!_promotionUnlocksDelivery) return 0;
    return baseDeliveryFee;
  }

  double get promotionSavings => promotionDiscount + promotionDeliverySaving;

  double get total {
    final value = subtotal - promotionDiscount + deliveryFee;
    return value < 0 ? 0 : value;
  }

  double get amountToFreeDelivery {
    if (isEmpty ||
        subtotal >= freeDeliveryThreshold ||
        _promotionUnlocksDelivery) {
      return 0;
    }
    return freeDeliveryThreshold - subtotal;
  }

  String keyFor(Product product, {String? variant}) {
    final normalizedVariant = variant?.trim() ?? '';
    return '${product.id}::$normalizedVariant';
  }

  bool contains(Product product, {String? variant}) {
    return _items.containsKey(keyFor(product, variant: variant));
  }

  int quantityFor(Product product, {String? variant}) {
    return _items[keyFor(product, variant: variant)]?.quantity ?? 0;
  }

  int add(
    Product product, {
    int quantity = 1,
    String? variant,
  }) {
    if (!product.inStock || product.stockQuantity <= 0 || quantity <= 0) {
      return quantityFor(product, variant: variant);
    }

    final key = keyFor(product, variant: variant);
    final current = _items[key]?.quantity ?? 0;
    final next = (current + quantity).clamp(1, product.stockQuantity).toInt();

    if (next == current) return current;

    _items[key] = CartItem(
      key: key,
      product: product,
      quantity: next,
      variant: variant,
    );
    _reconcilePromotion();
    notifyListeners();
    return next;
  }

  void setQuantity(String key, int quantity) {
    final item = _items[key];
    if (item == null) return;

    if (quantity <= 0) {
      remove(key);
      return;
    }

    final maxQuantity =
        item.product.stockQuantity > 0 ? item.product.stockQuantity : 1;
    final next = quantity.clamp(1, maxQuantity).toInt();
    if (next == item.quantity) return;

    _items[key] = item.copyWith(quantity: next);
    _reconcilePromotion();
    notifyListeners();
  }

  void increment(String key) {
    final item = _items[key];
    if (item == null) return;
    setQuantity(key, item.quantity + 1);
  }

  void decrement(String key) {
    final item = _items[key];
    if (item == null) return;
    setQuantity(key, item.quantity - 1);
  }

  CartItem? remove(String key) {
    final removed = _items.remove(key);
    if (removed != null) {
      _reconcilePromotion();
      notifyListeners();
    }
    return removed;
  }

  void restore(CartItem item) {
    final safeQuantity = item.quantity
        .clamp(
            1, item.product.stockQuantity > 0 ? item.product.stockQuantity : 1)
        .toInt();
    _items[item.key] = item.copyWith(quantity: safeQuantity);
    _reconcilePromotion();
    notifyListeners();
  }

  List<CartItem> clear() {
    final previous = items;
    if (_items.isEmpty) return previous;
    _items.clear();
    _appliedPromotion = null;
    notifyListeners();
    return previous;
  }

  void restoreAll(Iterable<CartItem> items) {
    _items.clear();
    for (final item in items) {
      final maxQuantity =
          item.product.stockQuantity > 0 ? item.product.stockQuantity : 1;
      _items[item.key] = item.copyWith(
        quantity: item.quantity.clamp(1, maxQuantity).toInt(),
      );
    }
    _reconcilePromotion();
    notifyListeners();
  }

  PromotionApplicationResult applyPromotion(String rawCode) {
    if (isEmpty) {
      return const PromotionApplicationResult(
        applied: false,
        message: 'Add items to your cart before applying a promo code.',
      );
    }

    final normalized = rawCode.trim().toUpperCase();
    if (normalized.isEmpty) {
      return const PromotionApplicationResult(
        applied: false,
        message: 'Enter a promo code to continue.',
      );
    }

    final promotion = DemoPromotions.findByCode(normalized);
    if (promotion == null) {
      return const PromotionApplicationResult(
        applied: false,
        message: 'That promo code is not available.',
      );
    }

    if (!promotion.isEligible(subtotal)) {
      return PromotionApplicationResult(
        applied: false,
        message:
            'Spend QAR ${promotion.minimumSubtotal.toStringAsFixed(0)} to use ${promotion.code}.',
        promotion: promotion,
      );
    }

    _appliedPromotion = promotion;
    notifyListeners();
    return PromotionApplicationResult(
      applied: true,
      message: '${promotion.code} applied successfully.',
      promotion: promotion,
    );
  }

  void removePromotion() {
    if (_appliedPromotion == null) return;
    _appliedPromotion = null;
    notifyListeners();
  }

  void _reconcilePromotion() {
    final promotion = _appliedPromotion;
    if (promotion == null) return;
    if (isEmpty || !promotion.isEligible(subtotal)) {
      _appliedPromotion = null;
    }
  }

  @visibleForTesting
  void resetForTesting({bool withDemoItems = false}) {
    _items.clear();
    _appliedPromotion = null;
    if (withDemoItems) {
      final first = DemoCatalog.products[0];
      final second = DemoCatalog.products[2];
      _items[keyFor(first)] = CartItem(
        key: keyFor(first),
        product: first,
        quantity: 1,
      );
      _items[keyFor(second, variant: '40')] = CartItem(
        key: keyFor(second, variant: '40'),
        product: second,
        quantity: 2,
        variant: '40',
      );
    }
    notifyListeners();
  }
}
