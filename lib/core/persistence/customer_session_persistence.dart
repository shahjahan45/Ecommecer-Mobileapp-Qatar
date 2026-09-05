import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/demo_catalog.dart';
import '../storefront/storefront_controller.dart';
import '../../data/demo_orders.dart';
import '../../features/cart/cart_controller.dart';
import '../../features/notifications/notification_controller.dart';
import '../../features/support/support_controller.dart';
import '../../features/wishlist/wishlist_controller.dart';
import '../../models/app_notification.dart';
import '../../models/cart_item.dart';
import '../../models/payment.dart';
import '../../models/product.dart';
import '../../models/shop_order.dart';
import '../../models/support_ticket.dart';

abstract class CustomerSessionStorage {
  const CustomerSessionStorage();

  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<void> remove(String key);
}

class SharedPreferencesCustomerSessionStorage extends CustomerSessionStorage {
  SharedPreferencesAsync? _preferences;

  SharedPreferencesAsync get _store => _preferences ??= SharedPreferencesAsync();

  @override
  Future<String?> read(String key) => _store.getString(key);

  @override
  Future<void> write(String key, String value) => _store.setString(key, value);

  @override
  Future<void> remove(String key) => _store.remove(key);
}

@visibleForTesting
class MemoryCustomerSessionStorage extends CustomerSessionStorage {
  final Map<String, String> values = <String, String>{};

  @override
  Future<String?> read(String key) async => values[key];

  @override
  Future<void> write(String key, String value) async {
    values[key] = value;
  }

  @override
  Future<void> remove(String key) async {
    values.remove(key);
  }
}

class CustomerSessionPersistence extends ChangeNotifier {
  CustomerSessionPersistence._({CustomerSessionStorage? storage})
      : _storage = storage ?? SharedPreferencesCustomerSessionStorage();

  static final CustomerSessionPersistence instance =
      CustomerSessionPersistence._();

  @visibleForTesting
  factory CustomerSessionPersistence.forTesting(CustomerSessionStorage storage) {
    return CustomerSessionPersistence._(storage: storage);
  }

  static const String storageKey = 'dcx.customer_session.v1';
  static const int schemaVersion = 1;

  final CustomerSessionStorage _storage;
  bool _loaded = false;
  bool _saving = false;
  DateTime? _lastSavedAt;
  String? _lastError;
  Future<void>? _loadFuture;

  bool get isLoaded => _loaded;
  bool get isSaving => _saving;
  DateTime? get lastSavedAt => _lastSavedAt;
  String? get lastError => _lastError;
  bool get isHealthy => _loaded && _lastError == null;

  Future<void> load() {
    if (_loaded) {
      return Future<void>.value();
    }
    return _loadFuture ??= _loadInternal();
  }

  Future<void> _loadInternal() async {
    try {
      final raw = await _storage.read(storageKey);
      if (raw != null && raw.trim().isNotEmpty) {
        final decoded = jsonDecode(raw);
        if (decoded is Map) {
          _applySnapshot(Map<String, dynamic>.from(decoded));
        }
      }
      _lastError = null;
    } catch (_) {
      // Persistence must never block the shopping experience. Unsupported
      // hosts and widget tests can continue using the in-memory controllers.
      _lastError = 'Local session storage is currently unavailable.';
    } finally {
      _loaded = true;
      _loadFuture = null;
      notifyListeners();
    }
  }

  Future<void> save() async {
    if (_saving) {
      return;
    }
    if (!_loaded) {
      await load();
    }
    _saving = true;
    notifyListeners();
    try {
      final savedAt = DateTime.now();
      final payload = _createSnapshot(savedAt: savedAt);
      await _storage.write(storageKey, jsonEncode(payload));
      _lastSavedAt = savedAt;
      _lastError = null;
    } catch (_) {
      _lastError = 'Could not save local shopping continuity.';
    } finally {
      _saving = false;
      notifyListeners();
    }
  }

  Future<void> clearStoredSnapshot() async {
    try {
      await _storage.remove(storageKey);
      _lastSavedAt = null;
      _lastError = null;
    } catch (_) {
      _lastError = 'Could not clear the local session snapshot.';
    }
    notifyListeners();
  }

  Map<String, dynamic> exportForSync({DateTime? generatedAt}) =>
      _createSnapshot(savedAt: generatedAt ?? DateTime.now());

  @visibleForTesting
  Map<String, dynamic> createSnapshotForTesting({DateTime? savedAt}) =>
      exportForSync(generatedAt: savedAt ?? DateTime(2026, 9, 2, 12));

