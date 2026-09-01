enum PromotionType {
  percentage,
  fixedAmount,
  freeDelivery,
}

class Promotion {
  final String code;
  final String title;
  final String description;
  final PromotionType type;
  final double value;
  final double minimumSubtotal;
  final double? maximumDiscount;

  const Promotion({
    required this.code,
    required this.title,
    required this.description,
    required this.type,
    required this.value,
    this.minimumSubtotal = 0,
    this.maximumDiscount,
  });

  bool isEligible(double subtotal) => subtotal >= minimumSubtotal;

  double discountFor(double subtotal) {
    if (!isEligible(subtotal)) return 0;

    switch (type) {
      case PromotionType.percentage:
        final raw = subtotal * (value / 100);
        final cap = maximumDiscount;
        return cap == null ? raw : raw.clamp(0, cap).toDouble();
      case PromotionType.fixedAmount:
        return value.clamp(0, subtotal).toDouble();
      case PromotionType.freeDelivery:
        return 0;
    }
  }
}

class PromotionApplicationResult {
  final bool applied;
  final String message;
  final Promotion? promotion;

  const PromotionApplicationResult({
    required this.applied,
    required this.message,
    this.promotion,
  });
}
