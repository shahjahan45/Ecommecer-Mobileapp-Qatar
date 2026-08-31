import '../models/shop_order.dart';
import 'demo_catalog.dart';

class DemoOrders {
  DemoOrders._();

  static final List<ShopOrder> orders = <ShopOrder>[
    ShopOrder(
      id: 'DCX-260829-1048',
      placedAt: DateTime(2026, 8, 29, 18, 42),
      status: ShopOrderStatus.outForDelivery,
      items: <ShopOrderItem>[
        ShopOrderItem(product: DemoCatalog.products[0], quantity: 1),
        ShopOrderItem(product: DemoCatalog.products[6], quantity: 2),
      ],
      deliveryFee: 0,
      discount: 20,
      deliveryLabel: 'Arriving today',
      deliveryWindow: 'Expected between 2:00 PM and 6:00 PM',
      carrier: 'DCX Express',
      trackingNumber: 'DCXQA88421057',
      deliveryAddress: 'Doha, Qatar',
      paymentMethod: 'Cash on delivery',
      shippingHistory: const <ShippingEvent>[
        ShippingEvent(
          title: 'Out for delivery',
          description: 'Your package is with the delivery partner in Doha.',
          timestamp: 'Today, 9:18 AM',
        ),
        ShippingEvent(
          title: 'Arrived at local hub',
          description: 'Package reached the Doha delivery hub.',
          timestamp: 'Today, 6:25 AM',
        ),
        ShippingEvent(
          title: 'Shipped',
          description: 'Your package left the DCX fulfillment center.',
          timestamp: 'Aug 30, 8:40 PM',
        ),
        ShippingEvent(
          title: 'Order packed',
          description: 'Items were checked and packed securely.',
          timestamp: 'Aug 30, 2:12 PM',
        ),
        ShippingEvent(
          title: 'Order confirmed',
          description: 'We received your order successfully.',
          timestamp: 'Aug 29, 6:42 PM',
        ),
      ],
    ),
    ShopOrder(
      id: 'DCX-260827-1031',
      placedAt: DateTime(2026, 8, 27, 11, 16),
      status: ShopOrderStatus.shipped,
      items: <ShopOrderItem>[
        ShopOrderItem(
          product: DemoCatalog.products[2],
          quantity: 1,
          variant: '40',
        ),
        ShopOrderItem(product: DemoCatalog.products[10], quantity: 1),
      ],
      deliveryFee: 0,
      deliveryLabel: 'Arriving Sep 2',
      deliveryWindow: 'Estimated delivery by 8:00 PM',
      carrier: 'Q-Post Priority',
      trackingNumber: 'QP2608271031',
      deliveryAddress: 'Al Wakrah, Qatar',
      paymentMethod: 'Card payment',
      shippingHistory: const <ShippingEvent>[
        ShippingEvent(
          title: 'In transit',
          description: 'Shipment is moving toward the destination hub.',
          timestamp: 'Today, 7:10 AM',
        ),
        ShippingEvent(
          title: 'Shipped',
          description: 'Carrier picked up the package from DCX.',
          timestamp: 'Aug 30, 5:24 PM',
        ),
        ShippingEvent(
          title: 'Order packed',
          description: 'Your items were packed and labelled.',
          timestamp: 'Aug 28, 10:05 AM',
        ),
        ShippingEvent(
          title: 'Order confirmed',
          description: 'Payment and order details were confirmed.',
          timestamp: 'Aug 27, 11:16 AM',
        ),
      ],
    ),
    ShopOrder(
      id: 'DCX-260819-0977',
      placedAt: DateTime(2026, 8, 19, 15, 4),
      status: ShopOrderStatus.delivered,
      items: <ShopOrderItem>[
        ShopOrderItem(product: DemoCatalog.products[4], quantity: 1),
      ],
      deliveryFee: 15,
      discount: 10,
      deliveryLabel: 'Delivered Aug 22',
      deliveryWindow: 'Delivered at 3:36 PM',
      carrier: 'DCX Express',
      trackingNumber: 'DCXQA77211603',
      deliveryAddress: 'Lusail, Qatar',
      paymentMethod: 'Cash on delivery',
      shippingHistory: const <ShippingEvent>[
        ShippingEvent(
          title: 'Delivered',
          description: 'Package was delivered successfully.',
          timestamp: 'Aug 22, 3:36 PM',
        ),
        ShippingEvent(
          title: 'Out for delivery',
          description: 'Package left the local delivery hub.',
          timestamp: 'Aug 22, 9:05 AM',
        ),
        ShippingEvent(
          title: 'Shipped',
          description: 'Package was handed to DCX Express.',
          timestamp: 'Aug 20, 7:32 PM',
        ),
        ShippingEvent(
          title: 'Order confirmed',
          description: 'We received your order successfully.',
          timestamp: 'Aug 19, 3:04 PM',
        ),
      ],
    ),
    ShopOrder(
      id: 'DCX-260812-0914',
      placedAt: DateTime(2026, 8, 12, 9, 30),
      status: ShopOrderStatus.cancelled,
      items: <ShopOrderItem>[
        ShopOrderItem(product: DemoCatalog.products[7], quantity: 1),
      ],
      deliveryFee: 0,
      deliveryLabel: 'Order cancelled',
      deliveryWindow: 'Cancelled Aug 12, 2026',
      carrier: 'Not assigned',
      trackingNumber: 'Not available',
      deliveryAddress: 'Doha, Qatar',
      paymentMethod: 'Bank transfer',
      shippingHistory: const <ShippingEvent>[
        ShippingEvent(
          title: 'Order cancelled',
          description: 'This order was cancelled before fulfillment.',
          timestamp: 'Aug 12, 10:12 AM',
        ),
        ShippingEvent(
          title: 'Order received',
          description: 'We received your order request.',
          timestamp: 'Aug 12, 9:30 AM',
        ),
      ],
    ),
  ];
}
