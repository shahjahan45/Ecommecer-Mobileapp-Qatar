# Phase 10.3 — Premium Same-Logo Launch Redesign

- Preserves the exact official `assets/icon/app_icon.png` asset.
- Replaces the minimal Flutter splash composition with a premium light-to-navy launch scene inspired by the supplied reference direction.
- Adds purposeful logo scale/fade/lift, spatial wave reveal, orange accent, Smart Shopping hierarchy, custom ring/track progress, and reduced-motion behavior.
- Keeps launch duration short (~1.38s normal, ~0.36s reduced motion).
- Adds an Android 12+ native splash drawable that centers the exact same official logo with safe breathing room so the system splash does not crop the wide artwork like an adaptive launcher icon.
- Keeps iOS native launch screen simple/static so the first real Flutter frame owns the branded animation.
- Adds responsive launch regression coverage for 320×568, 360×640, 412×915 and 800×1100.
