# DCX Online Store Phase 4.5 — Production Bottom Navigation Constraint Fix

## Root cause
The previous custom navigation item used `SizedBox.expand()` inside a horizontal `Expanded` child, while its inner `Column` used `mainAxisSize: MainAxisSize.max`. During a loose/unbounded cross-axis layout pass on some real Android devices, that item could request the maximum available vertical extent. Flutter's debug overflow then surfaced an extremely large value (the observed ~99978 px) at the selected tab.

The old main scaffold also used `extendBody: true`, so page content was painted behind the bottom bar and individual pages compensated with large manual bottom padding. That was fragile across system navigation modes and real-device safe-area insets.

## Fix
- Removed `SizedBox.expand()` from navigation items.
- Navigation item content now uses a finite 60 px control height and `Column(mainAxisSize: MainAxisSize.min)`.
- Bottom bar owns a finite 72 px content height and is wrapped in `SafeArea(top: false)`.
- Main Scaffold now uses `extendBody: false`; Scaffold reserves the bottom-navigation region correctly.
- Removed the Profile page's arbitrary 120 px bottom padding.
- Page and selection animations are synchronized using the PageController's fractional page position.
- Removed the unnecessary foundation.dart import in scroll behavior.
- Added a widget test across common phone widths.

No API, authentication, backend, data model, or database behavior was changed.
