# Phase 10.5 — Seamless Splash-to-Onboarding Handoff

Version: `1.10.5+33`

## Goal

Remove the abrupt visual cut between the premium DCX launch screen and the
first onboarding screen while preserving the existing official logo, launch
art direction, reduced-motion support, and onboarding functionality.

## Implementation

- Added `LaunchHandoffRoute` exclusively for Splash → Onboarding.
- New route uses a 520 ms fade-through with a subtle 2.8% vertical entrance
  and 0.986 → 1 scale settle.
- Splash simultaneously performs a gentle exit: fade, 1 → 1.035 scale, and a
  very small upward drift.
- The old splash route stays visually underneath the entering onboarding route
  during the transition, preventing a blank/flash frame.
- Onboarding explicitly uses the same `#F7F7FC` background as the launch
  surface so the transition maintains visual continuity.
- Reduced Motion still bypasses all spatial/fade handoff animation with zero
  transition duration.
- No Hero/shared-element overlay was introduced, avoiding unnecessary route
  overlay lifecycle complexity.

## Regression guard

`test/launch_experience_test.dart` now checks that during the handoff both the
outgoing launch transition and incoming onboarding page exist concurrently,
with no framework exception.
