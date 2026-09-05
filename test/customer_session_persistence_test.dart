import 'package:ecommerce_mobile/core/persistence/customer_session_persistence.dart';
import 'package:ecommerce_mobile/data/demo_catalog.dart';
import 'package:ecommerce_mobile/data/demo_orders.dart';
import 'package:ecommerce_mobile/features/cart/cart_controller.dart';
import 'package:ecommerce_mobile/features/notifications/notification_controller.dart';
import 'package:ecommerce_mobile/features/support/support_controller.dart';
import 'package:ecommerce_mobile/features/wishlist/wishlist_controller.dart';
import 'package:ecommerce_mobile/models/app_notification.dart';
import 'package:ecommerce_mobile/models/payment.dart';
import 'package:ecommerce_mobile/models/shop_order.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final cart = CartController.instance;
  final wishlist = WishlistController.instance;
  final notifications = NotificationController.instance;
  final support = SupportController.instance;

  setUp(() {
    cart.resetForTesting();
    wishlist.resetToDemoDefaults();
    notifications.resetForTesting();
    support.resetForTesting();
    DemoOrders.resetCustomerOrdersForTesting();
  });

  tearDown(() {
    cart.resetForTesting();
    wishlist.resetToDemoDefaults();
    notifications.resetForTesting();
    support.resetForTesting();
    DemoOrders.resetCustomerOrdersForTesting();
  });

  test('customer session snapshot restores shopping continuity', () async {
    final storage = MemoryCustomerSessionStorage();
    final saver = CustomerSessionPersistence.forTesting(storage);

    final headphones = DemoCatalog.products.first;
    cart.add(headphones, quantity: 2);
    expect(cart.applyPromotion('WELCOME10').applied, isTrue);

    wishlist.restore(<int>{headphones.id, DemoCatalog.products[2].id});
    notifications.markAllRead();
    notifications.updatePreference(AppNotificationType.promotion, false);

    support.createTicket(
      category: 'Order',
      subject: 'Keep this request',
      message: 'This support request should survive a local session restore.',
      createdAt: DateTime(2026, 9, 2, 12, 30),
    );

    DemoOrders.addCustomerOrder(
      ShopOrder(
        id: 'DCX-260902-5555',
        placedAt: DateTime(2026, 9, 2, 12, 35),
        status: ShopOrderStatus.processing,
        items: <ShopOrderItem>[
          ShopOrderItem(product: headphones, quantity: 1),
        ],
        deliveryFee: 0,
        discount: 10,
        deliveryLabel: 'Order confirmed',
        deliveryWindow: 'Standard delivery selected',
        carrier: 'DCX Express',
        trackingNumber: 'Pending assignment',
        deliveryAddress: 'Doha, Qatar',
        paymentMethod: 'Cash on delivery',
        paymentStatus: CheckoutPaymentStatus.payOnDelivery,
        paymentReference: 'COD-5555',
        promotionCode: 'WELCOME10',
        shippingHistory: const <ShippingEvent>[
          ShippingEvent(
            title: 'Order confirmed',
            description: 'We received your order successfully.',
            timestamp: 'Today, 12:35 PM',
          ),
        ],
      ),
    );

    await saver.save();
    expect(storage.values[CustomerSessionPersistence.storageKey], isNotNull);

    cart.resetForTesting();
    wishlist.restore(<int>{});
    notifications.resetForTesting();
    support.resetForTesting();
    DemoOrders.resetCustomerOrdersForTesting();

    final loader = CustomerSessionPersistence.forTesting(storage);
    await loader.load();

    expect(cart.totalQuantity, 2);
    expect(cart.appliedPromotion?.code, 'WELCOME10');
    expect(wishlist.contains(headphones), isTrue);
    expect(wishlist.contains(DemoCatalog.products[2]), isTrue);
    expect(notifications.unreadCount, 0);
    expect(
      notifications.preferenceFor(AppNotificationType.promotion),
      isFalse,
    );
    expect(
      support.tickets.any((ticket) => ticket.subject == 'Keep this request'),
      isTrue,
    );
    expect(DemoOrders.customerOrders, hasLength(1));
    expect(DemoOrders.customerOrders.single.id, 'DCX-260902-5555');
    expect(loader.lastSavedAt, isNotNull);
  });


  test('order sync snapshot carries immutable checkout prices and totals', () {
    final persistence = CustomerSessionPersistence.forTesting(
      MemoryCustomerSessionStorage(),
    );
    final backpack = DemoCatalog.products[3];
    final skincare = DemoCatalog.products[4];

    DemoOrders.addCustomerOrder(
      ShopOrder(
        id: 'DCX-260903-7813',
        placedAt: DateTime(2026, 9, 3, 11, 22),
        status: ShopOrderStatus.processing,
        items: <ShopOrderItem>[
          ShopOrderItem(product: backpack, quantity: 3, unitPrice: 149),
          ShopOrderItem(product: skincare, quantity: 1, unitPrice: 119),
        ],
        deliveryFee: 0,
        discount: 50,
        deliveryLabel: 'Order confirmed',
        deliveryWindow: 'Standard delivery selected',
        carrier: 'DCX Express',
        trackingNumber: 'Pending assignment',
        deliveryAddress: 'Doha, Qatar',
        paymentMethod: 'Cash on delivery',
        paymentStatus: CheckoutPaymentStatus.payOnDelivery,
        promotionCode: 'WELCOME10',
      ),
    );

    final snapshot = persistence.createSnapshotForTesting(
      savedAt: DateTime(2026, 9, 3, 11, 23),
    );
    final orders = snapshot['customerOrders'] as List<dynamic>;
    final order = Map<String, dynamic>.from(orders.single as Map);
    final items = order['items'] as List<dynamic>;
    final firstItem = Map<String, dynamic>.from(items.first as Map);

    expect(firstItem['productId'], 4);
    expect(firstItem['productName'], 'Urban Carry Minimal Backpack');
    expect(firstItem['unitPrice'], 149.0);
    expect(firstItem['lineTotal'], 447.0);
    expect(order['subtotal'], 566.0);
    expect(order['discount'], 50.0);
    expect(order['total'], 516.0);
    expect(order['currency'], 'QAR');
  });

  test('invalid catalog ids are ignored without breaking restore', () {
    final persistence = CustomerSessionPersistence.forTesting(
      MemoryCustomerSessionStorage(),
    );

    persistence.applySnapshotForTesting(<String, dynamic>{
      'version': 1,
      'savedAt': '2026-09-02T12:00:00.000',
      'cart': <String, dynamic>{
        'items': <Map<String, dynamic>>[
          <String, dynamic>{
            'productId': 999999,
            'quantity': 2,
            'variant': null,
          },
        ],
      },
      'wishlistProductIds': <int>[999999],
    });

    expect(cart.isEmpty, isTrue);
    expect(wishlist.isEmpty, isTrue);
  });
}
