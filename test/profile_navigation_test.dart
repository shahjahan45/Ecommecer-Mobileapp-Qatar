import 'package:ecommerce_mobile/features/profile/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
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
}
