import 'package:ecommerce_mobile/core/network/session_controller.dart';
import 'package:ecommerce_mobile/features/profile/change_password_page.dart';
import 'package:ecommerce_mobile/features/profile/personal_details_page.dart';
import 'package:ecommerce_mobile/features/profile/services/customer_account_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeAccountService implements CustomerAccountService {
  CustomerProfile profile = const CustomerProfile(
    id: '42',
    name: 'Test Customer',
    email: 'customer@example.com',
    phone: '+974 5555 0101',
  );
  String? changedPassword;

  @override
  Future<CustomerProfile> loadProfile() async => profile;

  @override
  Future<CustomerProfile> updateProfile({
    required String name,
    required String email,
    String? phone,
  }) async {
    profile = CustomerProfile(
      id: profile.id,
      name: name,
      email: email,
      phone: phone,
    );
    return profile;
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    changedPassword = newPassword;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('personal details load and save account information', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final session = SessionController.instance..resetForTesting();
    session.activateDemoSession(email: 'customer@example.com');
    addTearDown(session.resetForTesting);
    final service = _FakeAccountService();

    await tester.pumpWidget(
      MaterialApp(home: PersonalDetailsPage(accountService: service)),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('personal-details-page')), findsOneWidget);
    expect(find.text('Test Customer'), findsOneWidget);
    expect(find.text('customer@example.com'), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('personal-details-name')),
      'Updated Customer',
    );
    await tester.tap(find.byKey(const Key('personal-details-save')));
    await tester.pumpAndSettle();

    expect(service.profile.name, 'Updated Customer');
    expect(find.text('Your personal details were updated.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('change password validates and submits strong credentials', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final session = SessionController.instance..resetForTesting();
    session.activateDemoSession(email: 'customer@example.com');
    addTearDown(session.resetForTesting);
    final service = _FakeAccountService();

    await tester.pumpWidget(
      MaterialApp(home: ChangePasswordPage(accountService: service)),
    );
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('change-password-current')),
      'Customer@123',
    );
    await tester.enterText(
      find.byKey(const Key('change-password-new')),
      'NewCustomer@456',
    );
    await tester.enterText(
      find.byKey(const Key('change-password-confirm')),
      'NewCustomer@456',
    );
    await tester.tap(find.byKey(const Key('change-password-submit')));
    await tester.pumpAndSettle();

    expect(service.changedPassword, 'NewCustomer@456');
    expect(
      find.text('Password updated successfully. Your account credentials are now secure.'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}
