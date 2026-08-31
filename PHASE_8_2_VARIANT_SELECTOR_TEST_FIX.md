# Phase 8.2 — Variant Selector Test & Build Fix

## Root cause

The sports size selector used `ListView.separated`. Flutter lazily builds horizontal list children, so on a 320px-wide widget test the trailing size `42` could be outside the initial cache/build range. The production UI could still scroll to it, but `find.text('42')` saw zero widgets before horizontal scrolling.

## Fix

- Color variants keep the Phase 8.1 real-color `ListView.separated` swatch implementation.
- Text/size/pack variants now use `SingleChildScrollView(scrollDirection: Axis.horizontal) + Row`.
- All text variant widgets are built immediately while horizontal scrolling remains available.
- No product data, cart behavior, checkout behavior, navigation, pricing, or state management changed.
- Sports regression test now confirms sizes 38–42 are present and scrolls to/taps size 42.
- Official DCX logo remains unchanged.

## Project version

`1.8.2+21`
