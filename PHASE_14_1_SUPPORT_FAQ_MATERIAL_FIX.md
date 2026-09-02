# Phase 14.1 — Support FAQ Material Surface Fix

## Issue
`support_center_responsive_test.dart` reported four Flutter framework assertions because each FAQ `ExpansionTile` internally uses a `ListTile`, while the entire FAQ group was wrapped by a painted `Container` / `DecoratedBox`. The decorated background could hide the `ListTile` material background and ink splash.

## Fix
- Replaced the painted FAQ `Container` with a real `Material` surface.
- Preserved the same surface color, rounded radius, outline and clipping through `RoundedRectangleBorder`.
- Added stable keys for the FAQ surface and each FAQ tile.
- Extended the responsive test to scroll to the first FAQ, expand it, validate the answer and assert that no Flutter framework exception is emitted.

## Behaviour preserved
Support tickets, support request creation, FAQ copy, responsive layout, light/dark theming, notification features and all previous commerce phases remain unchanged.
