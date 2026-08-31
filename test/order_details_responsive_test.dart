import 'package:ecommerce_mobile/core/theme/app_theme.dart';
import 'package:ecommerce_mobile/data/demo_orders.dart';
import 'package:ecommerce_mobile/features/cart/cart_controller.dart';
import 'package:ecommerce_mobile/features/orders/order_details_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  for (final size in const <Size>[
    Size(320, 568),
    Size(360, 640),
    Size(412, 915),
    Size(800, 1100),
    Size(1100, 800),
  ]) {
    testWidgets(
      'order details stay responsive at ${size.width}x${size.height}',
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
            home: OrderDetailsPage(order: DemoOrders.orders.first),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Order details'), findsOneWidget);
        expect(find.text('Arriving today'), findsOneWidget);
        expect(find.text('Delivery progress'), findsOneWidget);
        expect(tester.takeException(), isNull, reason: 'Initial order detail failed at $size');

        final scrollable = find.byType(CustomScrollView);
        await tester.dragUntilVisible(
          find.text('Tracking information'),
          scrollable,
          const Offset(0, -180),
          maxIteration: 10,
        );
        await tester.pumpAndSettle();
        expect(find.text('Tracking information'), findsOneWidget);
        expect(tester.takeException(), isNull, reason: 'Tracking card failed at $size');

        await tester.dragUntilVisible(
          find.text('Package contents'),
          scrollable,
          const Offset(0, -220),
          maxIteration: 12,
        );
        await tester.pumpAndSettle();
        expect(find.text('Package contents'), findsOneWidget);
        expect(tester.takeException(), isNull, reason: 'Package contents failed at $size');
      },
    );
  }

  testWidgets('cancelled order status remains compact on a small phone', (tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: OrderDetailsPage(order: DemoOrders.orders.last),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Order cancelled'), findsWidgets);
    expect(find.text('Cancelled'), findsWidgets);
    expect(tester.takeException(), isNull);
  });
}
