# Google Maps setup — Phase 15

Phase 15 includes an optional Google Maps delivery-location picker using `google_maps_flutter` and `geocoding`.

## Android

1. In Google Cloud Console, enable **Maps SDK for Android** for your project.
2. Create a restricted Android API key for the app package.
3. Open:

   `android/app/src/main/AndroidManifest.xml`

4. Replace:

   `YOUR_GOOGLE_MAPS_API_KEY`

   with the restricted key.

The map location remains optional. Customers can save and use a normal typed address even when Maps is not configured.

## iOS

When the complete iOS runner is generated/configured, enable **Maps SDK for iOS**, add the Google Maps API key using the current `google_maps_flutter` iOS setup instructions, and restrict the key to the iOS bundle identifier.

## Security

Do not commit unrestricted production API keys. Use platform restrictions and separate keys for Android and iOS in production.
