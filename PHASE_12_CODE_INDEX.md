# Phase 12 Code Index

## New
- `lib/models/promotion.dart` — promotion types, rules and apply result model.
- `lib/data/demo_promotions.dart` — replaceable demo promotion catalog.
- `lib/features/cart/widgets/promotion_code_card.dart` — responsive promotion entry/applied UI shared by Cart and Checkout.
- `test/cart_promotion_controller_test.dart` — promotion calculation and eligibility regression coverage.
- `test/promotion_code_responsive_test.dart` — compact/tablet promo UX regression coverage.

## Updated
- `lib/features/cart/cart_controller.dart` — applied promotion state, promo discount, free-delivery offers, final total reconciliation.
- `lib/features/cart/cart_page.dart` — promo entry before order summary.
- `lib/features/cart/widgets/cart_summary_card.dart` — promo savings row, theme-aware surfaces and delivery messaging.
- `lib/features/checkout/checkout_page.dart` — promo entry available during checkout as well.
- `pubspec.yaml` — version `1.12.0+42` and Phase 12 description.
