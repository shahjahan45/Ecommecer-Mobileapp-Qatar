# Phase 10 Code Index

## New files

- `lib/features/auth/splash/widgets/launch_backdrop.dart`
- `lib/features/auth/splash/widgets/launch_logo_reveal.dart`
- `test/launch_experience_test.dart`
- `android/app/src/main/res/values/colors.xml`
- `android/app/src/main/res/values/styles.xml`
- `android/app/src/main/res/values-v31/styles.xml`
- `android/app/src/main/res/values-night/styles.xml`
- `android/app/src/main/res/values-night-v31/styles.xml`
- `android/app/src/main/res/drawable/launch_background.xml`
- `ios/Runner/Base.lproj/LaunchScreen.storyboard`

## Updated files

- `lib/main.dart`
- `lib/core/navigation/app_page_route.dart`
- `lib/core/widgets/app_pressable.dart`
- `lib/core/widgets/app_skeleton.dart`
- `lib/core/widgets/fade_slide_in.dart`
- `lib/features/auth/splash/splash_page.dart`
- `lib/features/auth/widgets/brand_mark.dart`
- `lib/features/auth/onboarding/onboarding_page.dart`
- `lib/navigation/main_navigation.dart`
- `lib/navigation/widgets/dcx_bottom_navigation_bar.dart`
- `pubspec.yaml`

## Phase 10.3 launch redesign
- `lib/features/auth/splash/splash_page.dart`
- `lib/features/auth/splash/widgets/launch_backdrop.dart`
- `lib/features/auth/splash/widgets/launch_logo_reveal.dart`
- `lib/features/auth/splash/widgets/launch_progress_indicator.dart`
- `android/app/src/main/res/drawable-v31/dcx_native_splash_icon.xml`
- `android/app/src/main/res/drawable-nodpi/dcx_splash_logo.png`
- `test/launch_experience_test.dart`

## Phase 10.5 — Seamless launch handoff

### New
- `lib/core/navigation/launch_handoff_route.dart`
- `PHASE_10_5_SEAMLESS_LAUNCH_HANDOFF.md`
- `PHASE_10_5_VERIFICATION_REPORT.md`

### Updated
- `lib/features/auth/splash/splash_page.dart`
- `lib/features/auth/onboarding/onboarding_page.dart`
- `test/launch_experience_test.dart`
- `pubspec.yaml`
- `README.md`

## Phase 10.7 additions
- `android/app/src/main/res/drawable-nodpi/dcx_native_splash_safe.png` — Android system-splash-safe padded derivative of the existing official logo.
- `android/app/src/main/res/values-v31/styles.xml` — uses the safe branded native splash icon instead of a transparent icon.
- `android/app/src/main/res/values-night-v31/styles.xml` — same branded first-frame behavior in night mode while preserving the light launch surface.
- `lib/features/auth/splash/splash_page.dart` — Flutter logo begins visible at 94% opacity for continuous native-to-Flutter handoff.
- `lib/features/auth/splash/widgets/launch_logo_reveal.dart` — stable first-frame logo key for regression testing.
- `test/launch_experience_test.dart` — verifies the Flutter logo is already visible on the first rendered frame.
