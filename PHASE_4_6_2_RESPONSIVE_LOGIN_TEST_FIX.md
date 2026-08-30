# Phase 4.6.2 — Responsive Login Test Fix

Root cause: the Remember/Forgot controls used a hard 320px breakpoint inside the login card. At a 412px screen the card inner width is roughly 328px, which selected the horizontal Row path at a fragile boundary. Font/layout metrics could then produce a RenderFlex exception that was captured by `tester.takeException()`.

Fixes:
- Replaced the breakpoint Row/Column switch with `Wrap`, allowing natural line wrapping.
- Changed the security footer to a bounded Row + Expanded text layout.
- Added 400/411/412/413px regression widths around the former failure boundary.
- No auth/API/backend behavior changed.
