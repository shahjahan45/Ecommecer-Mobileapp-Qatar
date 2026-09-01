import 'package:ecommerce_mobile/features/profile/address_book_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('address book stays responsive on a small phone', (tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(home: AddressBookPage()),
    );
    await tester.pumpAndSettle();

    expect(find.text('Delivery addresses'), findsOneWidget);
    expect(find.byKey(const Key('add-address-button')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('adding an address closes safely without framework errors',
      (tester) async {
    tester.view.physicalSize = const Size(412, 915);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(home: AddressBookPage()),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('add-address-button')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('address-editor-sheet')), findsOneWidget);

    await tester.enterText(
        find.byKey(const Key('address-label-field')), 'Office');
    await tester.enterText(
        find.byKey(const Key('address-name-field')), 'DCX Customer');
    await tester.enterText(
        find.byKey(const Key('address-mobile-field')), '55555555');
    await tester.enterText(
      find.byKey(const Key('address-location-field')),
      'West Bay, Doha, Qatar',
    );

    await tester.ensureVisible(find.byKey(const Key('save-address-button')));
    await tester.tap(find.byKey(const Key('save-address-button')));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('address-editor-sheet')), findsNothing);
    expect(find.text('West Bay, Doha, Qatar'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
