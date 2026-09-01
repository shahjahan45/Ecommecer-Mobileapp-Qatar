# Phase 11.5 — Appearance Responsive Test Fix

## Root cause

`AppearancePage` is a real scrollable settings page. Flutter's `ListView` builds children lazily around the viewport. On compact test sizes, the `Dark` theme option can be below the initially built range, so an immediate `find.text('Dark')` or `find.bySemanticsLabel('Dark theme')` can legitimately return zero widgets even though the UI is correct and reachable by scrolling.

## Production hardening

- Added `PageStorageKey<String>('appearance-scroll')` to the Appearance `ListView`.
- Added stable semantic keys for all theme options: `appearance-theme-system`, `appearance-theme-light`, and `appearance-theme-dark`.
- Theme-option semantics are now isolated with `container: true` and `excludeSemantics: true` so the accessibility label remains deterministic while the descriptive subtitle is exposed as a hint.
- No visual design, theme persistence, or selection logic was changed.

## Regression test change

`appearance_responsive_test.dart` now mirrors a real user interaction:

1. Pump the Appearance screen.
2. Confirm the initially visible content has no framework exception.
3. Scroll until the Dark theme card is built and visible.
4. Verify its stable key, text, and accessibility label.
5. Tap the exact Dark card.
6. Verify `Brightness.dark` and selected semantics.
7. Confirm no framework exception.

The same sizes remain covered: 320×568, 360×640, 412×915, and 800×1100.
