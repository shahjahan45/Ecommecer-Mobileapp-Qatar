import 'package:ecommerce_mobile/core/theme/app_theme.dart';
import 'package:ecommerce_mobile/data/demo_catalog.dart';
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
      expect(tester.takeException(), isNull);
    });
  }
}
