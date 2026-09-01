import 'package:ecommerce_mobile/core/theme/app_theme.dart';
import 'package:ecommerce_mobile/features/cart/cart_controller.dart';
import 'package:ecommerce_mobile/features/cart/cart_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const sizes = <Size>[
    Size(320, 568),
    Size(360, 640),
    Size(390, 844),
    Size(412, 915),
    Size(800, 1100),
    Size(1100, 800),
  ];

  for (final size in sizes) {
    testWidgets(
      'cart stays responsive at ${size.width}x${size.height}',
      (tester) async {
        CartController.instance.resetForTesting(withDemoItems: true);
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(CartController.instance.resetForTesting);

        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.lightTheme,
            home: const CartPage(),
          ),
        );
        await tester.pumpAndSettle();

        // Validate the initial viewport first. On short phones the order
        // summary is intentionally below the fold and is lazily built by the
        // CustomScrollView, so it must not be expected before scrolling.
        expect(find.text('My Cart'), findsOneWidget);
        expect(find.text('Checkout'), findsOneWidget);
        expect(
          tester.takeException(),
          isNull,
          reason: 'Initial cart viewport failed at size $size',
        );

        final cartScrollView = find.byType(CustomScrollView);
        expect(cartScrollView, findsOneWidget);

        // Exercise the real user path: scroll down until the lazy summary
        // sliver is built and visible, then verify it without any overflow.
        await tester.dragUntilVisible(
          find.text('Order summary'),
          cartScrollView,
          const Offset(0, -220),
          maxIteration: 12,
        );
        await tester.pumpAndSettle();

        expect(find.text('Order summary'), findsOneWidget);
        expect(
          tester.takeException(),
          isNull,
          reason: 'Scrolled cart viewport failed at size $size',
        );
      },
    );
  }

  testWidgets('empty cart remains scrollable and overflow free',
      (tester) async {
    CartController.instance.resetForTesting();
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(CartController.instance.resetForTesting);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const CartPage(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Your cart is waiting'), findsOneWidget);
    expect(find.byType(ListView), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
