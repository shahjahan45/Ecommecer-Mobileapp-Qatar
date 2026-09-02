# Phase 15.1 — Geocoding 5.x API Compatibility Fix

## Root cause

Phase 15 used the pre-5.0 geocoding top-level helpers `locationFromAddress(...)` and `placemarkFromCoordinates(...)`. The project depends on `geocoding: ^5.0.0`, where those operations are methods on a `Geocoding` instance. This caused `flutter analyze` and every test importing the app graph to fail at compile time.

## Fix

`MapLocationPickerPage` now owns a local `Geocoding` instance:

```dart
final Geocoding _geocoding = Geocoding();
```

and uses:

```dart
await _geocoding.locationFromAddress(query);
await _geocoding.placemarkFromCoordinates(latitude, longitude);
```

The instance stays local to the map picker. Ordinary Profile, Checkout and address tests therefore do not invoke native geocoding unless the customer actually opens the optional map flow.

## Scope

No address UX, saved-address behavior, footer placement, checkout rules, Google Maps marker behavior or branding was redesigned in this fix.
