# Phase 10.6 — First-Frame Cinematic Launch

This phase refines the premium launch experience so the branded Flutter launch scene is the first meaningful screen the customer sees.

## Android first-frame fix

Android 12+ always shows the platform SplashScreen before Flutter can draw. The previous phase supplied the DCX logo to that system splash, which Samsung/Android masked and cropped before the real Flutter launch scene appeared.

Phase 10.6 intentionally makes the Android 12+ system splash icon fully transparent and keeps only the same `#F7F7FC` background used by the Flutter launch. The platform splash still exists as required by Android, but it no longer presents a separate cropped-logo screen. The first visible branded composition is now `SplashPage`.

The official project logo remains unchanged at `assets/icon/app_icon.png` and is still used by the Flutter launch UI and application branding.

## 3–4 second opening choreography

Normal motion timing is approximately 3.8 seconds from first Flutter frame through the completed onboarding handoff:

1. Soft spatial background layers begin revealing.
2. The official DCX logo fades, lifts and settles from a restrained scale.
3. A subtle orange/purple ambient glow supports the logo without changing the image.
4. `Smart Shopping` and `Better • Faster • Smarter` enter after the logo establishes hierarchy.
5. The custom ring and progress track animate gradually instead of jumping.
6. The navy/orange wave receives only a few pixels of ambient drift after settling.
7. During the final 650 ms, the navy wave retreats downward while onboarding fades and settles into place on the same light surface.

No Hero overlay is used for this handoff.

## Reduced motion

When the OS requests reduced animation, the launch still settles immediately and transitions after the existing short accessibility-safe delay. The 3–4 second choreography is not forced on users who disable motion.

## Main files

- `lib/features/auth/splash/splash_page.dart`
- `lib/features/auth/splash/widgets/launch_backdrop.dart`
- `lib/features/auth/splash/widgets/launch_logo_reveal.dart`
- `lib/core/navigation/launch_handoff_route.dart`
- `android/app/src/main/res/drawable-v31/dcx_native_splash_transparent.xml`
- `android/app/src/main/res/values-v31/styles.xml`
- `android/app/src/main/res/values-night-v31/styles.xml`
- `test/launch_experience_test.dart`