  @visibleForTesting
  void applySnapshotForTesting(Map<String, dynamic> snapshot) {
    _applySnapshot(snapshot);
    _loaded = true;
  }

  Map<String, dynamic> _createSnapshot({required DateTime savedAt}) {
    final cart = CartController.instance;
    final wishlist = WishlistController.instance;
    final notifications = NotificationController.instance;
    final support = SupportController.instance;

    return <String, dynamic>{
      'version': schemaVersion,
      'savedAt': savedAt.toIso8601String(),
      'cart': <String, dynamic>{
        'items': cart.items
            .map(
              (item) => <String, dynamic>{
                'productId': item.product.id,
                'serverProductId': item.product.serverId,
                'quantity': item.quantity,
                'variant': item.variant,
              },
            )
            .toList(growable: false),
        'promotionCode': cart.appliedPromotion?.code,
      },
      'wishlistProductIds': wishlist.products
          .map((product) => product.id)
          .toList(growable: false),
      'notifications': <String, dynamic>{
        'items': notifications.items.map(_notificationToJson).toList(growable: false),
        'preferences': <String, dynamic>{
          for (final type in AppNotificationType.values)
            type.name: notifications.preferenceFor(type),
        },
      },
      'supportTickets': support.tickets.map(_ticketToJson).toList(growable: false),
      'customerOrders': DemoOrders.customerOrders
          .map(_orderToJson)
          .toList(growable: false),
    };
  }

  void _applySnapshot(Map<String, dynamic> snapshot) {
    final version = snapshot['version'] as int? ?? 0;
    if (version <= 0 || version > schemaVersion) {
      return;
    }

    final cartMap = _asStringDynamicMap(snapshot['cart']);
    if (cartMap != null) {
      final restoredItems = <CartItem>[];
      final rawItems = cartMap['items'];
      if (rawItems is List) {
        for (final rawItem in rawItems) {
          final item = _asStringDynamicMap(rawItem);
          if (item == null) {
            continue;
          }
          final productId = (item['productId'] as num?)?.toInt();
          final quantity = (item['quantity'] as num?)?.toInt() ?? 1;
          if (productId == null) {
            continue;
          }
          final product = _productById(productId);
          if (product == null || !product.inStock) {
            continue;
          }
          final variant = item['variant'] as String?;
          restoredItems.add(
            CartItem(
              key: CartController.instance.keyFor(product, variant: variant),
              product: product,
              quantity: quantity,
              variant: variant,
            ),
          );
        }
      }
      CartController.instance.restoreAll(restoredItems);
      final promotionCode = cartMap['promotionCode'] as String?;
      if (promotionCode != null && promotionCode.trim().isNotEmpty) {
        CartController.instance.applyPromotion(promotionCode);
      }
    }

    final rawWishlist = snapshot['wishlistProductIds'];
    if (rawWishlist is List) {
      final validIds = rawWishlist
          .whereType<num>()
          .map((value) => value.toInt())
          .where((id) => _productById(id) != null)
          .toSet();
      WishlistController.instance.restore(validIds);
    }

    final notificationMap = _asStringDynamicMap(snapshot['notifications']);
    if (notificationMap != null) {
      final items = <AppNotification>[];
      final rawItems = notificationMap['items'];
      if (rawItems is List) {
        for (final raw in rawItems) {
          final map = _asStringDynamicMap(raw);
          if (map == null) {
            continue;
          }
          final parsed = _notificationFromJson(map);
          if (parsed != null) {
            items.add(parsed);
          }
        }
      }

      final preferences = <AppNotificationType, bool>{};
      final rawPreferences = _asStringDynamicMap(notificationMap['preferences']);
      if (rawPreferences != null) {
        for (final type in AppNotificationType.values) {
          final value = rawPreferences[type.name];
          if (value is bool) {
            preferences[type] = value;
          }
        }
      }
      NotificationController.instance.restoreForSession(
        items: items,
        preferences: preferences,
      );
    }

    final rawTickets = snapshot['supportTickets'];
    if (rawTickets is List) {
      final tickets = <SupportTicket>[];
      for (final raw in rawTickets) {
        final map = _asStringDynamicMap(raw);
        if (map == null) {
          continue;
        }
        final parsed = _ticketFromJson(map);
        if (parsed != null) {
          tickets.add(parsed);
        }
      }
      SupportController.instance.restoreForSession(tickets);
    }

    final rawOrders = snapshot['customerOrders'];
    if (rawOrders is List) {
      final orders = <ShopOrder>[];
      for (final raw in rawOrders) {
        final map = _asStringDynamicMap(raw);
        if (map == null) {
          continue;
        }
        final parsed = _orderFromJson(map);
        if (parsed != null) {
          orders.add(parsed);
        }
      }
      DemoOrders.restoreCustomerOrders(orders);
    }

    _lastSavedAt = DateTime.tryParse(snapshot['savedAt'] as String? ?? '');
  }

