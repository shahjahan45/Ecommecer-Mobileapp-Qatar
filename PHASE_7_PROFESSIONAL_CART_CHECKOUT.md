# Phase 7 — Professional Cart & Checkout Foundation

Phase 7 upgrades the previous placeholder cart into a synchronized, responsive shopping cart and secure checkout foundation while preserving the official DCX Online Store branding and all previous phases.

## Included
- Shared `CartController` based on Flutter `ChangeNotifier`.
- Product + variant-aware cart lines.
- Stock-limited quantity controls.
- Remove with undo.
- Save for later / move to wishlist with undo.
- Live subtotal, savings, delivery and total calculations.
- Free-delivery progress state.
- Professional responsive cart cards.
- Sticky SafeArea checkout bar.
- Live cart quantity badge in bottom navigation.
- Home, Product Listing, Product Details and Wishlist now write into the same cart state.
- Product Details Buy Now opens the checkout foundation after placing the selected quantity/variant into the cart.
- Checkout foundation with delivery-address, delivery-method and payment-method UI.
- Cart and checkout regression tests across small phones, standard phones, tablets and landscape.

## Branding lock
`assets/icon/app_icon.png` remains the exact official DCX Online Store logo supplied by the user and must not be replaced, altered or regenerated.
