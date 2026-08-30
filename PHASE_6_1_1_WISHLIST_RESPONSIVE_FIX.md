# Phase 6.1.1 — Wishlist Responsive Fix

This cumulative patch fixes the wishlist RenderFlex overflows observed in Flutter widget tests at 360x640 and in the empty state.

## Root causes fixed

- Empty and no-result cards were placed inside `SliverFillRemaining(hasScrollBody: false)`, which can force a card taller than the remaining short viewport and produce a vertical RenderFlex overflow. They now use normal scrollable sliver content.
- Wishlist search used a tight fixed height. It now uses a minimum-height constraint and dense responsive input padding.
- Product list tiles now adapt image/padding/text sizing below 350 logical pixels of tile width and allow rating/stock metadata to wrap naturally.
- Empty-state spacing and icon sizing now compact automatically on narrow widths.

No wishlist business logic, product data, navigation, cart callbacks, or Product Details actions were changed.
