# Phase 11.4 — Offline Typography & Theme Test Fix

## Root cause
`AppTheme` used `GoogleFonts.inter(...)`. Flutter widget tests intentionally block real HTTP, so `google_fonts` attempted to download Inter from `fonts.gstatic.com` and the theme foundation test failed. The same runtime dependency could also delay or change typography on a first offline app launch.

## Production fix
- Removed runtime Google Fonts usage from the global theme.
- Removed the `google_fonts` dependency because no application code uses it anymore.
- Preserved DCX typography sizes, weights, line heights, letter spacing, and color hierarchy.
- Typography now inherits Flutter's native platform family (Roboto on Android, San Francisco on iOS, Segoe UI on Windows).
- Theme construction is fully synchronous and network-independent.
- Theme tests no longer create an `HttpClient` or depend on fonts.gstatic.com.

## Unchanged
Dark mode logic, theme persistence, Profile → Appearance navigation, commerce features, Phase 10.7 launch behavior, and the official DCX logo remain unchanged.
