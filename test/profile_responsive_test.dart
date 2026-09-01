import 'package:ecommerce_mobile/features/profile/profile_page.dart';
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
    testWidgets('account center stays responsive at ${size.width}x${size.height}', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(home: ProfilePage()),
      );
      await tester.pumpAndSettle();

      expect(find.text('My DCX account'), findsOneWidget);
      expect(find.text('Quick access'), findsOneWidget);
      expect(find.text('Orders'), findsWidgets);
      expect(find.text('Wishlist'), findsWidgets);
      expect(find.text('Secure account center'), findsOneWidget);

      if (size.width <= 360) {
        expect(
          find.byKey(const Key('account-quick-actions-scroll')),
          findsOneWidget,
        );
      }

      expect(tester.takeException(), isNull);

      await tester.dragUntilVisible(
        find.text('Help & support'),
        find.byKey(const PageStorageKey<String>('profile-account-scroll')),
        const Offset(0, -180),
        maxIteration: 15,
      );
      await tester.pumpAndSettle();

      expect(find.text('Help & support'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
