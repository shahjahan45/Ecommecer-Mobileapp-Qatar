import 'package:ecommerce_mobile/core/theme/app_theme.dart';
import 'package:ecommerce_mobile/data/demo_orders.dart';
import 'package:ecommerce_mobile/features/cart/cart_controller.dart';
import 'package:ecommerce_mobile/features/profile/address/address_book_controller.dart';
import 'package:ecommerce_mobile/features/checkout/checkout_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('checkout can select card and reach order confirmation', (tester) async {
    final cart = CartController.instance;
    cart.resetForTesting(withDemoItems: true);
    AddressBookController.instance.resetForTesting();
    final initialOrders = DemoOrders.orders.length;
    tester.view.physicalSize = const Size(412, 915);
    tester.view.devicePixelRatio = 1;

    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(() {
      cart.resetForTesting();
      AddressBookController.instance.resetForTesting();
      while (DemoOrders.orders.length > initialOrders) {
        DemoOrders.orders.removeAt(0);
      }
    });

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const CheckoutPage(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('checkout-address-option')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('checkout-address-name')), 'Phase 13 Customer');
    await tester.enterText(find.byKey(const Key('checkout-address-mobile')), '55512345');
    await tester.enterText(find.byKey(const Key('checkout-address-line')), 'Doha, Qatar');
    await tester.ensureVisible(find.byKey(const Key('checkout-save-address')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('checkout-save-address')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('checkout-payment-option')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey<String>('checkout-payment-card')));
    await tester.pumpAndSettle();

    expect(find.text('Card payment'), findsWidgets);
    await tester.tap(find.text('Review order'));
    await tester.pumpAndSettle();

    expect(find.text('Review and confirm'), findsOneWidget);
    await tester.tap(find.byKey(const Key('checkout-confirm-order')));
    await tester.pump(const Duration(milliseconds: 850));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('order-confirmation-page')), findsOneWidget);
    expect(find.text('Payment authorized'), findsOneWidget);
    expect(cart.isEmpty, isTrue);
    expect(tester.takeException(), isNull);
  });
}
