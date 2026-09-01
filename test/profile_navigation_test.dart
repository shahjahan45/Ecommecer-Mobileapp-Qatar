import 'package:ecommerce_mobile/core/theme/app_theme.dart';
import 'package:ecommerce_mobile/core/theme/theme_controller.dart';
import 'package:ecommerce_mobile/features/profile/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('profile quick access opens delivery addresses', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(home: ProfilePage()),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Addresses').first);
    await tester.pumpAndSettle();

    expect(find.text('Delivery addresses'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('profile opens appearance settings', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final controller = ThemeController.instance;
    await controller.setPreference(DcxThemePreference.light, persist: false);
    addTearDown(() async {
      await controller.setPreference(DcxThemePreference.system, persist: false);
    });

    await tester.pumpWidget(
      AnimatedBuilder(
        animation: controller,
        builder: (context, child) {
          return MaterialApp(
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: controller.themeMode,
            home: const ProfilePage(),
          );
        },
      ),
    );
    await tester.pumpAndSettle();

    // Catch profile-layout exceptions before navigation so this test reports
    // the actual failing stage instead of collapsing them into a multi-error.
    expect(tester.takeException(), isNull);

    final appearanceAction = find.byKey(
      const Key('profile-appearance-action'),
    );
    expect(appearanceAction, findsOneWidget);

    await tester.ensureVisible(appearanceAction);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    await tester.tap(appearanceAction);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('appearance-page')), findsOneWidget);
    expect(find.text('Make DCX feel like yours'), findsOneWidget);
    expect(find.text('Use device setting'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
