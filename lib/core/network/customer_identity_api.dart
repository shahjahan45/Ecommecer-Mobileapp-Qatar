import 'api_client.dart';

class CustomerIdentityApi {
  CustomerIdentityApi({ApiClient? client}) : client = client ?? ApiClient();

  final ApiClient client;

  Future<Map<String, dynamic>> fetchAuthConfig() async {
    final response =
        await client.get('/api/v1/auth/config', authenticated: false);
    return response.jsonObject;
  }

  Future<Map<String, dynamic>> exchangeFirebaseToken({
    required String idToken,
    String? name,
  }) async {
    final response = await client.post(
      '/api/v1/auth/firebase/exchange',
      authenticated: false,
      body: <String, dynamic>{
        'id_token': idToken,
        'name': name,
        'device': 'flutter-mobile',
      },
    );
    return response.jsonObject;
  }

  Future<void> sendRegistrationEmailOtp({required String idToken}) async {
    await client.post(
      '/api/v1/auth/firebase/email-otp/send',
      authenticated: false,
      body: <String, dynamic>{'id_token': idToken},
    );
  }

  Future<Map<String, dynamic>> verifyRegistrationEmailOtp({
    required String idToken,
    required String code,
    String? name,
  }) async {
    final response = await client.post(
      '/api/v1/auth/firebase/email-otp/verify',
      authenticated: false,
      body: <String, dynamic>{
        'id_token': idToken,
        'code': code,
        'name': name,
        'device': 'flutter-mobile',
      },
    );
    return response.jsonObject;
  }

  Future<void> registerDevice({
    required String fcmToken,
    required String platform,
    bool notificationsEnabled = true,
  }) async {
    await client.post(
      '/api/v1/devices',
      body: <String, dynamic>{
        'fcm_token': fcmToken,
        'platform': platform,
        'app_version': '1.19.4',
        'notifications_enabled': notificationsEnabled,
      },
    );
  }

  Future<void> unregisterDevice({required String fcmToken}) async {
    await client.delete(
      '/api/v1/devices',
      body: <String, dynamic>{'fcm_token': fcmToken},
    );
  }
}
