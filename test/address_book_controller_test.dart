import 'package:ecommerce_mobile/features/profile/address/address_book_controller.dart';
import 'package:ecommerce_mobile/models/saved_address.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('saved addresses can be reused and switched as default', () async {
    final controller = AddressBookController.instance;
    controller.resetForTesting();
    addTearDown(controller.resetForTesting);

    final home = SavedAddress(
      id: 'home',
      type: SavedAddressType.home,
      fullName: 'Customer',
      mobile: '55510000',
      addressLine: 'Doha, Qatar',
      isDefault: true,
      createdAt: DateTime(2026, 9, 2),
    );
    final work = SavedAddress(
      id: 'work',
      type: SavedAddressType.work,
      fullName: 'Customer',
      mobile: '55510000',
      addressLine: 'West Bay, Doha, Qatar',
      createdAt: DateTime(2026, 9, 2),
      mapLocation: const MapLocationData(
        latitude: 25.326,
        longitude: 51.533,
        resolvedAddress: 'West Bay, Doha, Qatar',
      ),
    );

    await controller.save(home, persist: false);
    await controller.save(work, persist: false);
    expect(controller.addresses.length, 2);
    expect(controller.defaultAddress?.id, 'home');

    await controller.setDefault('work', persist: false);
    expect(controller.defaultAddress?.id, 'work');
    expect(controller.defaultAddress?.mapLocation?.displayLabel, 'West Bay, Doha, Qatar');
  });
}
