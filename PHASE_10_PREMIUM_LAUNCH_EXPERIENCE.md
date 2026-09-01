# Phase 10 — Premium App Launch Experience & Motion Foundation

Version: `1.10.0+28`

## Research direction used

This phase follows current platform guidance reviewed in September 2026:

- Android 12+ system SplashScreen behavior and Android's August 2026 splash-screen guidance.
- Android edge-to-edge expectations for modern target SDKs.
- Material 3 motion guidance separating prominent spatial motion from recurring utility motion.
- Apple Human Interface Guidelines for a launch screen that is immediate, restrained, and visually close to the first app frame.
- Flutter accessibility guidance for `MediaQuery.disableAnimationsOf(context)`.

## What changed

### Native-aware launch

- Android launch theme now uses a single `#F7F7FC` starting-window background.
- Android 12+ uses the existing launcher icon as the system splash icon.
- iOS launch storyboard uses the same neutral launch surface and intentionally contains no extra advertising or text.
- The first Flutter frame uses the exact same background family to reduce visual flashing between native launch and Flutter.

### Premium Flutter reveal

The existing `SplashPage` was redesigned rather than replaced with a new app flow.

- Official DCX Online Store logo only.
- Short fade + scale + slight spatial lift.
- Responsive ambient radial layers and subtle dot pattern.
- Slim progress accent instead of a blocking spinner.
- Normal launch handoff begins after about 1.22 seconds.
- Reduced-motion users get an almost-static launch and a faster handoff.

### Accessibility and motion

- `AppPageRoute` removes spatial movement when Reduce Motion / Disable Animations is requested.
- `FadeSlideIn` returns its child directly for reduced-motion users.
- `AppPressable` disables press scaling under reduced motion.
- `AppSkeleton` becomes a static skeleton under reduced motion instead of continuously shimmering.
- Main bottom-navigation page motion jumps rather than animates when motion is disabled.
- Onboarding page transitions and indicator motion respect the same preference.

### Edge-to-edge foundation

`main.dart` now configures transparent system bars and `SystemUiMode.edgeToEdge` while existing `SafeArea` and inset handling continue protecting interactive controls.

## Branding lock

The launch experience uses the existing official asset only:

`assets/icon/app_icon.png`

No new logo, recolor, crop, generated icon, or substitute branding was introduced.
