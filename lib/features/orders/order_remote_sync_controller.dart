import 'package:flutter/foundation.dart';

import '../../core/network/api_environment.dart';
import '../../core/network/api_models.dart';
import '../../core/network/commerce_api_gateway.dart';
import '../../core/network/session_controller.dart';
import '../../data/demo_catalog.dart';
import '../../core/storefront/storefront_controller.dart';
import '../../data/demo_orders.dart';
import '../../models/payment.dart';
import '../../models/product.dart';
import '../../models/shop_order.dart';

class OrderRemoteSyncController extends ChangeNotifier {
  OrderRemoteSyncController._();

  static final OrderRemoteSyncController instance = OrderRemoteSyncController._();

  bool _refreshing = false;
  String? _lastError;
  DateTime? _lastRefreshedAt;

  bool get isRefreshing => _refreshing;
  String? get lastError => _lastError;
  DateTime? get lastRefreshedAt => _lastRefreshedAt;

  Future<void> refresh({CommerceApiGateway? gateway}) async {
    if (_refreshing || !_canUseRemote) {
      return;
    }
    _refreshing = true;
    _lastError = null;
    notifyListeners();

    try {
      final response = await (gateway ?? HttpCommerceApiGateway()).fetchOrders();
      final raw = response['data'];
      if (raw is List) {
        final orders = <ShopOrder>[];
        for (final value in raw) {
          final map = _map(value);
          if (map == null) {
            continue;
          }
          final order = _fromRemote(map);
          if (order != null) {
            orders.add(order);
          }
        }
        DemoOrders.restoreCustomerOrders(orders);
      }
      _lastRefreshedAt = DateTime.now();
    } on ApiException catch (error) {
      _lastError = error.message;
    } catch (_) {
      _lastError = 'Order updates could not be refreshed.';
    } finally {
      _refreshing = false;
      notifyListeners();
    }
  }

  bool get _canUseRemote => ApiEnvironment.isRemoteConfigured &&
      SessionController.instance.isAuthenticated &&
      SessionController.instance.hasUsableRemoteToken;

  ShopOrder? _fromRemote(Map<String, dynamic> json) {
    final number = json['order_number'] as String?;
    final placedAt = DateTime.tryParse(json['placed_at'] as String? ?? '')?.toLocal();
    if (number == null || placedAt == null) {
      return null;
    }

    ShopOrder? local;
    for (final order in DemoOrders.orders) {
      if (order.id == number) {
        local = order;
        break;
      }
    }

    final items = <ShopOrderItem>[];
    final rawItems = json['items'];
    if (rawItems is List) {
      for (final raw in rawItems) {
        final item = _map(raw);
        if (item == null) {
          continue;
        }
        final productId = (item['product_id'] as num?)?.toInt();
        final product = _productById(productId);
        if (product == null) {
          continue;
        }
        items.add(
          ShopOrderItem(
            product: product,
            quantity: (item['quantity'] as num?)?.toInt() ?? 1,
            variant: item['variant'] as String?,
            unitPrice: (item['unit_price'] as num?)?.toDouble(),
          ),
        );
      }
    }
    if (items.isEmpty && local != null) {
      items.addAll(local.items);
    }
    if (items.isEmpty) {
      return null;
    }

    final history = <ShippingEvent>[];
    final rawTimeline = json['timeline'];
    if (rawTimeline is List) {
      for (final raw in rawTimeline.reversed) {
        final event = _map(raw);
        if (event == null) {
          continue;
        }
        final status = event['status'] as String? ?? event['type'] as String? ?? 'update';
        final at = DateTime.tryParse(event['occurred_at'] as String? ?? '')?.toLocal();
        history.add(
          ShippingEvent(
            title: _statusTitle(status),
            description: (event['note'] as String?)?.trim().isNotEmpty == true
                ? event['note'] as String
                : 'DCX updated your order status.',
            timestamp: at == null ? 'Recently' : _formatTimestamp(at),
          ),
        );
      }
    }
    if (history.isEmpty && local != null) {
      history.addAll(local.shippingHistory);
    }

    final status = _statusFromServer(json['status'] as String?);
    final payment = _paymentFromServer(
      json['payment_status'] as String?,
      json['payment_method'] as String?,
    );
    final customerNote = (json['customer_note'] as String?)?.trim();
    final tracking = (json['tracking_number'] as String?)?.trim();

    return ShopOrder(
      id: number,
      placedAt: placedAt,
      status: status,
      items: items,
      deliveryFee: (json['delivery_fee'] as num?)?.toDouble() ?? local?.deliveryFee ?? 0,
      discount: (json['discount'] as num?)?.toDouble() ?? local?.discount ?? 0,
      deliveryLabel: customerNote?.isNotEmpty == true
          ? customerNote!
          : _deliveryLabel(status),
      deliveryWindow: customerNote?.isNotEmpty == true
          ? customerNote!
          : _deliveryWindow(status),
      carrier: local?.carrier ?? 'DCX Express',
      trackingNumber: tracking?.isNotEmpty == true
          ? tracking!
          : local?.trackingNumber ?? 'Pending assignment',
      deliveryAddress: json['delivery_address'] as String? ?? local?.deliveryAddress ?? '',
      paymentMethod: json['payment_method'] as String? ?? local?.paymentMethod ?? 'Payment pending',
      paymentStatus: payment,
      paymentReference: json['payment_reference'] as String? ?? local?.paymentReference,
      promotionCode: json['promo_code'] as String? ?? local?.promotionCode,
      shippingHistory: history,
    );
  }

