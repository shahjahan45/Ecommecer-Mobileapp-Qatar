# Branding semantics test fix — v1.6.6

## Root cause
The official logo was present on SplashPage, but the initial `FadeTransition` opacity is 0. By default Flutter may exclude semantics for a fully transparent fade child, so the first-frame widget test could not find the `DCX Online Store official logo` semantics label.

## Fix
Added `alwaysIncludeSemantics: true` to the existing SplashPage `FadeTransition`. This does not change the visual animation, asset, authentication, navigation, or business logic. It only keeps the official logo accessible in the semantics tree from the first frame.

The official `assets/icon/app_icon.png` remains unchanged.
