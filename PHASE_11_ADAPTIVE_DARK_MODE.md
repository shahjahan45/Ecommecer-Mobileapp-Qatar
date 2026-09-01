# Phase 11 — Adaptive Dark Mode & Design-System Upgrade

Version: `1.11.0+36`

## What changed

- Added persistent `System`, `Light`, and `Dark` appearance preferences.
- Added `ThemeController` backed by `SharedPreferencesAsync`.
- Added a complete Material 3 dark theme generated from the DCX purple seed.
- Added theme-aware status/navigation bar icon brightness.
- Added animated theme switching with reduced-motion-safe behavior.
- Added a responsive `Appearance` page under Account settings.
- Adapted the Account Center, account menu surfaces, quick actions, bottom navigation, shared product cards, category cards, icon buttons, empty states, and key Home surfaces to Material 3 light/dark color roles.
- Preserved the Phase 10.7 premium light launch experience and official DCX logo.

## Design direction

The implementation uses Material 3 `ColorScheme.fromSeed` for coherent light/dark roles and tone-based surfaces. Custom components use `surface`, `surfaceContainer`, `outlineVariant`, `onSurface`, and `onSurfaceVariant` rather than fixed white/black colors where they have been upgraded in this phase.

## Preference behavior

- `System`: follows the device theme.
- `Light`: forces the light DCX interface.
- `Dark`: forces the dark DCX interface.
- The selected preference is persisted between launches.

## Accessibility

- Theme transitions are short and purposeful.
- Existing reduced-motion behavior is preserved.
- System-bar icon brightness tracks the active app theme.
- Text scaling remains supported from 0.90× through 1.20×.
