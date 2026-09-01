import 'package:ecommerce_mobile/features/auth/splash/splash_page.dart';
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
      'premium launch stays responsive at ${size.width}x${size.height}',
      (tester) async {
        await tester.binding.setSurfaceSize(size);
        addTearDown(() => tester.binding.setSurfaceSize(null));

        await tester.pumpWidget(
          const MaterialApp(
            debugShowCheckedModeBanner: false,
            home: SplashPage(),
          ),
        );

        expect(
          find.bySemanticsLabel('DCX Online Store official logo'),
          findsOneWidget,
        );
        final firstFrameLogo = tester.widget<FadeTransition>(
          find.byKey(const Key('launch-logo-first-frame')),
        );
        expect(firstFrameLogo.opacity.value, greaterThanOrEqualTo(0.94));
        expect(
          find.bySemanticsLabel('Smart Shopping. Better. Faster. Smarter.'),
          findsOneWidget,
        );
        expect(
          find.bySemanticsLabel('Opening DCX Online Store'),
          findsOneWidget,
        );
        expect(find.byType(CircularProgressIndicator), findsNothing);
        expect(tester.takeException(), isNull);

        // The branded Flutter launch remains visible long enough for its
        // staged motion to be readable, then overlaps onboarding during the
        // final 650 ms handoff.
        await tester.pump(const Duration(milliseconds: 2200));
        expect(find.byKey(const Key('onboarding-page')), findsNothing);
        expect(tester.takeException(), isNull);

        await tester.pump(const Duration(milliseconds: 980));
        await tester.pump(const Duration(milliseconds: 80));

        expect(
          find.byKey(const Key('launch-handoff-transition')),
          findsOneWidget,
        );
        expect(find.byKey(const Key('onboarding-page')), findsOneWidget);
        expect(tester.takeException(), isNull);

        await tester.pumpAndSettle();

        expect(find.text('Skip'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('reduced motion reaches onboarding without launch animation',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(360, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        builder: (context, child) {
          final mediaQuery = MediaQuery.of(context);
          return MediaQuery(
            data: mediaQuery.copyWith(disableAnimations: true),
            child: child ?? const SizedBox.shrink(),
          );
        },
        home: const SplashPage(),
      ),
    );

    expect(
      find.bySemanticsLabel('DCX Online Store official logo'),
      findsOneWidget,
    );
    expect(
      find.bySemanticsLabel('Opening DCX Online Store'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);

    await tester.pump(const Duration(milliseconds: 380));
    await tester.pumpAndSettle();

    expect(find.text('Skip'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
