# Phase 15 — Premium Saved Addresses, Google Maps & Footer Reorganization

Version: `1.15.0+48`

## Address experience

- Shared `AddressBookController` used by Profile and Checkout.
- Persistent saved addresses backed by `SharedPreferencesAsync` with in-memory fallback for tests/unsupported hosts.
- Home / Work / Other address types.
- Checkout includes **Save this address for future use**.
- Saved addresses can be selected later without retyping.
- First saved address becomes the default automatically; default can be changed in Profile.
- Optional Google Maps location picker with search, tap-to-pin and draggable marker behavior.
- Reverse geocoding shows the selected location before confirmation and can prefill the typed delivery-address field.
- Map location is optional; checkout works with a normal typed address.

## Footer experience

- Full branded footer moved from Order Confirmation to the bottom of Profile.
- Profile footer keeps the official DCX logo and professional developer credit:
  - Sajahan Mansoor
  - DataCubeX Technologies
- Home receives a smaller logo-free `DcxHomeBottomSection`.
- Home bottom section includes Facebook, Instagram, YouTube and TikTok icons plus Help, Contact, About, Privacy, Terms, Refund and FAQs links.
- Help/Contact/FAQs link into the Support Center.
- About/Privacy/Terms/Refund link to dedicated app information screens.

## Files added

- `lib/models/saved_address.dart`
- `lib/features/profile/address/address_book_controller.dart`
- `lib/features/profile/address/map_location_picker_page.dart`
- `lib/features/checkout/checkout_address_sheet.dart`
- `lib/features/profile/app_information_page.dart`
- `test/address_book_controller_test.dart`
- `test/saved_address_checkout_test.dart`
- `test/home_bottom_section_test.dart`
- `GOOGLE_MAPS_SETUP.md`

## Packages

- `google_maps_flutter: 2.12.3`
- `geocoding: ^5.0.0`
- `font_awesome_flutter: ^11.0.0`

See `GOOGLE_MAPS_SETUP.md` before testing the live Google Maps screen.
