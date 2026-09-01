import 'package:ecommerce_mobile/core/theme/app_theme.dart';
import 'package:ecommerce_mobile/core/theme/theme_controller.dart';
import 'package:ecommerce_mobile/features/profile/appearance_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  for (final size in const <Size>[
    Size(320, 568),
    Size(360, 640),
    Size(412, 915),
    Size(800, 1100),
  ]) {
    testWidgets('appearance stays responsive at ${size.width}x${size.height}',
        (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final controller = ThemeController.instance;
      await controller.setPreference(DcxThemePreference.light, persist: false);

      await tester.pumpWidget(
        AnimatedBuilder(
          animation: controller,
          builder: (context, child) {
            return MaterialApp(
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: controller.themeMode,
              home: const AppearancePage(),
            );
          },
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Appearance'), findsOneWidget);
      expect(find.text('Use device setting'), findsOneWidget);
      expect(find.text('Light'), findsOneWidget);
      expect(tester.takeException(), isNull);

      final darkThemeCard = find.byKey(
        const ValueKey<String>('appearance-theme-dark'),
      );
      final appearanceScroll = find.byKey(
        const PageStorageKey<String>('appearance-scroll'),
      );

      // Theme options live in a real scrollable settings page. On compact
      // devices the Dark card may not be built until it enters the ListView
      // cache/viewport, so mirror the user interaction instead of assuming
      // every child exists on the initial frame.
      await tester.dragUntilVisible(
        darkThemeCard,
        appearanceScroll,
        const Offset(0, -150),
        maxIteration: 12,
      );
      await tester.pumpAndSettle();

      expect(darkThemeCard, findsOneWidget);
      expect(find.text('Dark'), findsOneWidget);
      expect(find.bySemanticsLabel('Dark theme'), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.tap(darkThemeCard);
      await tester.pumpAndSettle();

      final pageContext = tester.element(find.byType(AppearancePage));
      expect(Theme.of(pageContext).brightness, Brightness.dark);
      expect(
        tester.widget<Semantics>(darkThemeCard).properties.selected,
        isTrue,
      );
      expect(tester.takeException(), isNull);

      await controller.setPreference(DcxThemePreference.system, persist: false);
    });
  }
}
