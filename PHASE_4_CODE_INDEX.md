# DCX Shop Phase 4 — Code Index

Phase 4 is cumulative and keeps all previous code.

## New Phase 4 files

- `lib/data/demo_catalog.dart` — temporary local catalogue source for learning UI before Laravel.
- `lib/features/search/search_page.dart` — recent searches, popular searches, live suggestions and search submission.
- `lib/features/products/product_filter.dart` — immutable filter state.
- `lib/features/products/product_listing_page.dart` — responsive product catalogue, sorting, grid/list switching and filter application.
- `lib/features/products/widgets/filter_bottom_sheet.dart` — professional animated filtering sheet.
- `lib/features/products/widgets/product_list_tile.dart` — reusable list-view product presentation.

## Upgraded Phase 4 files

- `lib/core/constants/app_constants.dart` — app brand changed permanently to `DCX Shop`.
- `lib/models/category.dart` — category slug, product count and subcategory support.
- `lib/models/product.dart` — brand, subcategory, stock, tags and search metadata.
- `lib/features/categories/categories_page.dart` — complete category/subcategory browsing experience.
- `lib/features/home/home_page.dart` — home search/category/product actions now open Phase 4 browsing screens.
- `lib/widgets/product_card.dart` — stock-aware add button.

## Still intentionally not connected

Laravel API, MySQL, Sanctum, Firebase, persistent cart and production product images are reserved for later phases. Phase 4 focuses on discovery UI and client-side interaction architecture.
