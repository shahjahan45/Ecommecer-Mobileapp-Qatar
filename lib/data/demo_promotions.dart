import '../models/promotion.dart';

class DemoPromotions {
  DemoPromotions._();

  static const promotions = <Promotion>[
    Promotion(
      code: 'WELCOME10',
      title: '10% welcome saving',
      description: 'Save 10% on eligible items, up to QAR 50.',
      type: PromotionType.percentage,
      value: 10,
      minimumSubtotal: 100,
      maximumDiscount: 50,
    ),
    Promotion(
      code: 'DCX25',
      title: 'QAR 25 cart saving',
      description: 'Save QAR 25 when your basket reaches QAR 200.',
      type: PromotionType.fixedAmount,
      value: 25,
      minimumSubtotal: 200,
    ),
    Promotion(
      code: 'FREESHIP',
      title: 'Free standard delivery',
      description: 'Unlock free standard delivery on baskets from QAR 75.',
      type: PromotionType.freeDelivery,
      value: 0,
      minimumSubtotal: 75,
    ),
  ];

  static Promotion? findByCode(String rawCode) {
    final normalized = rawCode.trim().toUpperCase();
    for (final promotion in promotions) {
      if (promotion.code == normalized) return promotion;
    }
    return null;
  }
}
