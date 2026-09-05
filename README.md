# DCX Online Store — Phase 19.1.2 Firebase Gradle & Analyzer Clean

Version: `1.19.2+62`

Phase 19.1.2 resolves the six reported Flutter analyzer findings and aligns the Android Firebase setup with current Firebase Android guidance using the project's actual Groovy/Flutter Gradle layout: Google Services plugin `4.5.0`, Firebase Android BoM `34.18.0`, and Auth/Messaging native dependencies. Phase 19.1 Firebase verification/FCM, Phase 19.1.1 Search compilation fix, Phase 19.0 real-time Admin storefront and all earlier cumulative work remain preserved.

See `PHASE_19_1_2_FIREBASE_GRADLE_ANALYZER_CLEAN.md` and `PHASE_19_1_2_VERIFICATION_REPORT.md`.

---

# DCX Online Store — Phase 19.1.1 Search Compile Hotfix

Version: `1.19.1+61`

Phase 19.1.1 fixes the Search discovery compilation failure where the `_SearchDiscovery` widget referenced `_popularSearches` owned by `_SearchPageState`. The live server-authoritative popular-search list is now passed explicitly into the child widget. Firebase Phase 19.1, real-time Admin storefront Phase 19.0, official branding, order integrity, support and all previous cumulative functionality remain preserved.

The Android project also pins the Flutter 3.44.x compatibility flags `android.newDsl=false` and `android.builtInKotlin=false`. The Kotlin Gradle Plugin warnings from Firebase plugins are advisory on Flutter 3.44.7 and are not the cause of the reported compile failure.

See `PHASE_19_1_1_SEARCH_COMPILE_HOTFIX.md` and `PHASE_19_1_1_VERIFICATION_REPORT.md`.

---

# DCX Online Store — Phase 19.1 Cumulative Build

> **Phase 19.1 Final Firebase integration:** the supplied Android `google-services.json` is installed and verified for `com.example.ecommerce_mobile`. Normal Android runs auto-initialize Firebase; no Firebase Dart defines are required. Backend FCM sending still requires the private Firebase service-account JSON on DCX Core only.

Version: `1.19.1+60`

Phase 19.1 adds real customer registration with required mobile SMS OTP, Firebase email verification, secure Firebase password-reset email, optional Laravel six-digit email OTP, FCM push notification registration and Firebase-aware account security. DCX Core remains the authoritative commerce/customer backend and Phase 19.0 real-time Admin-controlled products/prices/images/promotions/banners/settings remain preserved.

See `PHASE_19_1_VERIFIED_CUSTOMER_IDENTITY_PUSH.md`, `FIREBASE_SETUP.md`, and `PHASE_19_1_VERIFICATION_REPORT.md`.

---

# DCX Online Store — Phase 19.0 Cumulative Build

Version: `1.19.0+59`

Phase 19.0 replaces hard-coded storefront presentation with a server-authoritative, cached live storefront supplied by DCX Core. Products, pricing, stock, images, categories, promotions, banners, home section copy, store settings, support contacts and information pages refresh automatically after Admin changes without publishing a new APK. The app performs a lightweight revision poll while active, refreshes when resumed, and keeps the last successful snapshot for temporary offline continuity.

See `PHASE_19_0_REALTIME_ADMIN_STOREFRONT.md` and `PHASE_19_0_VERIFICATION_REPORT.md`.

---

# DCX Online Store — Phase 18.9 Cumulative Build

Version: `1.18.9+58`

Phase 18.9 adds immutable checkout pricing snapshots to every customer order. Each synchronized order now carries product name, checkout unit price, line total, subtotal, discount, delivery fee and final total so DCX Core can reproduce exactly what the customer confirmed even when the server catalog mapping is missing or later changes. It preserves all Phase 18.8 live operations, customer care, account, logout and order-status synchronization.

See `PHASE_18_9_ORDER_AMOUNT_INTEGRITY.md` and `PHASE_18_9_VERIFICATION_REPORT.md`.

---

# DCX Online Store — Phase 18.7 Cumulative Build

Version: `1.18.7+56`

