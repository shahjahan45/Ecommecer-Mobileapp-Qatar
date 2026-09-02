import 'package:ecommerce_mobile/core/theme/app_theme.dart';
import 'package:ecommerce_mobile/data/demo_catalog.dart';
import 'package:ecommerce_mobile/features/checkout/order_confirmation_page.dart';
import 'package:ecommerce_mobile/models/payment.dart';
import 'package:ecommerce_mobile/models/shop_order.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final order = ShopOrder(
    id: 'DCX-260901-1300',
    placedAt: DateTime(2026, 9, 1, 19, 0),
    status: ShopOrderStatus.processing,
    items: <ShopOrderItem>[
      ShopOrderItem(product: DemoCatalog.products.first, quantity: 1),
    ],
    deliveryFee: 0,
    discount: 10,
    deliveryLabel: 'Order confirmed',
    deliveryWindow: 'Standard delivery selected',
    carrier: 'DCX Express',
    trackingNumber: 'Pending assignment',
    deliveryAddress: 'Test Customer • Doha, Qatar',
    paymentMethod: 'Card payment',
    paymentStatus: CheckoutPaymentStatus.paid,
    paymentReference: 'CARD-TEST-1300',
    promotionCode: 'WELCOME10',
  );

  for (final size in const <Size>[
    Size(320, 568),
    Size(360, 640),
    Size(412, 915),
    Size(800, 1100),
  ]) {
    testWidgets(
      'order confirmation stays responsive at ${size.width}x${size.height}',
      (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            home: OrderConfirmationPage(order: order),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('order-confirmation-page')), findsOneWidget);
        expect(find.text('Thank you for your order'), findsOneWidget);
        expect(find.text('Payment authorized'), findsOneWidget);
        expect(find.byKey(const Key('confirmation-support-card')), findsOneWidget);
        expect(find.byKey(const Key('dcx-mobile-footer')), findsNothing);
        expect(tester.takeException(), isNull, reason: 'Failed at size $size');
      },
    );
  }
}
