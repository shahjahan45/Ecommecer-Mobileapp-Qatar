# DCX Online Store — Phase 6 Professional Wishlist UI Kit

Phase 6 upgrades wishlist from a placeholder screen to an application-wide shopping feature.

## Included

- Shared `WishlistController` using Flutter `ChangeNotifier` only.
- Wishlist state is synchronized across Home product cards, product listing cards, list tiles, Product Details, and Wishlist.
- Premium purple wishlist hero summary with saved count and potential savings.
- Search within saved products.
- All / In stock / On sale filters.
- Responsive Grid / List view switcher.
- Professional empty and no-results states.
- Clear-all confirmation and immediate Undo action.
- Product Details navigation with unique Hero tags.
- Add-to-cart feedback without coupling wishlist to a future cart API.
- Accessibility labels on wishlist and cart controls.
- Responsive tests for small phones, large phones, tablets, and landscape.
- Controller tests for toggle, filtering, clear, and restore behavior.

## Architecture

```text
lib/features/wishlist/
├── wishlist_controller.dart
├── wishlist_page.dart
└── widgets/
    ├── wishlist_hero_card.dart
    └── wishlist_toolbar.dart
```

The controller is intentionally API-independent. A later Laravel-backed repository can replace the local demo data layer while preserving the UI API.
