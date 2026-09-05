# DCX Online Store — Firebase setup (Phase 19.1 Final)

The real Android Firebase client configuration is already installed in:

`android/app/google-services.json`

The Android package is `com.example.ecommerce_mobile` and matches the supplied Firebase app in project `dcx-ecom`.

## What now works from the Android client configuration

- Firebase Core initialization
- Email/Password Authentication
- Firebase email verification
- Firebase password-reset email
- Phone Authentication / SMS OTP (after Firebase Console prerequisites below)
- Firebase Cloud Messaging token registration / receiving

No Firebase Dart defines are required for normal Android runs. The app auto-initializes from `google-services.json`.

## Firebase Console requirements

Firebase Console → Authentication → Sign-in method:

- Enable **Email/Password**
- Enable **Phone**

Firebase Console → Project settings → Android app:

- Confirm package: `com.example.ecommerce_mobile`
- Add the Android signing **SHA-1**
- Add the Android signing **SHA-256**

Get debug fingerprints on Windows:

```powershell
cd C:\xampp\htdocs\ecommerce_mobile
powershell -ExecutionPolicy Bypass -File .\tools\prepare_android.ps1
cd android
.\gradlew.bat signingReport
```

Add release/upload SHA fingerprints later before Play Store publication.

For development, Firebase Authentication → Phone → Phone numbers for testing can be used to validate the flow without consuming real SMS quota.

## Customer registration flow

1. Customer enters full name, email, required mobile number and strong password.
2. Firebase sends SMS OTP to the mobile number.
3. SMS verification creates/validates the Firebase phone identity.
4. Email/password is linked to the same Firebase user.
5. Firebase sends the standard email-verification link.
6. After verification, Flutter sends a fresh Firebase ID token to DCX Core.
7. DCX Core verifies the Firebase identity and creates/updates the real customer account.
8. DCX Core returns the customer Sanctum token used for orders, addresses, support and profile APIs.
9. FCM token is registered to that customer/device.
10. Optional Laravel six-digit email OTP can be enabled as an additional verification layer.

## Run on the current Samsung / LAN

```powershell
flutter run `
  --dart-define=DCX_API_MODE=remote `
  --dart-define=DCX_API_BASE_URL=http://192.168.18.21:8000
```

Firebase Android configuration is loaded automatically.

## DCX Core Firebase configuration

Merge these values into your existing backend `.env`:

```env
FIREBASE_PROJECT_ID=dcx-ecom
FIREBASE_WEB_API_KEY=<use the current_key from android/app/google-services.json>
FIREBASE_SERVICE_ACCOUNT_PATH=storage/app/firebase/service-account.json
DCX_REQUIRE_PHONE_VERIFICATION=true
DCX_REQUIRE_EMAIL_VERIFICATION=true
DCX_REQUIRE_EMAIL_OTP=false
DCX_EMAIL_OTP_TTL_MINUTES=10
DCX_PUSH_NOTIFICATIONS_ENABLED=true
```

The Firebase Android API key is client configuration; the Firebase **service-account JSON/private key is server-only**. Never place the service-account file in Flutter, `public`, or `public_html`.

Place the service-account file at:

`C:\xampp\htdocs\dcx-core\storage\app\firebase\service-account.json`

It is required for Laravel to send FCM HTTP v1 pushes. Authentication/exchange can work with the Firebase project/API-key configuration, but server-originated FCM delivery requires the service account.

## Optional six-digit email OTP

Configure a real Laravel SMTP provider and set:

```env
DCX_REQUIRE_EMAIL_OTP=true
```

DCX Core uses hashed OTP storage, expiration, attempt limits and throttling.

## Push notifications

The app:

- requests Android notification permission
- creates `dcx_updates` high-priority notification channel
- registers/refreshed FCM tokens with DCX Core
- removes the current-device token on logout
- records foreground pushes in the in-app Notification Center
- receives background/terminated notification messages through Android/Firebase

Admin can send customer-specific and broadcast notifications after the backend service-account credential is installed.
