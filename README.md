# DCX Online Store — Phase 8 Cumulative Build

This cumulative build adds the professional Orders and integrated Order Tracking experience while preserving every previous cart, checkout, wishlist, product-details, authentication, responsive fix, official-branding lock and test guard.

See `PHASE_8_PROFESSIONAL_ORDERS_TRACKING.md` for the Phase 8 implementation summary and `PHASE_8_VERIFICATION_REPORT.md` for packaging preflight details.

## Phase 8 highlight

The Orders tab is now a mobile-first post-purchase hub with search, status filters, compact order cards, Buy Again, professional Order Details, expected delivery information, visual order progress, carrier/tracking data, detailed shipping history, inline package contents and responsive tests across phones, tablets and landscape.

# DCX Online Store Mobile — Phase 6

Cumulative Flutter source for DCX Online Store through Phase 6.

## Current customer-facing modules

- Premium authentication and onboarding
- Professional home shopping experience
- Categories and subcategories
- Search, suggestions, filters, sorting, grid/list browsing
- Product Details with gallery, variants, quantity, reviews, specifications, and sticky purchase controls
- Phase 6 synchronized professional Wishlist UI kit
- Professional synchronized Cart and Checkout foundation
- Professional Orders history and integrated Order Tracking
- Notifications and Profile foundations
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


## Phase 6.2 — Premium Login + App Logo

The login screen now follows the latest premium reference direction and uses `assets/icon/app_icon.png` directly in the DCX Online Store brand header. Existing login validation, navigation, mock authentication, Product Details, Wishlist, and shopping logic remain unchanged. See `PHASE_6_2_PREMIUM_LOGIN_APP_LOGO_REDESIGN.md`.

## OFFICIAL BRANDING

The official DCX Online Store logo/app-icon source is `assets/icon/app_icon.png`. See `OFFICIAL_BRANDING_LOCK.md`. Do not replace or redesign this asset unless explicitly requested by the user.

## Phase 8.1 update

Phase 8.1 hardens Product Details route lifecycle behavior and replaces textual color variant chips with professional real-color swatches. See `PHASE_8_1_PRODUCT_DETAILS_STABILITY_COLOR_SWATCH_FIX.md`.

Project version: `1.8.1+20`.


## Phase 8.4
Stable accessibility semantics for product variant controls. Official branding remains unchanged.

## Phase 9 — Premium Account Center

The Profile tab is now a professional mobile-first customer account hub with direct access to orders, wishlist, delivery addresses, payment preferences, security information, notifications, and help. The official DCX logo remains the single branding source at `assets/icon/app_icon.png`.