  Product? _productById(int id) {
    final live = StorefrontController.instance.productById(id);
    if (live != null) return live;
    for (final product in DemoCatalog.products) {
      if (product.id == id) {
        return product;
      }
    }
    return null;
  }

  Map<String, dynamic>? _asStringDynamicMap(Object? value) {
    if (value is! Map) {
      return null;
    }
    return Map<String, dynamic>.from(value);
  }

  Map<String, dynamic> _notificationToJson(AppNotification item) =>
      <String, dynamic>{
        'id': item.id,
        'type': item.type.name,
        'title': item.title,
        'message': item.message,
        'createdAt': item.createdAt.toIso8601String(),
        'isRead': item.isRead,
        'orderId': item.orderId,
      };

  AppNotification? _notificationFromJson(Map<String, dynamic> json) {
    final id = json['id'] as String?;
    final title = json['title'] as String?;
    final message = json['message'] as String?;
    final createdAt = DateTime.tryParse(json['createdAt'] as String? ?? '');
    if (id == null || title == null || message == null || createdAt == null) {
      return null;
    }
    final typeName = json['type'] as String?;
    final type = AppNotificationType.values.firstWhere(
      (item) => item.name == typeName,
      orElse: () => AppNotificationType.account,
    );
    return AppNotification(
      id: id,
      type: type,
      title: title,
      message: message,
      createdAt: createdAt,
      isRead: json['isRead'] as bool? ?? false,
      orderId: json['orderId'] as String?,
    );
  }

  Map<String, dynamic> _ticketToJson(SupportTicket item) => <String, dynamic>{
        'id': item.id,
        'serverId': item.serverId,
        'category': item.category,
        'subject': item.subject,
        'message': item.message,
        'createdAt': item.createdAt.toIso8601String(),
        'lastReplyAt': item.lastReplyAt?.toIso8601String(),
        'status': item.status.name,
        'priority': item.priority,
        'orderId': item.orderId,
        'messages': item.messages
            .map(
              (message) => <String, dynamic>{
                'serverId': message.serverId,
                'senderType': message.senderType,
                'message': message.message,
                'sentAt': message.sentAt.toIso8601String(),
              },
            )
            .toList(growable: false),
      };

  SupportTicket? _ticketFromJson(Map<String, dynamic> json) {
    final id = json['id'] as String?;
    final category = json['category'] as String?;
    final subject = json['subject'] as String?;
    final message = json['message'] as String?;
    final createdAt = DateTime.tryParse(json['createdAt'] as String? ?? '');
    if (id == null ||
        category == null ||
        subject == null ||
        message == null ||
        createdAt == null) {
      return null;
    }
    final statusName = json['status'] as String?;
    final status = SupportTicketStatus.values.firstWhere(
      (item) => item.name == statusName,
      orElse: () => SupportTicketStatus.open,
    );
    final messages = <SupportTicketMessage>[];
    final rawMessages = json['messages'];
    if (rawMessages is List) {
      for (final raw in rawMessages) {
        final map = _asStringDynamicMap(raw);
        if (map == null) {
          continue;
        }
        final body = map['message'] as String?;
        final sentAt = DateTime.tryParse(map['sentAt'] as String? ?? '');
        if (body == null || sentAt == null) {
          continue;
        }
        messages.add(
          SupportTicketMessage(
            serverId: (map['serverId'] as num?)?.toInt(),
            senderType: map['senderType'] as String? ?? 'customer',
            message: body,
            sentAt: sentAt,
          ),
        );
      }
    }
    return SupportTicket(
      id: id,
      serverId: (json['serverId'] as num?)?.toInt(),
      category: category,
      subject: subject,
      message: message,
      createdAt: createdAt,
      lastReplyAt: DateTime.tryParse(json['lastReplyAt'] as String? ?? ''),
      status: status,
      priority: json['priority'] as String? ?? 'normal',
      orderId: json['orderId'] as String?,
      messages: messages,
    );
  }

