# Phase 6 Code Index

## New
- `lib/features/wishlist/wishlist_controller.dart` — shared wishlist state and filtering.
- `lib/features/wishlist/wishlist_page.dart` — premium responsive wishlist screen.
- `lib/features/wishlist/widgets/wishlist_hero_card.dart` — premium summary UI kit.
- `lib/features/wishlist/widgets/wishlist_toolbar.dart` — search, filters, and view switcher.
- `test/wishlist_responsive_test.dart` — phone/tablet/landscape layout coverage.
- `test/wishlist_controller_test.dart` — wishlist state behavior coverage.

## Updated
- `lib/widgets/product_card.dart` — synchronized heart state + semantics.
- `lib/features/products/widgets/product_list_tile.dart` — synchronized heart state + responsive price row.
- `lib/features/products/product_details_page.dart` — shared wishlist state.
- `lib/features/home/home_page.dart` — live wishlist badge/count.
- `lib/data/demo_catalog.dart` — richer demo wishlist seed data.
- `pubspec.yaml` — Phase 6 version and description.
- `README.md` — cumulative Phase 6 documentation.

## Cleanup
- Removed the obsolete `platform_templates/` reference directory to avoid confusing it with the real Flutter `android/` project.
