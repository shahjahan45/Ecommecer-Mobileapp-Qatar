# Phase 13 Code Index

## New production files

- `lib/models/payment.dart` — payment method/status domain model and labels.
- `lib/features/checkout/payment_flow_controller.dart` — checkout payment orchestration state.
- `lib/features/checkout/checkout_order_service.dart` — cart-to-order snapshot/placement boundary.
- `lib/features/checkout/order_confirmation_page.dart` — responsive post-purchase confirmation UX.

## Updated production files

- `lib/features/checkout/checkout_page.dart` — payment selection, review/confirm, order placement and processing state.
- `lib/models/shop_order.dart` — payment status/reference and promotion metadata.
- `lib/data/demo_orders.dart` — realistic payment metadata for existing demo orders.
- `lib/features/orders/order_details_page.dart` — payment status/reference/promo display.
- `pubspec.yaml` — Phase 13 version/description.

## New tests

- `test/payment_flow_controller_test.dart`
- `test/checkout_order_service_test.dart`
- `test/checkout_payment_flow_test.dart`
- `test/order_confirmation_responsive_test.dart`