Phase 18.7 is a stability/quality patch on top of Phase 18.6. It removes the remaining `curly_braces_in_flow_control_structures` analyzer findings in the password screen and makes the professional profile logout regression test deterministic by scoping the email assertion to the sign-out card and checking the exact confirmation-sheet message. No customer-facing logout UI was removed or simplified.

The Phase 18.6 Flutter compatibility fix and professional animated admin navigation remain preserved in the cumulative full-system package.

See `PHASE_18_7_ANALYZER_TEST_STABILITY_FIX.md` and `PHASE_18_7_VERIFICATION_REPORT.md`.

---

# DCX Online Store — Phase 18.5 Cumulative Build

Version: `1.18.5+54`

Phase 18.5 preserves Phase 18.4 secure logout and Phase 18.3 mobile-to-admin order synchronization, then adds professional customer account management inside Profile: editable personal details, authoritative backend profile loading/saving, secure password changes, live password-strength guidance, validation feedback, immediate session identity refresh, and other-device token revocation through DCX Core.

See `PHASE_18_5_PROFESSIONAL_ACCOUNT_MANAGEMENT.md` and `PHASE_18_5_VERIFICATION_REPORT.md`.

## Previous Phase 18.4 — Professional Profile Logout

Phase 18.4 added the secure logout card, confirmation bottom sheet, Laravel token revocation, local session cleanup and clean navigation back to Login.

# DCX Online Store — Phase 16 Cumulative Build

Version: `1.16.0+50`

Phase 16 adds a versioned local customer-session snapshot so cart contents, applied promotions, wishlist selections, notification read/preferences state, support activity and customer-created orders can resume after a normal app restart. Saved addresses and appearance continue using their existing dedicated persistence stores.

The app hydrates this snapshot in the background while the premium launch experience is running and saves it when the app becomes inactive/hidden/paused/detached. Profile also includes a compact **Shopping continuity** card with a manual **Save now** action. The persistence layer is injectable so widget/unit tests can use deterministic in-memory storage instead of platform plugins.

See `PHASE_16_PERSISTENT_CUSTOMER_STATE.md`, `PHASE_16_CODE_INDEX.md`, and `PHASE_16_VERIFICATION_REPORT.md`.

## Phase 15.1 — Geocoding 5.x compatibility

Fixed the Phase 15 Google Maps location picker for `geocoding 5.x`. Forward and reverse geocoding now use a `Geocoding` instance, eliminating the compile errors for `locationFromAddress` and `placemarkFromCoordinates`.

# DCX Online Store — Phase 15 Cumulative Build

Version: `1.15.0+48`

This cumulative Flutter build preserves all previous commerce, launch, theme, promotion, payment, order, notification and support work, then upgrades delivery addresses, optional Google Maps location selection and footer placement for a cleaner international-app experience.

## Phase 15 highlight

- Persistent saved delivery addresses shared between Checkout and Profile.
- Home / Work / Other address types with a fast reuse flow.
- **Save this address for future use** at checkout.
- Optional Google Maps search/pin selection and reverse-geocoded address preview.
- Full branded footer moved to Profile with Sajahan Mansoor / DataCubeX Technologies developer credit.
- Minimal logo-free Home social/link section.
- Dedicated About / Privacy / Terms / Refund information destinations.
- New saved-address, footer and reuse regression tests.

See `PHASE_15_PREMIUM_ADDRESS_MAPS_FOOTER.md`, `PHASE_15_CODE_INDEX.md`, `PHASE_15_VERIFICATION_REPORT.md`, and `GOOGLE_MAPS_SETUP.md`.

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
- Promotions, promo codes and savings engine
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

## Phase 11 — Adaptive Dark Mode & Design System

Phase 11 adds persistent System/Light/Dark appearance modes, a Material 3 dark palette, theme-aware system bars, a responsive Appearance settings screen, and dark-aware shared Account/Home/navigation/product surfaces. The Phase 10.7 branded native-to-Flutter launch sequence and official DCX logo remain unchanged.

Run after extracting:

```powershell
flutter clean
flutter pub get
dart format lib test
flutter analyze
flutter test
flutter run
```


## Phase 11.3 — Lazy Theme Storage Fix
ThemeController no longer constructs SharedPreferencesAsync until a real load/persist operation is requested. This keeps persist:false theme switching test-safe while preserving production persistence.


