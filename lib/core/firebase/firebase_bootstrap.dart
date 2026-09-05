import 'package:firebase_core/firebase_core.dart';

import 'firebase_environment.dart';
import 'firebase_native_platform.dart';

class FirebaseBootstrap {
  FirebaseBootstrap._();

  static bool _initialized = false;

  /// Android production/debug builds use android/app/google-services.json.
  /// Dart-defines remain supported for non-Android targets and CI scenarios.
  static bool get isConfigured =>
      FirebaseEnvironment.isConfigured || hasNativeFirebaseAndroidConfig;

  static bool get isReady => _initialized && Firebase.apps.isNotEmpty;

  static Future<bool> ensureInitialized() async {
    if (!isConfigured) return false;
    if (_initialized && Firebase.apps.isNotEmpty) return true;

    try {
      if (Firebase.apps.isEmpty) {
        if (FirebaseEnvironment.isConfigured) {
          await Firebase.initializeApp(options: FirebaseEnvironment.options);
        } else {
          // Android reads the generated resources produced from
          // android/app/google-services.json by the Google Services plugin.
          await Firebase.initializeApp();
        }
      }
      _initialized = true;
      return true;
    } on FirebaseException catch (error) {
      if (error.code == 'duplicate-app') {
        _initialized = true;
        return true;
      }
      rethrow;
    }
  }
}
