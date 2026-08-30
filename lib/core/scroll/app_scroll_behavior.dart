import 'package:flutter/material.dart';

/// Native-feeling scrolling for DCX Online Store.
///
/// Android uses clamping physics for predictable commerce-page scrolling.
/// iOS/macOS retain the native light bounce. AlwaysScrollableScrollPhysics
/// keeps pull/drag interaction available even on short pages.
class AppScrollBehavior extends MaterialScrollBehavior {
  const AppScrollBehavior();

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    final platform = getPlatform(context);

    if (platform == TargetPlatform.iOS || platform == TargetPlatform.macOS) {
      return const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      );
    }

    return const ClampingScrollPhysics(
      parent: AlwaysScrollableScrollPhysics(),
    );
  }
}
