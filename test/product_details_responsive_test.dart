import 'package:ecommerce_mobile/core/theme/app_theme.dart';
import 'package:ecommerce_mobile/data/demo_catalog.dart';
import 'package:ecommerce_mobile/features/cart/cart_controller.dart';
import 'package:ecommerce_mobile/features/products/product_details_page.dart';
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
      'product details stays responsive at ${size.width}x${size.height}',
      (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.lightTheme,
            home: ProductDetailsPage(
              product: DemoCatalog.products[0],
            ),
          ),
        );
        await tester.pump();

        expect(find.text('AirBeat Pro Wireless Headphones'), findsOneWidget);
        expect(find.text('Add to cart'), findsOneWidget);
        expect(find.text('Buy now'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('sports sizes use compact horizontal selector', (tester) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final sportsProduct = DemoCatalog.products.firstWhere(
      (product) => product.category == 'Sports',
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: ProductDetailsPage(product: sportsProduct),
      ),
    );
    await tester.pump();

    final pageScroll = find.byKey(const Key('product-details-scroll'));
    expect(pageScroll, findsOneWidget);

    await tester.dragUntilVisible(
      find.text('Select size'),
      pageScroll,
      const Offset(0, -220),
      maxIteration: 12,
    );
    await tester.pumpAndSettle();

    expect(find.text('Select size'), findsOneWidget);
    expect(find.text('Size guide'), findsOneWidget);

    final variantScroll = find.byKey(const Key('product-variant-scroll'));
    expect(variantScroll, findsOneWidget);

    // Do not assume the last size is initially inside a 320px viewport.
    // Scroll the actual horizontal selector exactly as a user would.
    final size42 = find.byKey(const ValueKey('variant-option-42'));
    expect(size42, findsOneWidget);

    await tester.dragUntilVisible(
      size42,
      variantScroll,
      const Offset(-90, 0),
      maxIteration: 8,
    );
    await tester.pumpAndSettle();

    expect(find.text('42'), findsOneWidget);

    final size42Semantics = find.bySemanticsLabel('size 42');
    expect(size42Semantics, findsOneWidget);

    await tester.tap(size42);
    await tester.pumpAndSettle();

    // The visual check icon must not change the stable accessibility label.
    expect(find.bySemanticsLabel('size 42'), findsOneWidget);
    expect(
      find.descendant(
        of: size42,
        matching: find.byIcon(Icons.check_circle_rounded),
      ),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'color variants use real swatches and buy-now navigation stays stable',
    (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      CartController.instance.resetForTesting();
      addTearDown(() => CartController.instance.resetForTesting());

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: ProductDetailsPage(
            product: DemoCatalog.products[0],
          ),
        ),
      );
      await tester.pump();

      await tester.dragUntilVisible(
        find.text('Select color'),
        find.byType(SingleChildScrollView).first,
        const Offset(0, -240),
      );
      await tester.pumpAndSettle();

      expect(find.text('Select color'), findsOneWidget);
      expect(find.text('Midnight'), findsNothing);
      expect(find.text('Lavender'), findsNothing);
      expect(find.text('Silver'), findsNothing);
      expect(find.bySemanticsLabel('Color Midnight'), findsOneWidget);
      expect(find.bySemanticsLabel('Color Lavender'), findsOneWidget);
      expect(find.bySemanticsLabel('Color Silver'), findsOneWidget);

      await tester.tap(find.bySemanticsLabel('Color Lavender'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      await tester.tap(find.text('Add to cart'));
      await tester.pump();
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      await tester.tap(find.text('Buy now'));
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('Checkout'), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.pageBack();
      await tester.pumpAndSettle();

      expect(find.text('Product details'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
