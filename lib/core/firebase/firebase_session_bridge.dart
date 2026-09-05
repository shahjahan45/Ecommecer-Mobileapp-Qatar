import '../network/session_controller.dart';

class FirebaseSessionBridge {
  FirebaseSessionBridge._();

  static void activateFromApi(
    Map<String, dynamic> result, {
    bool rememberRequested = true,
  }) {
    final token = result['access_token'] as String? ?? result['token'] as String?;
    if (token == null || token.trim().isEmpty) {
      throw StateError('DCX Core did not return an access token.');
    }
    final customer = result['customer'];
    final map = customer is Map
        ? Map<String, dynamic>.from(customer)
        : <String, dynamic>{};
    final customerIdValue = map['id'];
    final customerId = customerIdValue == null ? null : '$customerIdValue';
    SessionController.instance.activateRemoteSession(
      accessToken: token,
      email: (map['email'] as String? ?? '').trim(),
      customerId: customerId?.trim().isEmpty == true ? null : customerId,
      name: map['name'] as String?,
      phone: map['phone'] as String?,
      expiresAt: DateTime.tryParse('${result['expires_at'] ?? ''}'),
      rememberRequested: rememberRequested,
    );
  }
}
