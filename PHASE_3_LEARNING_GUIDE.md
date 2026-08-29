# Phase 3 Learning Guide — Professional Home UI + Reusable UI Kit

This ZIP is cumulative. It contains:

- Phase 1: Flutter foundation, theme, product/category models, navigation shell.
- Phase 2: splash, onboarding, login, register, forgot password, verification UI and validation.
- Phase 3: reusable design-system tokens, animated UI components, premium home experience, wishlist/notification entry screens and professional empty states.

## What Phase 3 teaches

### 1. Design tokens
`lib/core/design_system/app_tokens.dart` centralizes spacing, corner radius, animation timing and shadows. This prevents random UI values from spreading through the app.

### 2. Reusable animation components
- `AppPressable` adds a subtle press/scale interaction.
- `FadeSlideIn` provides reusable entrance motion.
- `AppSkeleton` provides an animated shimmer loading placeholder.
- `AppIconButton` provides a consistent icon button and notification badge.
- `EmptyStateCard` provides reusable premium empty states.

### 3. Stateful professional Home page
`lib/features/home/home_page.dart` is now stateful because it manages:
- auto-sliding promotional banners,
- page indicators,
- selected category,
- initial loading state,
- pull-to-refresh,
- local UI feedback for add-to-cart previews.

### 4. Product card interaction
`ProductCard` is now stateful. It demonstrates:
- local favorite toggling,
- animated heart state,
- Hero-ready product icon,
- discount calculation,
- press animation,
- add button feedback.

### 5. Custom bottom navigation
The default Material NavigationBar was replaced by a custom animated floating navigation surface. `IndexedStack` still preserves tab state.

## Important

Phase 3 is still UI-first. Laravel, real products, cart persistence, real wishlist persistence and Firebase are intentionally not connected yet.

## Run

```bash
flutter create .
flutter clean
flutter pub get
dart format lib test
flutter analyze
flutter run
```

If your project already has `android/`, you do not need to run `flutter create .` again.

## Expected analyzer result

`No issues found!`

If Flutter reports `Can't find service: activity` or `Can't find service: package`, that is an Android emulator boot/service problem, not a Dart build error. Use a fully booted stable Android 15/16 emulator.
