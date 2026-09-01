# Phase 12 — Professional Promotions & Savings Engine

Phase 12 adds a production-shaped promotions foundation to the existing DCX Online Store cart and checkout experience without changing the official branding or Phase 10.7 launch flow.

## Customer experience

- A premium promo-code card is available in both Cart and Checkout.
- Promo codes are normalized case-insensitively and validated before they change totals.
- Applied offers switch into a compact success state with offer details, savings and an explicit remove action.
- Suggested demo codes are tappable and populate the field for quick QA/demo testing.
- Compact phones stack the promo input and Apply action vertically to avoid horizontal overflow.
- Material 3 theme roles are used so the new surfaces remain readable in light and dark appearance modes.

## Promotion rules

The current demo promotion catalog intentionally lives behind `DemoPromotions` so it can later be replaced by the Laravel/API source without rewriting cart totals or UI.

- `WELCOME10` — 10% off, maximum QAR 50, minimum basket QAR 100.
- `DCX25` — QAR 25 off, minimum basket QAR 200.
- `FREESHIP` — free standard delivery, minimum basket QAR 75.

## Cart calculation order

1. Product subtotal
2. Product-level sale savings (informational)
3. Promotion discount
4. Delivery fee / promotion delivery saving
5. Final payable total

Applied promotions are reconciled when quantities or cart lines change. If the basket falls below the promotion minimum, the promotion is removed rather than leaving a misleading discount in the total.

## Accessibility and testability

Stable keys were added for the promo field, Apply action and applied state. Suggested-code chips expose button semantics. New controller tests cover percentage caps, minimum-spend validation, free delivery, invalidation and unknown codes. Responsive promo UI coverage targets 320, 360, 412 and 800 px widths.

## Important

These are local demo promotion rules for the Flutter phase. A real production backend should remain the authority for promotion eligibility, usage limits, expiry, customer targeting and final checkout validation.
