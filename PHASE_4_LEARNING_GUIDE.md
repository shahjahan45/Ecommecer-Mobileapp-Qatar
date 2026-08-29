# Phase 4 Learning Guide — DCX Shop Product Discovery

## Goal

Phase 4 teaches how a professional shopping app moves from a beautiful home screen into a structured product-discovery experience.

## New architecture

```text
lib/
  data/
    demo_catalog.dart
  features/
    categories/
      categories_page.dart
    search/
      search_page.dart
    products/
      product_filter.dart
      product_listing_page.dart
      widgets/
        filter_bottom_sheet.dart
        product_list_tile.dart
```

## 1. Demo catalogue

`demo_catalog.dart` is the temporary source of truth for Phase 4. It gives us a realistic local product set while we focus on UI and interaction design.

Later, Laravel API responses will replace this file without forcing us to redesign the screens.

## 2. Professional categories

The Categories screen now includes:

- branded DCX Shop hero panel
- responsive department grid
- animated selected category state
- product counts
- subcategory chips
- direct navigation to filtered product lists
- search access

## 3. Search

The Search screen demonstrates:

- focused search field
- recent searches
- popular searches
- live local suggestions
- product/brand/category keyword matching
- smooth transition from search to product results

## 4. Product listing

The listing page demonstrates:

- category filtering
- subcategory filtering
- query filtering
- responsive grid view
- professional list view
- grid/list switch
- sorting
- filter count badges
- no-results state

## 5. Filters

The animated bottom sheet supports:

- price range
- minimum rating
- in-stock-only
- discounted-products-only

The filter state stays on the listing page until the user changes it.

## 6. Sorting

Sorting includes:

- Featured
- Newest
- Price: Low to High
- Price: High to Low
- Highest rated

## 7. Phase boundary

When a user taps a product, Phase 4 shows a preview explaining that the full Product Details screen belongs to Phase 5. This keeps the learning process controlled and makes each phase independently testable.

## Recommended test sequence

1. Open DCX Shop.
2. Complete onboarding and enter the app.
3. Open Categories.
4. Select Electronics.
5. Open Audio.
6. Toggle grid/list view.
7. Sort by Highest rated.
8. Open Filters and choose price/rating/stock/deal options.
9. Open Search.
10. Search `smart` or `running`.
11. Verify that matching catalogue products appear.
