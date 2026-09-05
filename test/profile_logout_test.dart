import 'package:ecommerce_mobile/core/network/session_controller.dart';
import 'package:ecommerce_mobile/features/auth/login/login_page.dart';
import 'package:ecommerce_mobile/features/profile/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('profile exposes professional sign out confirmation', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final session = SessionController.instance;
    session.resetForTesting();
    session.activateDemoSession(email: 'customer@dcx.test');
    addTearDown(session.resetForTesting);

    await tester.pumpWidget(const MaterialApp(home: ProfilePage()));
    await tester.pumpAndSettle();

    final card = find.byKey(const Key('profile-sign-out-card'));
    expect(card, findsOneWidget);
    await tester.ensureVisible(card);
    await tester.pumpAndSettle();

    expect(find.text('Sign out securely'), findsOneWidget);
    expect(
      find.descendant(
        of: card,
        matching: find.text('Signed in as customer@dcx.test'),
      ),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const Key('profile-sign-out-action')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('profile-sign-out-sheet')), findsOneWidget);
    expect(find.text('Sign out of DCX?'), findsOneWidget);
    expect(
      find.text(
        'You are signed in as customer@dcx.test. You will need to sign in again to access your account and sync orders.',
      ),
      findsOneWidget,
    );
    expect(find.byKey(const Key('profile-sign-out-confirm')), findsOneWidget);

    await tester.tap(find.byKey(const Key('profile-sign-out-confirm')));
    await tester.pumpAndSettle();

    expect(session.isAuthenticated, isFalse);
    expect(find.byType(LoginPage), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('guest profile offers sign in instead of sign out', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final session = SessionController.instance;
    session.resetForTesting();
    addTearDown(session.resetForTesting);

    await tester.pumpWidget(const MaterialApp(home: ProfilePage()));
    await tester.pumpAndSettle();

    final card = find.byKey(const Key('profile-sign-out-card'));
    await tester.ensureVisible(card);
    await tester.pumpAndSettle();

    expect(find.text('Sign in to your account'), findsOneWidget);
    expect(find.text('Sign in'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
