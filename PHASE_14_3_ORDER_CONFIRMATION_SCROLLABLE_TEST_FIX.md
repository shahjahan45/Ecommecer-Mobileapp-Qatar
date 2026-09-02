# Phase 14.3 — Order Confirmation Scrollable Test Fix

## Root cause
`WidgetTester.scrollUntilVisible` requires its `scrollable` finder to resolve to a `Scrollable` widget. The Phase 14.2 test passed the keyed `ListView` itself. `ListView` is a `ScrollView`, not a `Scrollable`, so Flutter's test framework attempted an invalid cast and threw:

`type 'ListView' is not a subtype of type 'Scrollable' in type cast`

## Fix
The test still locates the production `ListView` using its stable `PageStorageKey`, then resolves the internal `Scrollable` descendant and passes that finder to `scrollUntilVisible`.

The production Order Confirmation page and premium footer are unchanged.
