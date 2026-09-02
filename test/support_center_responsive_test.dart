import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ecommerce_mobile/core/theme/app_theme.dart';
import 'package:ecommerce_mobile/features/profile/help_support_page.dart';
import 'package:ecommerce_mobile/features/support/support_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  for (final size in const <Size>[
    Size(320, 568),
    Size(360, 640),
    Size(412, 915),
    Size(800, 1100),
  ]) {
    testWidgets('support center stays responsive at ${size.width}x${size.height}', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      SupportController.instance.resetForTesting();

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const HelpSupportPage(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('We are here to help'), findsOneWidget);
      expect(find.byKey(const Key('new-support-request')), findsOneWidget);
      expect(find.text('Your requests'), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.dragUntilVisible(
        find.byKey(const ValueKey<String>('support-faq-0')),
        find.byKey(const PageStorageKey<String>('help-support-scroll')),
        const Offset(0, -180),
        maxIteration: 18,
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('support-faq-surface')), findsOneWidget);
      expect(find.byKey(const ValueKey<String>('support-faq-0')), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.tap(find.byKey(const ValueKey<String>('support-faq-0')));
      await tester.pumpAndSettle();

      expect(
        find.text('Open My orders, select the order, and use the integrated tracking timeline.'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });
  }
}
