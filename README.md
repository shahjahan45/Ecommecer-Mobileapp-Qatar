# DCX Online Store — Phase 10 Cumulative Build

Version: `1.10.5+33`

This cumulative Flutter build preserves all previous authentication, shopping, Product Details, Wishlist, Cart, Checkout, Orders/Tracking, Profile/Account Center, responsive fixes, test guards and the official branding lock, then adds the Phase 10 premium native-aware launch experience and modern motion/accessibility foundation.

## Phase 10 highlight

- Native-aware Android launch resources with Android 12+ splash attributes.
- Standards-aligned iOS `LaunchScreen.storyboard` surface for an existing iOS Flutter scaffold.
- Short premium DCX logo reveal using the exact official asset.
- Responsive layered launch background and a slim progress accent instead of a blocking spinner.
- Reduced-motion support across launch, routes, onboarding, press feedback, skeletons and bottom navigation.
- Edge-to-edge system-bar foundation with existing SafeArea/inset protection preserved.
- New launch regression tests for small phones, normal phones and tablets.

See `PHASE_10_PREMIUM_LAUNCH_EXPERIENCE.md`, `PHASE_10_CODE_INDEX.md`, and `PHASE_10_VERIFICATION_REPORT.md`.

## Current customer-facing modules

- Premium launch, onboarding and authentication
- Home shopping experience
- Categories and subcategories
- Search, suggestions, filters, sorting and product browsing
- Premium Product Details with gallery, real color swatches, text/size variants, quantity, reviews and sticky purchase controls
- Synchronized Wishlist
- Synchronized Cart and Checkout foundation
- Orders history and integrated Order Tracking
- Notifications
- Premium Profile / Account Center
- Delivery Address Book
- Payment preferences
- Security and support areas
- Production-safe responsive bottom navigation

## Official branding

The only official DCX Online Store logo/app-icon source is:

`assets/icon/app_icon.png`

Do not replace, recolor, regenerate, crop or redesign this asset unless the user explicitly requests a logo change. See `OFFICIAL_BRANDING_LOCK.md`.

## Local verification

```powershell
flutter clean
flutter pub get
dart format lib test
flutter analyze
flutter test
```

Then run on a connected device:

```powershell
flutter run
```

If Windows Application Control blocks `flutter_tester.exe`, that is an operating-system security-policy issue rather than a Flutter source error; allow the Flutter SDK test executable through the applicable policy before rerunning `flutter test`.

## Phase 10.1 — Profile compact-width responsive fix

- Fixes the Profile Account Center horizontal RenderFlex overflow at 320x568 and 360x640.
- Compact phones use a gesture-friendly horizontal Quick Access rail instead of cramped two-column cards.
- 390px+ keeps the two-column layout and tablets keep four columns.
- No account navigation/business logic changes.


## Phase 10.2
Profile hero compact-width overflow fix: the secure-account status element is now width-bounded and responsive on 320/360 px phone layouts.

## Phase 10.3 — Premium Same-Logo Launch Experience
The app launch now uses the same official DCX logo in a premium animated light-to-navy scene with spatial wave reveal, orange accent, responsive Smart Shopping copy, custom progress motion, reduced-motion support, and an Android 12+ native splash drawable designed to prevent launcher-icon cropping during the system handoff.


## Phase 10.4 — Launch Semantics Regression Fix

The premium launch progress layer now keeps its accessibility semantics in the tree while its fade animation starts at zero opacity. This fixes the launch regression test that expects `Opening DCX Online Store` immediately after the first frame, without changing launch visuals, timing, motion, or branding.


## Phase 10.5 — Seamless Splash → Onboarding transition

- Replaces the abrupt first-screen switch with a coordinated 520 ms fade-through handoff.
- Splash gently fades, lifts and scales while onboarding fades/settles in above it.
- Launch and onboarding surfaces share the same base background to prevent flashes.
- Reduced Motion uses an immediate zero-duration handoff.
- Existing official DCX image/logo and launch artwork remain unchanged.

## Phase 10.6 — First-Frame Cinematic Launch

The Android 12+ system splash is now visually neutral (matching background + transparent icon), preventing a cropped native logo from appearing before Flutter. The premium DCX Flutter launch is the first branded screen and uses a staged ~3.8 second launch-to-onboarding choreography with reduced-motion support.

## Phase 10.7 — Seamless native first frame

- Replaces the intentionally transparent Android 12+ system splash icon with a safe-area padded copy of the existing official DCX logo.
- Keeps the Android system splash background aligned with the Flutter launch surface (`#F7F7FC`) so there is no perceived blank white page before branding.
- Starts the Flutter logo at 94% opacity on its first real frame, preventing the native mark from disappearing during engine handoff.
- Preserves the official source logo byte-for-byte at `assets/icon/app_icon.png`; only the Android native splash derivative contains transparent safety padding for Android's system mask.
