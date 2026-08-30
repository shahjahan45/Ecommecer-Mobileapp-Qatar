# Phase 4.6.1 — SecurityMessage const fix

Fixed `lib/features/auth/widgets/security_message.dart` for Flutter 3.44.7 / Dart 3.12.2.

Root cause: `Semantics` is not a const constructor in this SDK configuration, but the widget was invoked with `const Semantics(...)`.

Change:

```dart
return const Semantics(
```

became:

```dart
return Semantics(
```

The child widgets remain const where valid, so there is no functional or visual change.
