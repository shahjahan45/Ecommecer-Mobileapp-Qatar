# Phase 11.3 — Lazy Theme Storage Fix

## Root cause
`ThemeController.instance` constructed `SharedPreferencesAsync` immediately. Flutter widget/unit tests do not automatically register the `SharedPreferencesAsyncPlatform` implementation, so merely referencing the singleton could throw `Bad state: The SharedPreferencesAsyncPlatform instance must be set.` even when `persist: false` was requested.

## Fix
- `SharedPreferencesAsync` is now created lazily only when `load()` or a persisted `setPreference(..., persist: true)` actually needs platform storage.
- In-memory theme changes (`persist: false`) no longer touch the plugin.
- Real app persistence remains unchanged: `load()` and persisted changes still use `SharedPreferencesAsync` and preserve the existing try/catch fallback.
- Added a regression test proving in-memory theme switching works without a platform preferences implementation.

No visual UI, launch, profile, cart, checkout, wishlist, orders, or navigation behavior was changed.
