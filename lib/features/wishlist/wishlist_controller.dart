import 'package:flutter/foundation.dart';

import '../../data/demo_catalog.dart';
import '../../models/product.dart';

enum WishlistFilter {
  all,
  inStock,
  onSale,
}

class WishlistController extends ChangeNotifier {
  WishlistController._()
      : _productIds = DemoCatalog.products
            .where((product) => product.favorite)
            .map((product) => product.id)
            .toSet();

  static final WishlistController instance = WishlistController._();

  final Set<int> _productIds;

  int get count => _productIds.length;

  bool get isEmpty => _productIds.isEmpty;

  bool contains(Product product) => _productIds.contains(product.id);

  List<Product> get products => DemoCatalog.products
      .where((product) => _productIds.contains(product.id))
      .toList(growable: false);

  double get totalSavings => products.fold<double>(
        0,
        (total, product) =>
            total + ((product.oldPrice ?? product.price) - product.price),
      );

  bool toggle(Product product) {
    if (_productIds.contains(product.id)) {
      _productIds.remove(product.id);
      notifyListeners();
      return false;
    }

    _productIds.add(product.id);
    notifyListeners();
    return true;
  }

  bool add(Product product) {
    final changed = _productIds.add(product.id);
    if (changed) notifyListeners();
    return changed;
  }

  bool remove(Product product) {
    final changed = _productIds.remove(product.id);
    if (changed) notifyListeners();
    return changed;
  }

  Set<int> clear() {
    final previous = Set<int>.from(_productIds);
    if (_productIds.isEmpty) return previous;

    _productIds.clear();
    notifyListeners();
    return previous;
  }

  void restore(Set<int> productIds) {
    _productIds
      ..clear()
      ..addAll(productIds);
    notifyListeners();
  }

  List<Product> visibleProducts({
    required WishlistFilter filter,
    String query = '',
  }) {
    final normalizedQuery = query.trim().toLowerCase();

    return products.where((product) {
      final matchesFilter = switch (filter) {
        WishlistFilter.all => true,
        WishlistFilter.inStock => product.inStock,
        WishlistFilter.onSale => product.onSale,
      };

      if (!matchesFilter) return false;
      if (normalizedQuery.isEmpty) return true;

      return product.searchableText.contains(normalizedQuery);
    }).toList(growable: false);
  }

  @visibleForTesting
  void resetToDemoDefaults() {
    _productIds
      ..clear()
      ..addAll(
        DemoCatalog.products
            .where((product) => product.favorite)
            .map((product) => product.id),
      );
    notifyListeners();
  }
}
