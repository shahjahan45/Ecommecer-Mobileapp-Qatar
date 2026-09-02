import 'package:ecommerce_mobile/core/theme/app_theme.dart';
import 'package:ecommerce_mobile/core/widgets/dcx_mobile_footer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('home bottom section is minimal, social and logo-free', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const Scaffold(
          body: DcxHomeBottomSection(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final section = find.byKey(const Key('dcx-home-bottom-section'));
    expect(section, findsOneWidget);
    expect(find.text('Stay connected'), findsOneWidget);
    expect(find.text('Help & Support'), findsOneWidget);
    expect(find.text('Privacy Policy'), findsOneWidget);
    expect(find.text('Terms & Conditions'), findsOneWidget);
    expect(find.text('Refund Policy'), findsOneWidget);
    expect(find.text('FAQs'), findsOneWidget);
    expect(
      find.descendant(of: section, matching: find.byType(Image)),
      findsNothing,
      reason: 'Home bottom section must not show the company logo.',
    );
    expect(tester.takeException(), isNull);
  });
}
