# DCX Shop Phase 4.4 — Universal Responsive Hardening

This cumulative update keeps every feature from Phases 1–4.3 and focuses on real-device stability.

## What was changed

- Rebuilt onboarding with a Stack + scrollable PageView composition so there is no root vertical Flex that can overflow on short screens.
- Added app-wide text-scale protection (0.90–1.20) for stable controls on devices with very large system font settings.
- Changed Android-style scrolling to native clamping physics for smoother long-page scrolling and less elastic/janky movement.
- Replaced the heavy five-page opacity/scale tab stack with a PageView-driven wipe transition for lower GPU/layout cost on real phones.
- Bottom navigation labels use no text scaling plus FittedBox, preventing navigation Flex overflow.
- Home and catalogue product grids change to one column below 370 logical pixels and use explicit safe card heights.
- Category department grid changes to one column below 350 logical pixels and uses explicit card heights.
- Home deal card changes from Row to Column on narrow phones.
- Quick-benefit cards become horizontally scrollable on very narrow phones.
- Login, verification and footer actions use wrapping layouts where appropriate.
- Sort bottom sheet is now vertically scrollable on short devices.
- Auth pages include keyboard inset padding so the keyboard cannot cover/force the form outside the viewport.

## Tested design targets in the code

The responsive logic is designed for:

- 320×568 class small phones
- 360×640 / 360×800 Android phones
- 390×844 / 412×915 modern phones
- landscape / short-height layouts
- tablets (600–900+ logical px)
- larger screens and desktop-width Flutter previews

## Important Android native repair

If Android Studio still shows invalid manifest attributes, regenerate the Android platform instead of editing Dart code:

```powershell
cd C:\xampp\htdocs\ecommerce_mobile
Remove-Item -Recurse -Force android
flutter create --platforms=android .
```

Then change only the generated app label to `DCX Shop`. If you use the included template, copy `platform_templates/android/AndroidManifest.xml` after regeneration and keep the generated MainActivity package path.

## Clean test

```powershell
flutter clean
flutter pub get
dart format lib
flutter analyze
flutter run
```

If a RenderFlex banner ever appears again, click **Inspect Widget** while the banner is visible. Flutter will select the exact offending Flex. Send that selected widget name and screen screenshot so the specific component can be corrected rather than guessed.
