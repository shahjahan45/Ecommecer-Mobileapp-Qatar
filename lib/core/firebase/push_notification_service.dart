import 'dart:async';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';

import '../../features/notifications/notification_controller.dart';
import '../network/customer_identity_api.dart';
import '../network/session_controller.dart';
import 'firebase_bootstrap.dart';

@pragma('vm:entry-point')
Future<void> dcxFirebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await FirebaseBootstrap.ensureInitialized();
}

class PushNotificationService {
  PushNotificationService._();

  static final PushNotificationService instance = PushNotificationService._();

  final CustomerIdentityApi _identityApi = CustomerIdentityApi();
  StreamSubscription<String>? _tokenSubscription;
  StreamSubscription<RemoteMessage>? _messageSubscription;
  StreamSubscription<RemoteMessage>? _openedSubscription;
  bool _initialized = false;
  bool _wasAuthenticated = false;

  Future<void> initialize() async {
    if (_initialized || !FirebaseBootstrap.isConfigured) return;
    final ready = await FirebaseBootstrap.ensureInitialized();
    if (!ready) return;

    FirebaseMessaging.onBackgroundMessage(
      dcxFirebaseMessagingBackgroundHandler,
    );
    final messaging = FirebaseMessaging.instance;
    await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    await messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    _messageSubscription = FirebaseMessaging.onMessage.listen((message) {
      _capture(message);
    });
    _openedSubscription =
        FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _capture(message, isRead: true, idPrefix: 'fcm-open');
    });

    final initialMessage = await messaging.getInitialMessage();
    if (initialMessage != null) {
      _capture(initialMessage, isRead: true, idPrefix: 'fcm-launch');
    }
    _tokenSubscription = messaging.onTokenRefresh.listen((token) {
      if (SessionController.instance.hasUsableRemoteToken) {
        _registerToken(token);
      }
    });
    SessionController.instance.addListener(_onSessionChanged);
    _initialized = true;
    await _onSessionChanged();
  }

  void _capture(
    RemoteMessage message, {
    bool isRead = false,
    String idPrefix = 'fcm',
  }) {
    NotificationController.instance.addRemoteNotification(
      id: message.messageId ??
          '$idPrefix-${DateTime.now().microsecondsSinceEpoch}',
      title: message.notification?.title ?? 'DCX Online Store',
      message: message.notification?.body ?? '',
      type: message.data['type'],
      orderId: message.data['order_number'],
      isRead: isRead,
    );
  }

  Future<void> _onSessionChanged() async {
    final authenticated = SessionController.instance.hasUsableRemoteToken;
    if (authenticated) {
      _wasAuthenticated = true;
      try {
        await FirebaseMessaging.instance.subscribeToTopic('dcx_customers');
        final token = await FirebaseMessaging.instance.getToken();
        if (token != null && token.trim().isNotEmpty) {
          await _registerToken(token);
        }
      } catch (_) {
        // Push setup is best-effort and must never block authentication.
      }
      return;
    }
    if (_wasAuthenticated) {
      _wasAuthenticated = false;
      try {
        await FirebaseMessaging.instance.unsubscribeFromTopic('dcx_customers');
      } catch (_) {}
    }
  }

  Future<void> _registerToken(String token) async {
    try {
      await _identityApi.registerDevice(
        fcmToken: token,
        platform: Platform.isIOS ? 'ios' : 'android',
      );
    } catch (_) {
      // Orders/login remain usable when FCM registration is temporarily down.
    }
  }

  Future<void> unregisterCurrentDevice() async {
    if (!_initialized || !SessionController.instance.hasUsableRemoteToken) {
      return;
    }
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null && token.isNotEmpty) {
        await _identityApi.unregisterDevice(fcmToken: token);
      }
      await FirebaseMessaging.instance.unsubscribeFromTopic('dcx_customers');
    } catch (_) {
      // Local logout still proceeds if the backend/FCM is unavailable.
    }
  }

  Future<void> dispose() async {
    await _tokenSubscription?.cancel();
    await _messageSubscription?.cancel();
    await _openedSubscription?.cancel();
    SessionController.instance.removeListener(_onSessionChanged);
    _initialized = false;
  }
}
