import 'package:flutter/foundation.dart';

import '../network/api_environment.dart';
import '../network/api_models.dart';
import '../network/commerce_api_gateway.dart';
import '../network/session_controller.dart';
import '../persistence/customer_session_persistence.dart';
import '../../features/profile/address/address_book_controller.dart';

enum CloudSyncState {
  idle,
  checking,
  localOnly,
  ready,
  syncing,
  success,
  error,
}

class CloudSyncController extends ChangeNotifier {
  CloudSyncController._({
    CommerceApiGateway? gateway,
    CustomerSessionPersistence? persistence,
    AddressBookController? addressBook,
    SessionController? sessionController,
    bool? remoteConfiguredOverride,
  })  : _gateway = gateway ?? HttpCommerceApiGateway(),
        _persistence = persistence ?? CustomerSessionPersistence.instance,
        _addressBook = addressBook ?? AddressBookController.instance,
        _sessionController = sessionController ?? SessionController.instance,
        _remoteConfiguredOverride = remoteConfiguredOverride;

  static final CloudSyncController instance = CloudSyncController._();

  @visibleForTesting
  factory CloudSyncController.forTesting({
    required CommerceApiGateway gateway,
    required CustomerSessionPersistence persistence,
    required AddressBookController addressBook,
    required SessionController sessionController,
    required bool remoteConfigured,
  }) {
    return CloudSyncController._(
      gateway: gateway,
      persistence: persistence,
      addressBook: addressBook,
      sessionController: sessionController,
      remoteConfiguredOverride: remoteConfigured,
    );
  }

  final CommerceApiGateway _gateway;
  final CustomerSessionPersistence _persistence;
  final AddressBookController _addressBook;
  final SessionController _sessionController;
  final bool? _remoteConfiguredOverride;

  CloudSyncState _state = CloudSyncState.idle;
  DateTime? _lastRemoteSyncAt;
  String? _message;
  String? _lastError;

  CloudSyncState get state => _state;
  DateTime? get lastRemoteSyncAt => _lastRemoteSyncAt;
  String? get message => _message;
  String? get lastError => _lastError;
  bool get isBusy => state == CloudSyncState.checking || state == CloudSyncState.syncing;
  bool get remoteConfigured => _remoteConfiguredOverride ?? ApiEnvironment.isRemoteConfigured;
  bool get isLocalOnly => !remoteConfigured;
  bool get hasPendingLocalChanges {
    final localSaved = _persistence.lastSavedAt;
    if (localSaved == null) return true;
    if (_lastRemoteSyncAt == null) return true;
    return localSaved.isAfter(_lastRemoteSyncAt!);
  }

  Future<void> checkConnection() async {
    if (isBusy) return;
    if (!remoteConfigured) {
      _state = CloudSyncState.localOnly;
      _message = 'Local continuity is active. Configure the remote API to enable cross-device sync.';
      _lastError = null;
      notifyListeners();
      return;
    }

    _state = CloudSyncState.checking;
    _message = 'Checking API connection…';
    _lastError = null;
    notifyListeners();

    try {
      await _gateway.healthCheck();
      _state = CloudSyncState.ready;
      _message = 'Remote API is reachable and ready for authenticated sync.';
    } on ApiException catch (error) {
      _state = CloudSyncState.error;
      _lastError = error.message;
      _message = null;
    } catch (_) {
      _state = CloudSyncState.error;
      _lastError = 'The API connection could not be verified.';
      _message = null;
    }
    notifyListeners();
  }

  Future<void> syncNow() async {
    if (isBusy) return;

    await _persistence.save();
    await _addressBook.load();

    if (!remoteConfigured) {
      _state = CloudSyncState.localOnly;
      _message = 'Saved on this device. Remote sync is disabled in this build.';
      _lastError = null;
      notifyListeners();
      return;
    }

    if (!_sessionController.isAuthenticated ||
        _sessionController.bearerToken == null) {
      _state = CloudSyncState.error;
      _lastError = 'Sign in to a remote customer account before syncing.';
      _message = null;
      notifyListeners();
      return;
    }

    _state = CloudSyncState.syncing;
    _message = 'Syncing your latest shopping activity…';
    _lastError = null;
    notifyListeners();

    final generatedAt = DateTime.now();
    final payload = <String, dynamic>{
      'schema': 'dcx-mobile-sync-v1',
      'generatedAt': generatedAt.toUtc().toIso8601String(),
      'customer': <String, dynamic>{
        'id': _sessionController.session.customerId,
        'email': _sessionController.session.email,
      },
      'session': _persistence.exportForSync(generatedAt: generatedAt),
      'addresses': _addressBook.exportForSync(),
      'client': const <String, dynamic>{
        'platform': 'flutter-mobile',
        'appVersion': '1.19.4',
      },
    };

    final idempotencyKey =
        'mobile-sync-${_sessionController.session.customerId ?? 'customer'}-${generatedAt.microsecondsSinceEpoch}';

    try {
      await _gateway.syncCustomerState(
        payload: payload,
        idempotencyKey: idempotencyKey,
      );
      _lastRemoteSyncAt = DateTime.now();
      _state = CloudSyncState.success;
      _message = 'Your customer data is up to date.';
      _lastError = null;
    } on ApiException catch (error) {
      _state = CloudSyncState.error;
      _lastError = error.message;
      _message = null;
    } catch (_) {
      _state = CloudSyncState.error;
      _lastError = 'Sync could not be completed. Your local data is still safe.';
      _message = null;
    }
    notifyListeners();
  }

  @visibleForTesting
  void resetForTesting() {
    _state = CloudSyncState.idle;
    _lastRemoteSyncAt = null;
    _message = null;
    _lastError = null;
    notifyListeners();
  }
}
