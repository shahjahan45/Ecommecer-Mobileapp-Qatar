# Phase 10.4 — Launch Semantics Fix

## Root cause
`LaunchProgressIndicator` correctly exposed the semantics label `Opening DCX Online Store`, but its parent `FadeTransition` began at opacity 0 and did not set `alwaysIncludeSemantics: true`. Flutter therefore excluded that subtree from the semantics tree during the initial test frame.

## Fix
Added `alwaysIncludeSemantics: true` to the progress-layer `FadeTransition` in `SplashPage`.

## Scope
- No visual redesign.
- No animation duration changes.
- No navigation changes.
- No logo changes.
- No progress painter changes.
- Existing reduced-motion behavior preserved.

## Regression contract
The launch screen must expose these semantics immediately after first pump, including while fade opacity is zero:
- `DCX Online Store official logo`
- `Smart Shopping. Better. Faster. Smarter.`
- `Opening DCX Online Store`
