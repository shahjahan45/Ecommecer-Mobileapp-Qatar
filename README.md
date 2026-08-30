# DCX Online Store Mobile — Phase 6

Cumulative Flutter source for DCX Online Store through Phase 6.

## Current customer-facing modules

- Premium authentication and onboarding
- Professional home shopping experience
- Categories and subcategories
- Search, suggestions, filters, sorting, grid/list browsing
- Product Details with gallery, variants, quantity, reviews, specifications, and sticky purchase controls
- Phase 6 synchronized professional Wishlist UI kit
- Cart, Orders, Notifications, and Profile foundations
- Production-safe responsive bottom navigation

## Phase 6 highlight

Wishlist is now shared across product cards, product lists, Product Details, Home badge, and the Wishlist page. The page includes search, filters, grid/list layouts, savings summary, clear confirmation, undo, empty states, accessibility labels, and responsive tests.

## Local verification

```powershell
flutter clean
flutter pub get
dart format lib test
flutter analyze
flutter test
```

Then run on a connected Android device with `flutter run`.

No backend API contract is changed in Phase 6. Wishlist persistence is currently in-memory and deliberately isolated behind `WishlistController` so it can be replaced by Laravel/API persistence later without redesigning the UI.

## Phase 6.1 — Premium Product Details UI Redesign

Phase 6.1 compacts and modernizes Product Details while preserving the existing product, wishlist, navigation and cart callback behavior. The size/variant selector is now a single horizontally scrollable row, quantity controls are compact, trust information uses reusable list cards, and checkout remains sticky and SafeArea-aware. See `PHASE_6_1_PREMIUM_PRODUCT_DETAILS_UI_REDESIGN.md`.


## Phase 6.1.1 — Wishlist responsive test fix

Fixes short-screen wishlist and empty-state RenderFlex overflows without changing business logic. See `PHASE_6_1_1_WISHLIST_RESPONSIVE_FIX.md`.
