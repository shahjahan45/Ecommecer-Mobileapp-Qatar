import 'package:ecommerce_mobile/core/persistence/customer_session_persistence.dart';
import 'package:ecommerce_mobile/core/theme/app_theme.dart';
import 'package:ecommerce_mobile/features/profile/widgets/shopping_continuity_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final size in <Size>[
    const Size(320, 568),
    const Size(360, 640),
    const Size(800, 1100),
  ]) {
    testWidgets('shopping continuity card is responsive at ${size.width}x${size.height}', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(size);
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final persistence = CustomerSessionPersistence.forTesting(
        MemoryCustomerSessionStorage(),
      );
      persistence.applySnapshotForTesting(<String, dynamic>{
        'version': 1,
        'savedAt': '2026-09-02T12:15:00.000',
      });

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: ShoppingContinuityCard(persistence: persistence),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('shopping-continuity-card')), findsOneWidget);
      expect(find.text('Shopping continuity'), findsOneWidget);
      expect(find.byKey(const Key('shopping-continuity-save-now')), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