## Phase 11.4
Global Material 3 typography is now offline-safe and uses each platform's native system font family while preserving DCX sizing/weight hierarchy. This removes runtime Google Fonts HTTP requests and makes theme tests deterministic.

## Phase 11.5 — Appearance Responsive Test Fix

Phase 11.5 hardens the Appearance settings regression coverage for Flutter `ListView` lazy building. Theme cards now have deterministic semantic keys, the settings list has a stable scroll key, and compact-device tests scroll the Dark option into view before validating and selecting it. No visual design or theme behavior was changed.


## Phase 12 — Professional Promotions & Savings Engine

- Adds validated promo-code application in both Cart and Checkout.
- Adds percentage, fixed-amount and free-delivery promotion types.
- Adds responsive compact-phone promo entry and accessible applied-offer state.
- Order summary now reflects promotion savings and final payable total.
- Promotion eligibility is automatically reconciled after cart quantity/line changes.
- Demo promotion rules are isolated in `DemoPromotions` so a future backend/API can replace the source cleanly.
- New controller and responsive widget regression tests cover the promotion flow.

Demo QA codes: `WELCOME10`, `DCX25`, `FREESHIP`.

See `PHASE_12_PROMOTIONS_SAVINGS_ENGINE.md`, `PHASE_12_CODE_INDEX.md`, and `PHASE_12_VERIFICATION_REPORT.md`.

## Phase 13 — Secure Payment Flow & Order Confirmation

- Adds structured Cash on delivery / Card / Bank transfer checkout methods.
- Adds processing-safe payment orchestration with explicit payment status/reference metadata.
- Adds a professional review-and-confirm step before order placement.
- Converts the current Cart snapshot into a new My Orders record, carries promotion savings forward and clears the cart only after successful local authorization.
- Adds a premium responsive Order Confirmation screen with payment, receipt and delivery details.
- Extends Order Details with payment status/reference and promo metadata.
- Keeps raw card data out of the app layer and leaves a clean gateway integration boundary for a later Laravel/API payment phase.

See `PHASE_13_SECURE_PAYMENT_ORDER_CONFIRMATION.md`, `PHASE_13_CODE_INDEX.md`, and `PHASE_13_VERIFICATION_REPORT.md`.

## Phase 14 — Notifications & Support Center
Phase 14 adds live unread notification state, filters, preferences, automatic order-confirmation alerts, dynamic Home/Account badges, and a professional customer support center with local ticket creation. See `PHASE_14_NOTIFICATIONS_SUPPORT_CENTER.md`.


## Phase 14.1 — Support FAQ Material Surface Fix
Replaces the FAQ group's painted `Container` with a proper `Material` surface so `ExpansionTile` / `ListTile` ink and background painting use the correct Material ancestor. Stable FAQ keys and an expand/collapse responsive regression check were added. No support/business logic was changed.

## Phase 14.2 — Premium Mobile App Footer
Order Confirmation now includes a responsive commercial-app footer with trust indicators, the official DCX logo, policy labels, customer support access, copyright, and professional developer attribution to **Sajahan Mansoor · DataCubeX Technologies**. The footer is implemented as a reusable theme-aware component.

## Phase 14.3 — Order Confirmation Scrollable Test Fix
Fixes the Flutter test `_TypeError` caused by passing a `ListView` finder to `WidgetTester.scrollUntilVisible`. The test now resolves the ListView's internal `Scrollable` descendant before scrolling to the premium footer. Production UI is unchanged. Version 1.14.3+47.

## Phase 17 — Production API Foundation & Sync Readiness

Phase 17 adds an offline-first API boundary, in-memory authenticated session handling, environment-driven remote configuration and a new Profile → Data & sync experience. The app remains fully functional in local demo mode by default. See `PHASE_17_API_SETUP.md` before enabling a real backend.

## Phase 19.1.3 hotfix

Phase 19.1.3 removes the remaining reported flow-control analyzer findings from the new storefront/Firebase registration code without suppressing lint rules. See `PHASE_19_1_3_ANALYZER_FLOW_CONTROL_CLEAN.md` and `PHASE_19_1_3_VERIFICATION_REPORT.md`.
