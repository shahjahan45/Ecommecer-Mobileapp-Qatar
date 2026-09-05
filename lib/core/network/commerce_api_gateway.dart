import 'api_client.dart';
import 'api_models.dart';

abstract class CommerceApiGateway {
  Future<void> healthCheck();

  Future<Map<String, dynamic>> signIn({
    required String email,
    required String password,
  });

  Future<void> signOut();

  Future<Map<String, dynamic>> fetchCustomerProfile();

  Future<Map<String, dynamic>> updateCustomerProfile({
    required String name,
    required String email,
    String? phone,
  });

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });

  Future<Map<String, dynamic>> syncCustomerState({
    required Map<String, dynamic> payload,
    required String idempotencyKey,
  });

  Future<Map<String, dynamic>> fetchOrders();

  Future<Map<String, dynamic>> fetchSupportTickets();

  Future<Map<String, dynamic>> createSupportTicket({
    required String category,
    required String subject,
    required String message,
    String? orderNumber,
  });

  Future<Map<String, dynamic>> replySupportTicket({
    required int ticketId,
    required String message,
  });
}

class HttpCommerceApiGateway implements CommerceApiGateway {
  final ApiClient client;

  HttpCommerceApiGateway({ApiClient? client}) : client = client ?? ApiClient();

  @override
  Future<void> healthCheck() async {
    await client.get('/api/v1/health');
  }

  @override
  Future<Map<String, dynamic>> signIn({
    required String email,
    required String password,
  }) async {
    final response = await client.post(
      '/api/v1/auth/login',
      authenticated: false,
      body: <String, dynamic>{
        'email': email,
        'password': password,
        'device': 'flutter-mobile',
      },
    );
    return response.jsonObject;
  }

  @override
  Future<void> signOut() async {
    await client.post('/api/v1/auth/logout');
  }

  @override
  Future<Map<String, dynamic>> fetchCustomerProfile() async {
    final response = await client.get('/api/v1/auth/me');
    return response.jsonObject;
  }

  @override
  Future<Map<String, dynamic>> updateCustomerProfile({
    required String name,
    required String email,
    String? phone,
  }) async {
    final response = await client.patch(
      '/api/v1/auth/profile',
      body: <String, dynamic>{
        'name': name,
        'email': email,
        'phone': phone,
      },
    );
    return response.jsonObject;
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await client.post(
      '/api/v1/auth/change-password',
      body: <String, dynamic>{
        'current_password': currentPassword,
        'password': newPassword,
        'password_confirmation': newPassword,
      },
    );
  }

  @override
  Future<Map<String, dynamic>> syncCustomerState({
    required Map<String, dynamic> payload,
    required String idempotencyKey,
  }) async {
    final response = await client.post(
      '/api/v1/mobile/session/sync',
      idempotencyKey: idempotencyKey,
      body: payload,
    );
    if (response.body.trim().isEmpty) {
      return <String, dynamic>{};
    }
    try {
      return response.jsonObject;
    } on ApiException {
      return <String, dynamic>{};
    }
  }

  @override
  Future<Map<String, dynamic>> fetchOrders() async {
    final response = await client.get('/api/v1/orders');
    return response.jsonObject;
  }

  @override
  Future<Map<String, dynamic>> fetchSupportTickets() async {
    final response = await client.get('/api/v1/support');
    return response.jsonObject;
  }

  @override
  Future<Map<String, dynamic>> createSupportTicket({
    required String category,
    required String subject,
    required String message,
    String? orderNumber,
  }) async {
    final response = await client.post(
      '/api/v1/support',
      body: <String, dynamic>{
        'category': category,
        'subject': subject,
        'message': message,
        'order_number': orderNumber,
      },
    );
    return response.jsonObject;
  }

  @override
  Future<Map<String, dynamic>> replySupportTicket({
    required int ticketId,
    required String message,
  }) async {
    final response = await client.post(
      '/api/v1/support/$ticketId/reply',
      body: <String, dynamic>{'message': message},
    );
    return response.jsonObject;
  }
}
