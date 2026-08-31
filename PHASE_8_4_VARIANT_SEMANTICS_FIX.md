# Phase 8.4 — Stable Variant Accessibility Semantics

## Fix
The sports-size regression test could locate the visual `42` widget but could not find an exact semantics label `size 42`. The variant button previously allowed descendant text/icon semantics to merge with the parent semantics node. Once the selected check icon was present, the final semantics representation was not guaranteed to remain an exact single-label node.

Phase 8.4 makes each text/color variant a deterministic semantics container:
- `container: true`
- `excludeSemantics: true`
- explicit `label`
- explicit `button` and `selected` flags
- explicit semantic `onTap` action

The visual UI, variant values, selection callback, cart logic, product model and navigation are unchanged.

Text variants normalize headings such as `Select size` to stable lowercase labels such as `size 42`. Color variants retain labels such as `Color Midnight`.
