# Phase 9.1 — Account Security const fix

Fixed Flutter analyzer error in `lib/features/profile/account_security_page.dart`.

The outer `ListView.children` list was declared `const`, while this Flutter SDK does not accept the nested `ConstrainedBox` invocation as a const expression. The outer list is now non-const; valid inner const widgets remain unchanged.

No UI, navigation, account logic, checkout logic, authentication, or branding behavior changed.

Project version: `1.9.1+27`.
