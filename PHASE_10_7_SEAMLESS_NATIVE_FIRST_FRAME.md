# Phase 10.7 — Seamless Native First Frame

## Problem fixed
On Android 12+ the operating system must display its own system splash before Flutter renders. Phase 10.6 intentionally used a transparent splash icon to eliminate the previously cropped DCX logo. On real devices that made the mandatory system splash look like a blank white page.

## Solution
- Keep the mandatory native Android splash.
- Match its background to the Flutter launch surface (`#F7F7FC`).
- Display a safe-area padded derivative of the same official DCX logo so Android's splash mask clips only transparent padding, not the artwork.
- Start the Flutter logo at 94% opacity on the first Flutter frame so the native brand mark visually continues into the cinematic Flutter animation.
- Keep the 3–4 second premium launch and the Phase 10.5/10.6 onboarding handoff unchanged.

## Branding guarantee
`assets/icon/app_icon.png` is unchanged. The native Android splash image is only a transparent padded derivative required by the Android system splash mask.
