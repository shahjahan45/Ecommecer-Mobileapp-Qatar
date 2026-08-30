enum AuthProvider { google, apple }

abstract class AuthService {
  const AuthService();

  Future<void> login({
    required String email,
    required String password,
    required bool rememberMe,
  });

  Future<void> loginWithProvider(AuthProvider provider);
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
  }

  @override
  Future<void> loginWithProvider(AuthProvider provider) async {
    await Future<void>.delayed(const Duration(milliseconds: 850));
  }
}
