# Firebase Android configuration — integrated

The supplied Firebase Android client configuration has been integrated at:

`android/app/google-services.json`

Verified client identifiers:

- Firebase project: `dcx-ecom`
- Project number / Messaging sender ID: `412921458887`
- Android application ID: `1:412921458887:android:6be8d8f1fd031112b80ee2`
- Android package: `com.example.ecommerce_mobile`
- Storage bucket: `dcx-ecom.firebasestorage.app`

The package matches the Flutter Android `applicationId`/`namespace`.

## Still required in Firebase Console

Phone Authentication on a real Android device requires your Android signing SHA fingerprints in Firebase Project Settings. Add both debug SHA-1 and SHA-256 now, and later add your Play/upload signing fingerprints for production.

The Firebase backend service-account JSON is deliberately **not** included in the mobile project. Place it only in DCX Core at `storage/app/firebase/service-account.json` to enable Laravel → FCM sending.
