import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ecommerce_mobile/core/theme/app_theme.dart';
import 'package:ecommerce_mobile/features/support/support_controller.dart';
import 'package:ecommerce_mobile/features/support/support_request_page.dart';

void main() {
  testWidgets('customer can submit a local support request', (tester) async {
    SupportController.instance.resetForTesting();
    final before = SupportController.instance.tickets.length;

    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.lightTheme, home: const SupportRequestPage()),
    );

    await tester.enterText(find.byKey(const Key('support-subject')), 'Payment question');
    await tester.enterText(
      find.byKey(const Key('support-message')),
      'Please help me confirm the payment status for my latest order.',
    );
    await tester.tap(find.byKey(const Key('submit-support-request')));
    await tester.pumpAndSettle();

    expect(SupportController.instance.tickets.length, before + 1);
  });
}
