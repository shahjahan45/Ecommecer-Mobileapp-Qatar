import 'package:ecommerce_mobile/core/network/commerce_api_gateway.dart';
import 'package:ecommerce_mobile/core/network/session_controller.dart';
import 'package:ecommerce_mobile/core/persistence/customer_session_persistence.dart';
import 'package:ecommerce_mobile/core/sync/cloud_sync_controller.dart';
import 'package:ecommerce_mobile/features/profile/address/address_book_controller.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeGateway implements CommerceApiGateway {
  bool healthChecked = false;
  Map<String, dynamic>? lastPayload;
  String? lastIdempotencyKey;

  @override
  Future<void> healthCheck() async {
    healthChecked = true;
  }

  @override
  Future<Map<String, dynamic>> signIn({
    required String email,
    required String password,
  }) async => <String, dynamic>{
        'access_token': 'token',
      };

  @override
  Future<void> signOut() async {}

  @override
  Future<Map<String, dynamic>> fetchCustomerProfile() async => <String, dynamic>{
        'customer': <String, dynamic>{
          'id': '1',
          'name': 'Test Customer',
          'email': 'customer@example.com',
          'phone': '+974 5555 0101',
        },
      };

  @override
  Future<Map<String, dynamic>> updateCustomerProfile({
    required String name,
    required String email,
    String? phone,
  }) async => <String, dynamic>{
        'customer': <String, dynamic>{
          'id': '1',
          'name': name,
          'email': email,
          'phone': phone,
        },
      };

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {}

  @override
  Future<Map<String, dynamic>> fetchOrders() async => <String, dynamic>{'data': <dynamic>[]};

  @override
  Future<Map<String, dynamic>> fetchSupportTickets() async => <String, dynamic>{'data': <dynamic>[]};

  @override
  Future<Map<String, dynamic>> createSupportTicket({
    required String category,
    required String subject,
    required String message,
    String? orderNumber,
  }) async => <String, dynamic>{};

  @override
  Future<Map<String, dynamic>> replySupportTicket({
    required int ticketId,
    required String message,
  }) async => <String, dynamic>{};

  @override
  Future<Map<String, dynamic>> syncCustomerState({
    required Map<String, dynamic> payload,
    required String idempotencyKey,
  }) async {
    lastPayload = payload;
    lastIdempotencyKey = idempotencyKey;
    return <String, dynamic>{'synced': true};
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('local mode saves continuity without contacting remote gateway', () async {
    final gateway = _FakeGateway();
    final persistence = CustomerSessionPersistence.forTesting(
      MemoryCustomerSessionStorage(),
    );
    final addresses = AddressBookController.instance;
    addresses.resetForTesting();
    final session = SessionController.instance..resetForTesting();
    addTearDown(session.resetForTesting);

    final controller = CloudSyncController.forTesting(
      gateway: gateway,
      persistence: persistence,
      addressBook: addresses,
      sessionController: session,
      remoteConfigured: false,
    );

    await controller.syncNow();

    expect(controller.state, CloudSyncState.localOnly);
    expect(gateway.lastPayload, isNull);
    expect(persistence.lastSavedAt, isNotNull);
  });

  test('remote mode sends authenticated customer snapshot with idempotency key', () async {
    final gateway = _FakeGateway();
    final persistence = CustomerSessionPersistence.forTesting(
      MemoryCustomerSessionStorage(),
    );
    final addresses = AddressBookController.instance;
    addresses.resetForTesting();
    final session = SessionController.instance..resetForTesting();
    session.activateRemoteSession(
      accessToken: 'remote-token',
      email: 'customer@example.com',
      customerId: 'customer-1',
    );
    addTearDown(session.resetForTesting);

    final controller = CloudSyncController.forTesting(
      gateway: gateway,
      persistence: persistence,
      addressBook: addresses,
      sessionController: session,
      remoteConfigured: true,
    );

    await controller.checkConnection();
    expect(gateway.healthChecked, isTrue);
    expect(controller.state, CloudSyncState.ready);

    await controller.syncNow();

    expect(controller.state, CloudSyncState.success);
    expect(gateway.lastPayload, isNotNull);
    expect(gateway.lastPayload!['schema'], 'dcx-mobile-sync-v1');
    expect(gateway.lastPayload!['session'], isA<Map<String, dynamic>>());
    expect(gateway.lastPayload!['addresses'], isA<List<dynamic>>());
    expect(gateway.lastIdempotencyKey, startsWith('mobile-sync-customer-1-'));
  });
}
