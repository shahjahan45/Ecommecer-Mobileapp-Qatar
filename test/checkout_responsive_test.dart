import 'package:ecommerce_mobile/core/theme/app_theme.dart';
import 'package:ecommerce_mobile/features/cart/cart_controller.dart';
import 'package:ecommerce_mobile/features/checkout/checkout_page.dart';
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
    testWidgets(
      'checkout foundation stays responsive at ${size.width}x${size.height}',
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
            home: const CheckoutPage(),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Checkout'), findsOneWidget);
        expect(find.text('Secure checkout'), findsOneWidget);
        expect(find.text('Review order'), findsOneWidget);
        expect(tester.takeException(), isNull, reason: 'Failed at size $size');
      },
    );
  }

  testWidgets(
    'delivery address sheet saves and closes without framework errors',
    (tester) async {
      CartController.instance.resetForTesting(withDemoItems: true);
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(CartController.instance.resetForTesting);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const CheckoutPage(),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Add address'));
      await tester.pumpAndSettle();

      expect(find.text('Delivery address'), findsWidgets);
      await tester.enterText(
        find.byKey(const Key('checkout-address-name')),
        'Test Customer',
      );
      await tester.enterText(
        find.byKey(const Key('checkout-address-mobile')),
        '55512345',
      );
      await tester.enterText(
        find.byKey(const Key('checkout-address-line')),
        'Doha, Qatar',
      );

      await tester.tap(find.byKey(const Key('checkout-save-address')));
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.textContaining('Test Customer'), findsOneWidget);
      expect(find.textContaining('Doha, Qatar'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
