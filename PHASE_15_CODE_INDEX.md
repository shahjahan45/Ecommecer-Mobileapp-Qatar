# Phase 15 Code Index

## Saved addresses
- `lib/models/saved_address.dart` — address type, optional map pin, JSON persistence model.
- `lib/features/profile/address/address_book_controller.dart` — saved/default address state and persistence.
- `lib/features/profile/address_book_page.dart` — premium address management/editor UI.
- `lib/features/checkout/checkout_address_sheet.dart` — saved-address selection + add-new flow for checkout.
- `lib/features/checkout/checkout_page.dart` — shared address integration and confirmation summary.

## Google Maps
- `lib/features/profile/address/map_location_picker_page.dart` — Google Map, search/geocode, tap/drag pin, reverse geocode.
- `android/app/src/main/AndroidManifest.xml` — Google Maps API-key slot.
- `GOOGLE_MAPS_SETUP.md` — platform setup instructions.

## Footer / information
- `lib/core/widgets/dcx_mobile_footer.dart` — full Profile footer + minimal logo-free Home bottom section.
- `lib/features/profile/profile_page.dart` — full footer placement.
- `lib/features/home/home_page.dart` — minimal Home social/link section placement.
- `lib/features/profile/app_information_page.dart` — About/Privacy/Terms/Refund information destinations.
- `lib/features/checkout/order_confirmation_page.dart` — no longer owns the full app footer.
