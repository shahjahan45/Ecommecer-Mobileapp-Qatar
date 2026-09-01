# Phase 11.2 — Profile → Appearance Navigation Test Fix

This maintenance release makes the Profile → Appearance route regression test deterministic under the Phase 11 theme architecture.

## Changes

- Added a stable `profile-appearance-action` key to the Appearance account-menu action.
- Added a stable `appearance-page` key to the Appearance page scaffold.
- Extended `AccountMenuItem` with an optional widget key for reliable automation without changing visual behavior.
- Updated `profile_navigation_test.dart` to run inside the same `AppTheme` + `ThemeController` harness used by the production app.
- The test now fully reveals the Appearance action before tapping it, and checks for framework exceptions before and after navigation so multiple exceptions are not collapsed into an opaque test failure.
- No visual Profile or Appearance behavior was changed.