  Map<String, dynamic> _orderToJson(ShopOrder order) => <String, dynamic>{
        'id': order.id,
        'placedAt': order.placedAt.toIso8601String(),
        'status': order.status.name,
        'items': order.items
            .map(
              (item) => <String, dynamic>{
                'productId': item.product.id,
                'serverProductId': item.product.serverId,
                'productName': item.product.name,
                'quantity': item.quantity,
                'variant': item.variant,
                'unitPrice': item.unitPrice,
                'lineTotal': item.lineTotal,
              },
            )
            .toList(growable: false),
        'subtotal': order.subtotal,
        'deliveryFee': order.deliveryFee,
        'discount': order.discount,
        'total': order.total,
        'currency': 'QAR',
        'deliveryLabel': order.deliveryLabel,
        'deliveryWindow': order.deliveryWindow,
        'carrier': order.carrier,
        'trackingNumber': order.trackingNumber,
        'deliveryAddress': order.deliveryAddress,
        'paymentMethod': order.paymentMethod,
        'paymentStatus': order.paymentStatus.name,
        'paymentReference': order.paymentReference,
        'promotionCode': order.promotionCode,
        'shippingHistory': order.shippingHistory
            .map(
              (event) => <String, dynamic>{
                'title': event.title,
                'description': event.description,
                'timestamp': event.timestamp,
                'completed': event.completed,
              },
            )
            .toList(growable: false),
      };

  ShopOrder? _orderFromJson(Map<String, dynamic> json) {
    final id = json['id'] as String?;
    final placedAt = DateTime.tryParse(json['placedAt'] as String? ?? '');
    if (id == null || placedAt == null) {
      return null;
    }

    final items = <ShopOrderItem>[];
    final rawItems = json['items'];
    if (rawItems is List) {
      for (final raw in rawItems) {
        final item = _asStringDynamicMap(raw);
        if (item == null) {
          continue;
        }
        final productId = (item['productId'] as num?)?.toInt();
        final quantity = (item['quantity'] as num?)?.toInt() ?? 1;
        if (productId == null) {
          continue;
        }
        final product = _productById(productId);
        if (product == null) {
          continue;
        }
        items.add(
          ShopOrderItem(
            product: product,
            quantity: quantity,
            variant: item['variant'] as String?,
            unitPrice: (item['unitPrice'] as num?)?.toDouble(),
          ),
        );
      }
    }
    if (items.isEmpty) {
      return null;
    }

    final statusName = json['status'] as String?;
    final status = ShopOrderStatus.values.firstWhere(
      (item) => item.name == statusName,
      orElse: () => ShopOrderStatus.processing,
    );
    final paymentStatusName = json['paymentStatus'] as String?;
    final paymentStatus = CheckoutPaymentStatus.values.firstWhere(
      (item) => item.name == paymentStatusName,
      orElse: () => CheckoutPaymentStatus.payOnDelivery,
    );

    final history = <ShippingEvent>[];
    final rawHistory = json['shippingHistory'];
    if (rawHistory is List) {
      for (final raw in rawHistory) {
        final event = _asStringDynamicMap(raw);
        if (event == null) {
          continue;
        }
        final title = event['title'] as String?;
        final description = event['description'] as String?;
        final timestamp = event['timestamp'] as String?;
        if (title == null || description == null || timestamp == null) {
          continue;
        }
        history.add(
          ShippingEvent(
            title: title,
            description: description,
            timestamp: timestamp,
            completed: event['completed'] as bool? ?? true,
          ),
        );
      }
    }

    return ShopOrder(
      id: id,
      placedAt: placedAt,
      status: status,
      items: items,
      deliveryFee: (json['deliveryFee'] as num?)?.toDouble() ?? 0,
      discount: (json['discount'] as num?)?.toDouble() ?? 0,
      deliveryLabel: json['deliveryLabel'] as String? ?? 'Order confirmed',
      deliveryWindow: json['deliveryWindow'] as String? ?? 'Delivery scheduled',
      carrier: json['carrier'] as String? ?? 'DCX Express',
      trackingNumber: json['trackingNumber'] as String? ?? 'Pending assignment',
      deliveryAddress: json['deliveryAddress'] as String? ?? '',
      paymentMethod: json['paymentMethod'] as String? ?? 'Cash on delivery',
      paymentStatus: paymentStatus,
      paymentReference: json['paymentReference'] as String?,
      promotionCode: json['promotionCode'] as String?,
      shippingHistory: history,
    );
  }
}