  Product? _productById(int? id) {
    if (id == null) {
      return null;
    }
    final live = StorefrontController.instance.productById(id);
    if (live != null) return live;
    for (final product in DemoCatalog.products) {
      if (product.id == id) {
        return product;
      }
    }
    return null;
  }

  ShopOrderStatus _statusFromServer(String? value) {
    switch (value) {
      case 'packed':
        return ShopOrderStatus.packed;
      case 'shipped':
        return ShopOrderStatus.shipped;
      case 'out_for_delivery':
        return ShopOrderStatus.outForDelivery;
      case 'delivered':
        return ShopOrderStatus.delivered;
      case 'cancelled':
      case 'refunded':
        return ShopOrderStatus.cancelled;
      default:
        return ShopOrderStatus.processing;
    }
  }

  CheckoutPaymentStatus _paymentFromServer(String? value, String? method) {
    switch (value) {
      case 'paid':
      case 'authorized':
        return CheckoutPaymentStatus.paid;
      case 'failed':
        return CheckoutPaymentStatus.failed;
      default:
        return (method ?? '').toLowerCase().contains('bank')
            ? CheckoutPaymentStatus.awaitingTransfer
            : CheckoutPaymentStatus.payOnDelivery;
    }
  }

  String _deliveryLabel(ShopOrderStatus status) {
    switch (status) {
      case ShopOrderStatus.processing:
        return 'Order is being prepared';
      case ShopOrderStatus.packed:
        return 'Order packed';
      case ShopOrderStatus.shipped:
        return 'Order shipped';
      case ShopOrderStatus.outForDelivery:
        return 'Out for delivery';
      case ShopOrderStatus.delivered:
        return 'Delivered';
      case ShopOrderStatus.cancelled:
        return 'Order cancelled';
    }
  }

  String _deliveryWindow(ShopOrderStatus status) =>
      status == ShopOrderStatus.delivered
          ? 'Delivery completed successfully'
          : status == ShopOrderStatus.cancelled
              ? 'This order is no longer active'
              : 'Latest status synchronized from DCX Core';

  String _statusTitle(String value) => value
      .replaceAll('_', ' ')
      .split(' ')
      .where((part) => part.isNotEmpty)
      .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
      .join(' ');

  String _formatTimestamp(DateTime value) {
    const months = <String>['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    final hour = value.hour == 0 ? 12 : (value.hour > 12 ? value.hour - 12 : value.hour);
    final minute = value.minute.toString().padLeft(2, '0');
    final period = value.hour >= 12 ? 'PM' : 'AM';
    return '${months[value.month - 1]} ${value.day}, $hour:$minute $period';
  }

  Map<String, dynamic>? _map(Object? value) {
    if (value is! Map) {
      return null;
    }
    return Map<String, dynamic>.from(value);
  }
}
