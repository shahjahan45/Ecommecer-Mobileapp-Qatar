# Phase 7.1 — Cart Responsive Test Fix

## Root cause

The Phase 7 cart UI uses `CustomScrollView` with lazy slivers. On 320×568 and 360×640 screens, `Order summary` is correctly below the initial viewport and therefore is not built yet. The previous widget test incorrectly expected `Order summary` immediately after `pumpAndSettle()`, causing a false failure.

## Fix

- Keep the production Cart UI and business logic unchanged.
- Validate `My Cart`, the sticky `Checkout` CTA, and absence of framework exceptions in the initial viewport.
- Scroll the actual `CustomScrollView` with `dragUntilVisible()`.
- Assert `Order summary` after the lazy sliver is built.
- Check `tester.takeException()` again after scrolling.
- Preserve the 320×568, 360×640, 390×844, 412×915, tablet, and landscape matrix.
- Preserve the empty-cart overflow test.

This change fixes the test contract rather than forcing below-the-fold production content to be eagerly built.
