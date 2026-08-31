import 'package:ecommerce_mobile/core/theme/app_theme.dart';
import 'package:ecommerce_mobile/features/cart/cart_controller.dart';
import 'package:ecommerce_mobile/features/orders/orders_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  for (final size in const <Size>[
    Size(320, 568),
    Size(360, 640),
    Size(390, 844),
    Size(412, 915),
    Size(800, 1100),
    Size(1100, 800),
  ]) {
    testWidgets(
      'orders stay responsive at ${size.width}x${size.height}',
      (tester) async {
        CartController.instance.resetForTesting();
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(CartController.instance.resetForTesting);

        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.lightTheme,
            home: const OrdersPage(),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('My orders'), findsOneWidget);
        expect(find.text('Orders at a glance'), findsOneWidget);
        expect(find.text('All'), findsOneWidget);
        expect(tester.takeException(), isNull, reason: 'Initial orders layout failed at $size');

        final scrollable = find.byType(CustomScrollView);
        await tester.dragUntilVisible(
          find.text('DCX-260829-1048'),
          scrollable,
          const Offset(0, -180),
          maxIteration: 12,
        );
        await tester.pumpAndSettle();

        expect(find.text('DCX-260829-1048'), findsOneWidget);
        expect(tester.takeException(), isNull, reason: 'Scrolled orders layout failed at $size');
      },
    );
  }

  testWidgets('order search can show a compact no-results state', (tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const OrdersPage(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byType(TextField),
      'does-not-exist',
    );
    await tester.pumpAndSettle();

    expect(find.text('No matching orders'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
