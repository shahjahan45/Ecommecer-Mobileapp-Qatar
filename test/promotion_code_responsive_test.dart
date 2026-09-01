import 'package:ecommerce_mobile/core/theme/app_theme.dart';
import 'package:ecommerce_mobile/features/cart/cart_controller.dart';
import 'package:ecommerce_mobile/features/cart/cart_page.dart';
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
      'promotion entry stays responsive and applies at ${size.width}x${size.height}',
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
            darkTheme: AppTheme.darkTheme,
            home: const CartPage(),
          ),
        );
        await tester.pumpAndSettle();

        final scrollView = find.byType(CustomScrollView);
        expect(scrollView, findsOneWidget);

        final field = find.byKey(
          const ValueKey<String>('promotion-code-field'),
        );
        await tester.dragUntilVisible(
          field,
          scrollView,
          const Offset(0, -220),
          maxIteration: 14,
        );
        await tester.pumpAndSettle();

        expect(field, findsOneWidget);
        expect(
          find.byKey(const ValueKey<String>('promotion-apply-button')),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);

        await tester.enterText(field, 'WELCOME10');
        await tester.tap(
          find.byKey(const ValueKey<String>('promotion-apply-button')),
        );
        await tester.pumpAndSettle();

        expect(
          find.byKey(const ValueKey<String>('promotion-applied-card')),
          findsOneWidget,
        );
        expect(find.text('WELCOME10'), findsWidgets);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
