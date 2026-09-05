import 'package:firebase_core/firebase_core.dart';

class FirebaseEnvironment {
  FirebaseEnvironment._();

  static const apiKey = String.fromEnvironment('DCX_FIREBASE_API_KEY');
  static const appId = String.fromEnvironment('DCX_FIREBASE_APP_ID');
  static const messagingSenderId =
      String.fromEnvironment('DCX_FIREBASE_MESSAGING_SENDER_ID');
  static const projectId = String.fromEnvironment('DCX_FIREBASE_PROJECT_ID');
  static const storageBucket =
      String.fromEnvironment('DCX_FIREBASE_STORAGE_BUCKET');

  static bool get isConfigured =>
      apiKey.trim().isNotEmpty &&
      appId.trim().isNotEmpty &&
      messagingSenderId.trim().isNotEmpty &&
      projectId.trim().isNotEmpty;

  static FirebaseOptions get options => FirebaseOptions(
        apiKey: apiKey,
        appId: appId,
        messagingSenderId: messagingSenderId,
        projectId: projectId,
        storageBucket: storageBucket.trim().isEmpty ? null : storageBucket,
      );
}
