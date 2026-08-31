import 'package:ecommerce_mobile/core/theme/app_theme.dart';
import 'package:ecommerce_mobile/features/wishlist/wishlist_controller.dart';
import 'package:ecommerce_mobile/features/wishlist/wishlist_page.dart';
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
    Size(1100, 800),
  ];

  for (final size in sizes) {
    testWidgets(
      'wishlist stays responsive at ${size.width}x${size.height}',
      (tester) async {
        WishlistController.instance.resetToDemoDefaults();
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(WishlistController.instance.resetToDemoDefaults);

        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.lightTheme,
            home: const WishlistPage(),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Your saved favourites'), findsOneWidget);
        expect(find.byType(WishlistPage), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }

  for (final size in const <Size>[
    Size(320, 568),
    Size(360, 640),
    Size(412, 915),
  ]) {
    testWidgets(
      'wishlist empty state remains usable at ${size.width}x${size.height}',
      (tester) async {
        WishlistController.instance.resetToDemoDefaults();
        WishlistController.instance.clear();
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(WishlistController.instance.resetToDemoDefaults);

        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.lightTheme,
            home: const WishlistPage(),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Your wishlist is ready'), findsOneWidget);
        expect(find.text('Continue shopping'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('wishlist no-results state can scroll on a short phone', (tester) async {
    WishlistController.instance.resetToDemoDefaults();
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(WishlistController.instance.resetToDemoDefaults);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const WishlistPage(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byType(TextField).first,
      'product-that-does-not-exist',
    );
    await tester.pumpAndSettle();

    expect(find.text('No saved products match'), findsOneWidget);
    expect(find.text('Reset filters'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

}
