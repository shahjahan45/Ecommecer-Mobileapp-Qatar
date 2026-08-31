# Phase 8.5 — Checkout Address Lifecycle Fix

Fixes the debug red-screen assertion that could occur when saving the delivery address while the modal bottom sheet and keyboard were still tearing down.

## Root cause
The previous `_showAddressSheet()` created three `TextEditingController` instances in the parent checkout state, passed them into a modal route, then disposed them immediately when `showModalBottomSheet()` completed. The route can still be in reverse animation / overlay teardown when that future completes, especially with an active text input connection. This created an unsafe ownership/lifecycle boundary and could cascade into Flutter's `_dependents.isEmpty` debug assertion during inherited-element deactivation.

## Fix
- Address form is now a dedicated StatefulWidget that owns and disposes its own controllers and FocusNodes.
- Keyboard focus is explicitly cleared before closing.
- The sheet waits until the end of the current frame before popping.
- Controllers are disposed only when the bottom-sheet widget itself is actually disposed.
- Saved address is returned as a result and shown in the existing checkout address card.
- Added stable keys and a regression widget test covering open → type → save → close.
