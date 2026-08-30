# DCX Online Store v1.6.5 — Login Responsive Regression Fix

## Root cause
A later login UI polish reintroduced a breakpoint-driven `Row + Spacer` for the Remember Me / Forgot Password controls. At tight card widths, especially after validation messages expand the form, the row could exceed the available horizontal constraint and trigger a `RenderFlex overflowed ... on the right` exception.

## Fix
- Restored a natural `Wrap` layout for Remember Me / Forgot Password.
- Replaced the fit-path social `Row` with a `Wrap`; narrow widths still use horizontal scrolling.
- Social callbacks and authentication behavior are unchanged.
- Added regression coverage for validation states at 360x640 and 412x915.
- Official `assets/icon/app_icon.png` remains byte-for-byte unchanged.
