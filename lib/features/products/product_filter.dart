class ProductFilter {
  final double minPrice;
  final double maxPrice;
  final double minRating;
  final bool inStockOnly;
  final bool onSaleOnly;

  const ProductFilter({
    this.minPrice = 0,
    this.maxPrice = 500,
    this.minRating = 0,
    this.inStockOnly = false,
    this.onSaleOnly = false,
  });

  ProductFilter copyWith({
    double? minPrice,
    double? maxPrice,
    double? minRating,
    bool? inStockOnly,
    bool? onSaleOnly,
  }) {
    return ProductFilter(
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      minRating: minRating ?? this.minRating,
      inStockOnly: inStockOnly ?? this.inStockOnly,
      onSaleOnly: onSaleOnly ?? this.onSaleOnly,
    );
  }

  int get activeCount {
    var count = 0;
    if (minPrice > 0 || maxPrice < 500) count++;
    if (minRating > 0) count++;
    if (inStockOnly) count++;
    if (onSaleOnly) count++;
    return count;
  }
}
