import 'package:ecommerce_mobile/core/theme/app_theme.dart';
import 'package:ecommerce_mobile/features/cart/cart_controller.dart';
import 'package:ecommerce_mobile/features/checkout/checkout_page.dart';
import 'package:ecommerce_mobile/features/profile/address/address_book_controller.dart';
import 'package:ecommerce_mobile/models/saved_address.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('checkout reuses a saved default address without typing it again', (tester) async {
    CartController.instance.resetForTesting(withDemoItems: true);
    AddressBookController.instance.resetForTesting(
      addresses: <SavedAddress>[
        SavedAddress(
          id: 'home-1',
          type: SavedAddressType.home,
          fullName: 'Saved Customer',
          mobile: '55512345',
          addressLine: 'The Pearl, Doha, Qatar',
          isDefault: true,
          createdAt: DateTime(2026, 9, 2),
        ),
      ],
    );
    addTearDown(CartController.instance.resetForTesting);
    addTearDown(AddressBookController.instance.resetForTesting);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const CheckoutPage(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('The Pearl, Doha, Qatar'), findsOneWidget);

    await tester.tap(find.byKey(const Key('checkout-address-option')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey<String>('checkout-saved-address-home-1')), findsOneWidget);
    expect(find.byKey(const Key('checkout-use-saved-address')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
