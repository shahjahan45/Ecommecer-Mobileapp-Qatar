import 'package:ecommerce_mobile/core/theme/app_theme.dart';
import 'package:ecommerce_mobile/features/auth/login/login_page.dart';
import 'package:ecommerce_mobile/features/auth/widgets/social_login_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const sizes = <Size>[
    Size(320, 568),
    Size(360, 640),
    Size(390, 844),
    Size(412, 915),
    Size(800, 1100),
  ];

  for (final size in sizes) {
    testWidgets('premium login lays out at ${size.width}x${size.height}',
        (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const LoginPage(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Welcome back'), findsOneWidget);
      expect(find.text('Sign in'), findsOneWidget);
      expect(find.byType(SocialIconButton), findsNWidgets(5));
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Image &&
              widget.image is AssetImage &&
              (widget.image as AssetImage).assetName ==
                  'assets/icon/app_icon.png',
        ),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });
  }

  for (final size in const <Size>[Size(360, 640), Size(412, 915)]) {
    testWidgets(
      'validation errors stay responsive at ${size.width}x${size.height}',
      (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.lightTheme,
            home: const LoginPage(),
          ),
        );
        await tester.pumpAndSettle();

        await tester.ensureVisible(find.text('Sign in'));
        await tester.tap(find.text('Sign in'));
        await tester.pumpAndSettle();

        expect(find.text('Email is required'), findsOneWidget);
        expect(find.text('Password is required'), findsOneWidget);
        expect(find.text('Remember me'), findsOneWidget);
        expect(find.text('Forgot password?'), findsOneWidget);
        expect(find.byType(SocialIconButton), findsNWidgets(5));
        expect(tester.takeException(), isNull);

        await tester.ensureVisible(find.text('Sign up'));
        await tester.pumpAndSettle();
        expect(find.text('Sign up'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('small screen can scroll from header to sign up', (tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const LoginPage(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Welcome back'), findsOneWidget);
    await tester.ensureVisible(find.text('Sign up'));
    await tester.pumpAndSettle();
    expect(find.text('Sign up'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
