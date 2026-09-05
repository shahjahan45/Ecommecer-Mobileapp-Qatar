import 'package:ecommerce_mobile/core/network/session_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('session controller keeps remote token in memory and can sign out', () {
    final controller = SessionController.instance;
    controller.resetForTesting();
    addTearDown(controller.resetForTesting);

    controller.activateRemoteSession(
      accessToken: 'secure-test-token',
      email: 'customer@example.com',
      customerId: '42',
      name: 'Test Customer',
      phone: '+974 5555 0101',
      expiresAt: DateTime.now().add(const Duration(hours: 1)),
      rememberRequested: true,
    );

    expect(controller.isAuthenticated, isTrue);
    expect(controller.isDemoSession, isFalse);
    expect(controller.bearerToken, 'secure-test-token');
    expect(controller.session.rememberRequested, isTrue);
    expect(controller.name, 'Test Customer');
    expect(controller.phone, '+974 5555 0101');

    controller.updateIdentity(
      name: 'Updated Customer',
      email: 'updated@example.com',
      phone: '+974 7000 1234',
    );
    expect(controller.name, 'Updated Customer');
    expect(controller.email, 'updated@example.com');
    expect(controller.bearerToken, 'secure-test-token');

    controller.signOut();
    expect(controller.isAuthenticated, isFalse);
    expect(controller.bearerToken, isNull);
  });
}
