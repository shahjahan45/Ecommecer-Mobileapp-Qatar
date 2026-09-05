import 'package:flutter/foundation.dart';

enum CustomerSessionStatus { guest, authenticated, expired }

class CustomerAuthSession {
  final CustomerSessionStatus status;
  final String? customerId;
  final String? name;
  final String? email;
  final String? phone;
  final String? accessToken;
  final DateTime? expiresAt;
  final bool demo;
  final bool rememberRequested;

  const CustomerAuthSession({
    required this.status,
    this.customerId,
    this.name,
    this.email,
    this.phone,
    this.accessToken,
    this.expiresAt,
    this.demo = false,
    this.rememberRequested = false,
  });

  const CustomerAuthSession.guest()
      : this(status: CustomerSessionStatus.guest);

  bool get isAuthenticated => status == CustomerSessionStatus.authenticated;
  bool get hasUsableToken =>
      isAuthenticated && accessToken != null && accessToken!.trim().isNotEmpty;
}

class SessionController extends ChangeNotifier {
  SessionController._();

  static final SessionController instance = SessionController._();

  CustomerAuthSession _session = const CustomerAuthSession.guest();

  CustomerAuthSession get session => _session;
  bool get isAuthenticated => _session.isAuthenticated;
  bool get isDemoSession => _session.demo;
  bool get hasUsableRemoteToken => !_session.demo && bearerToken != null;
  String? get customerId => _session.customerId;
  String? get name => _session.name;
  String? get email => _session.email;
  String? get phone => _session.phone;

  String? get bearerToken {
    final expiresAt = _session.expiresAt;
    if (expiresAt != null && DateTime.now().isAfter(expiresAt)) {
      return null;
    }
    return _session.accessToken;
  }

  void activateDemoSession({
    required String email,
    String? name,
    String? phone,
    bool rememberRequested = false,
  }) {
    _session = CustomerAuthSession(
      status: CustomerSessionStatus.authenticated,
      customerId: 'demo-customer',
      name: name ?? 'Demo Customer',
      email: email,
      phone: phone,
      demo: true,
      rememberRequested: rememberRequested,
    );
    notifyListeners();
  }

  void activateRemoteSession({
    required String accessToken,
    required String email,
    String? customerId,
    String? name,
    String? phone,
    DateTime? expiresAt,
    bool rememberRequested = false,
  }) {
    _session = CustomerAuthSession(
      status: CustomerSessionStatus.authenticated,
      customerId: customerId,
      name: name,
      email: email,
      phone: phone,
      accessToken: accessToken,
      expiresAt: expiresAt,
      demo: false,
      rememberRequested: rememberRequested,
    );
    notifyListeners();
  }

  void updateIdentity({
    required String name,
    required String email,
    String? phone,
    String? customerId,
  }) {
    if (!_session.isAuthenticated) return;
    _session = CustomerAuthSession(
      status: _session.status,
      customerId: customerId ?? _session.customerId,
      name: name,
      email: email,
      phone: phone,
      accessToken: _session.accessToken,
      expiresAt: _session.expiresAt,
      demo: _session.demo,
      rememberRequested: _session.rememberRequested,
    );
    notifyListeners();
  }

  void expire() {
    _session = CustomerAuthSession(
      status: CustomerSessionStatus.expired,
      customerId: _session.customerId,
      name: _session.name,
      email: _session.email,
      phone: _session.phone,
      demo: _session.demo,
    );
    notifyListeners();
  }

  void signOut() {
    _session = const CustomerAuthSession.guest();
    notifyListeners();
  }

  @visibleForTesting
  void resetForTesting() {
    _session = const CustomerAuthSession.guest();
    notifyListeners();
  }
}
