import 'package:ecommerce_mobile/core/network/commerce_api_gateway.dart';
import 'package:ecommerce_mobile/core/network/session_controller.dart';
import 'package:ecommerce_mobile/core/persistence/customer_session_persistence.dart';
import 'package:ecommerce_mobile/core/sync/cloud_sync_controller.dart';
import 'package:ecommerce_mobile/core/theme/app_theme.dart';
import 'package:ecommerce_mobile/features/profile/address/address_book_controller.dart';
import 'package:ecommerce_mobile/features/profile/data_sync_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _NoopGateway implements CommerceApiGateway {
  @override
  Future<void> healthCheck() async {}

  @override
  Future<Map<String, dynamic>> signIn({
    required String email,
    required String password,
  }) async => <String, dynamic>{};

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
  }) async => <String, dynamic>{};
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  for (final size in <Size>[
    const Size(320, 568),
    const Size(360, 640),
    const Size(412, 915),
    const Size(800, 1100),
  ]) {
    testWidgets('data sync page stays responsive at ${size.width}x${size.height}', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(size);
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final persistence = CustomerSessionPersistence.forTesting(
        MemoryCustomerSessionStorage(),
      );
      persistence.applySnapshotForTesting(<String, dynamic>{
        'version': 1,
        'savedAt': '2026-09-02T12:15:00.000',
      });
      final addresses = AddressBookController.instance;
      addresses.resetForTesting();
      final session = SessionController.instance..resetForTesting();
      addTearDown(session.resetForTesting);

      final controller = CloudSyncController.forTesting(
        gateway: _NoopGateway(),
        persistence: persistence,
        addressBook: addresses,
        sessionController: session,
        remoteConfigured: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: DataSyncPage(
            controller: controller,
            sessionController: session,
            persistence: persistence,
            addressBook: addresses,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('data-sync-hero')), findsOneWidget);
      expect(find.text('Offline-first by default'), findsOneWidget);
      expect(find.byKey(const Key('sync-now-action')), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
