# Phase 2 Learning Guide

## 1. Splash
`SplashPage` owns a short animation and timer, then uses `pushReplacement` so the user cannot return to splash.

## 2. Onboarding
`PageView` manages three onboarding pages. `PageController` advances pages smoothly. Animated width dots show progress.

## 3. Reusable form widgets
`AuthTextField`, `PrimaryButton`, and `AuthScaffold` prevent repeated UI code across Login, Register, and Forgot Password.

## 4. Validation
`Validators` centralizes email/mobile/password rules. Real server validation will still be required later; Flutter validation is only user feedback.

## 5. Login
The login form validates fields, shows a temporary loading state, then navigates to `MainNavigation`. This is a demo until Laravel Sanctum is connected.

## 6. Register
Registration validates name, email, mobile, password, confirmation, and Terms acceptance, then opens the verification UI.

## 7. Verification
Six individual numeric fields show how an OTP screen works. The current phase accepts any six digits; backend verification comes later.

## 8. Navigation
`AppPageRoute` centralizes fade + slide transitions so each screen does not invent a different transition.
