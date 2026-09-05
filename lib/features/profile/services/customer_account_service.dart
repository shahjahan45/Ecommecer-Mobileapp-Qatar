import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/firebase/firebase_bootstrap.dart';
import '../../../core/network/api_environment.dart';
import '../../../core/network/api_models.dart';
import '../../../core/network/commerce_api_gateway.dart';
import '../../../core/network/session_controller.dart';

class CustomerProfile {
  final String? id;
  final String name;
  final String email;
  final String? phone;

  const CustomerProfile({
    this.id,
    required this.name,
    required this.email,
    this.phone,
  });

  factory CustomerProfile.fromMap(Map<String, dynamic> map) {
    final idValue = map['id'];
    return CustomerProfile(
      id: idValue == null ? null : '$idValue',
      name: '${map['name'] ?? ''}'.trim(),
      email: '${map['email'] ?? ''}'.trim(),
      phone: map['phone'] == null || '${map['phone']}'.trim().isEmpty
          ? null
          : '${map['phone']}'.trim(),
    );
  }
}

abstract class CustomerAccountService {
  Future<CustomerProfile> loadProfile();

  Future<CustomerProfile> updateProfile({
    required String name,
    required String email,
    String? phone,
  });

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });
}

class CustomerAccountServiceFactory {
  CustomerAccountServiceFactory._();

  static CustomerAccountService create() {
    if (ApiEnvironment.isRemoteConfigured) {
      return RemoteCustomerAccountService();
    }
    return DemoCustomerAccountService();
  }
}

class DemoCustomerAccountService implements CustomerAccountService {
  final SessionController sessionController;

  DemoCustomerAccountService({SessionController? sessionController})
      : sessionController = sessionController ?? SessionController.instance;

  @override
  Future<CustomerProfile> loadProfile() async {
    final session = sessionController.session;
    if (!session.isAuthenticated) {
      throw const ApiException(
        kind: ApiFailureKind.unauthorized,
        message: 'Please sign in to manage your account.',
      );
    }
    return CustomerProfile(
      id: session.customerId,
      name: session.name ?? 'Demo Customer',
      email: session.email ?? 'customer@dcx.test',
      phone: session.phone,
    );
  }

  @override
  Future<CustomerProfile> updateProfile({
    required String name,
    required String email,
    String? phone,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    sessionController.updateIdentity(
      name: name.trim(),
      email: email.trim().toLowerCase(),
      phone: phone?.trim().isEmpty == true ? null : phone?.trim(),
    );
    return loadProfile();
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 450));
    if (currentPassword.trim().isEmpty) {
      throw const ApiException(
        kind: ApiFailureKind.validation,
        message: 'Enter your current password.',
      );
    }
  }
}

class RemoteCustomerAccountService implements CustomerAccountService {
  final CommerceApiGateway gateway;
  final SessionController sessionController;

  RemoteCustomerAccountService({
    CommerceApiGateway? gateway,
    SessionController? sessionController,
  })  : gateway = gateway ?? HttpCommerceApiGateway(),
        sessionController = sessionController ?? SessionController.instance;

  @override
  Future<CustomerProfile> loadProfile() async {
    final result = await gateway.fetchCustomerProfile();
    return _apply(result);
  }

  @override
  Future<CustomerProfile> updateProfile({
    required String name,
    required String email,
    String? phone,
  }) async {
    final result = await gateway.updateCustomerProfile(
      name: name,
      email: email,
      phone: phone,
    );
    return _apply(result);
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    if (FirebaseBootstrap.isConfigured) {
      await FirebaseBootstrap.ensureInitialized();
      final user = FirebaseAuth.instance.currentUser;
      final email = user?.email;
      if (user != null && email != null && email.trim().isNotEmpty) {
        await user.reauthenticateWithCredential(
          EmailAuthProvider.credential(
            email: email,
            password: currentPassword,
          ),
        );
        await user.updatePassword(newPassword);
        await user.getIdToken(true);
        return;
      }
    }
    await gateway.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }

  CustomerProfile _apply(Map<String, dynamic> result) {
    final raw = result['customer'];
    if (raw is! Map) {
      throw const ApiException(
        kind: ApiFailureKind.invalidResponse,
        message: 'The server returned an invalid customer profile.',
      );
    }
    final profile = CustomerProfile.fromMap(Map<String, dynamic>.from(raw));
    if (profile.name.isEmpty || profile.email.isEmpty) {
      throw const ApiException(
        kind: ApiFailureKind.invalidResponse,
        message: 'The customer profile is incomplete.',
      );
    }
    sessionController.updateIdentity(
      customerId: profile.id,
      name: profile.name,
      email: profile.email,
      phone: profile.phone,
    );
    return profile;
  }
}
