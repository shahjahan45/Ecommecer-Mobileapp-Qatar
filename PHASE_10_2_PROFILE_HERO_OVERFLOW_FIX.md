# Phase 10.2 — Profile Hero Overflow Fix

## Root cause
The remaining 320/360 px profile regression was not in the Quick Access rail. The hero status chip used an intrinsic-width `Row(mainAxisSize: MainAxisSize.min)` containing the full “Secure account center” label. Flutter test font metrics could make that row wider than the hero's compact inner width, producing a right-side RenderFlex overflow (4.8 px at 360 px).

## Fix
- Replaced the intrinsic-width status chip with a bounded, full-width status banner.
- Shield icon remains fixed-size.
- Status text is inside `Expanded`, with one-line ellipsis as a final safety net.
- Compact hero widths use slightly smaller horizontal padding, icon and status font sizing.
- Phase 10.1 Quick Access rail remains unchanged.
- Profile navigation and business logic are unchanged.

## Regression coverage
`profile_responsive_test.dart` still covers 320×568, 360×640, 390×844, 412×915, 800×1100 and 1100×800, and now explicitly checks that the secure status text is present before asserting that no framework exception occurred.
