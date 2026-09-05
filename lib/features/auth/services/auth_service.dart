import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/firebase/firebase_bootstrap.dart';
import '../../../core/firebase/firebase_session_bridge.dart';
import '../../../core/firebase/push_notification_service.dart';
import '../../../core/network/api_environment.dart';
import '../../../core/network/api_models.dart';
import '../../../core/network/commerce_api_gateway.dart';
import '../../../core/network/customer_identity_api.dart';
import '../../../core/network/session_controller.dart';

enum AuthProvider { google, apple }

abstract class AuthService {
  const AuthService();

  Future<void> login({
    required String email,
    required String password,
    required bool rememberMe,
  });

  Future<void> loginWithProvider(AuthProvider provider);

  Future<void> logout();
}

class AuthServiceFactory {
  AuthServiceFactory._();

  static AuthService create() {
    if (ApiEnvironment.isRemoteConfigured) {
      return RemoteAuthService();
    }
    return const MockAuthService();
  }
}

class MockAuthService extends AuthService {
  const MockAuthService();

  @override
  Future<void> login({
    required String email,
    required String password,
    required bool rememberMe,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 900));
    SessionController.instance.activateDemoSession(
      email: email,
      rememberRequested: rememberMe,
    );
  }

  @override
  Future<void> loginWithProvider(AuthProvider provider) async {
    await Future<void>.delayed(const Duration(milliseconds: 850));
    SessionController.instance.activateDemoSession(
      email: '${provider.name}@demo.dcx',
    );
  }

  @override
  Future<void> logout() async {
    SessionController.instance.signOut();
  }
}

class RemoteAuthService extends AuthService {
  final CommerceApiGateway gateway;
  final CustomerIdentityApi identityApi;

  RemoteAuthService({
    CommerceApiGateway? gateway,
    CustomerIdentityApi? identityApi,
  })  : gateway = gateway ?? HttpCommerceApiGateway(),
        identityApi = identityApi ?? CustomerIdentityApi();

  @override
  Future<void> login({
    required String email,
    required String password,
    required bool rememberMe,
  }) async {
    if (FirebaseBootstrap.isConfigured) {
      await FirebaseBootstrap.ensureInitialized();
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = credential.user;
      if (user == null) {
        throw const ApiException(
          kind: ApiFailureKind.invalidResponse,
          message: 'Firebase did not return a customer account.',
        );
      }
      await user.reload();
      final refreshed = FirebaseAuth.instance.currentUser;
      if (refreshed == null) {
        throw const ApiException(
          kind: ApiFailureKind.unauthorized,
          message: 'The secure Firebase session was lost. Please sign in again.',
        );
      }
      if (!refreshed.emailVerified) {
        await refreshed.sendEmailVerification();
        throw const ApiException(
          kind: ApiFailureKind.validation,
          message: 'Verify your email address before signing in. A new verification email was sent.',
        );
      }
      if ((refreshed.phoneNumber ?? '').trim().isEmpty) {
        throw const ApiException(
          kind: ApiFailureKind.validation,
          message: 'This account has not completed mobile SMS verification.',
        );
      }
      final idToken = await refreshed.getIdToken(true);
      if (idToken == null || idToken.isEmpty) {
        throw const ApiException(
          kind: ApiFailureKind.invalidResponse,
          message: 'Firebase did not return a usable identity token.',
        );
      }
      final result = await identityApi.exchangeFirebaseToken(
        idToken: idToken,
        name: refreshed.displayName,
      );
      if (result['registration_email_otp_required'] == true) {
        throw const ApiException(
          kind: ApiFailureKind.validation,
          message: 'This account still requires the final six-digit DCX email verification code. Complete registration first.',
        );
      }
      FirebaseSessionBridge.activateFromApi(
        result,
        rememberRequested: rememberMe,
      );
      return;
    }

    // Backward-compatible login for the seeded development customer or
    // installations that have not enabled Firebase yet.
    final result = await gateway.signIn(email: email, password: password);
    final token = result['access_token'] as String? ?? result['token'] as String?;
    if (token == null || token.trim().isEmpty) {
      throw const ApiException(
        kind: ApiFailureKind.invalidResponse,
        message: 'The server did not return a usable access token.',
      );
    }
    final customer = result['customer'];
    final customerMap = customer is Map
        ? Map<String, dynamic>.from(customer)
        : <String, dynamic>{};
    final customerIdValue = customerMap['id'];
    final customerId = customerIdValue == null ? null : '$customerIdValue';
    SessionController.instance.activateRemoteSession(
      accessToken: token,
      email: customerMap['email'] as String? ?? email,
      customerId: customerId?.trim().isEmpty == true ? null : customerId,
      name: customerMap['name'] as String?,
      phone: customerMap['phone'] as String?,
      expiresAt: DateTime.tryParse('${result['expires_at'] ?? ''}'),
      rememberRequested: rememberMe,
    );
  }

  @override
  Future<void> loginWithProvider(AuthProvider provider) async {
    throw const ApiException(
      kind: ApiFailureKind.configuration,
      message: 'Social sign in requires a configured identity provider.',
    );
  }

  @override
  Future<void> logout() async {
    try {
      await PushNotificationService.instance.unregisterCurrentDevice();
      if (SessionController.instance.hasUsableRemoteToken) {
        await gateway.signOut();
      }
    } finally {
      if (FirebaseBootstrap.isConfigured) {
        try {
          await FirebaseAuth.instance.signOut();
        } catch (_) {}
      }
      SessionController.instance.signOut();
    }
  }
}
