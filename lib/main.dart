import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app.dart';
import 'core/firebase/firebase_bootstrap.dart';
import 'core/firebase/push_notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Phase 19.1: Android initializes from android/app/google-services.json.
  // Dart-defined FirebaseOptions remain supported for other targets/CI.
  if (await FirebaseBootstrap.ensureInitialized()) {
    await PushNotificationService.instance.initialize();
  }

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  runApp(const EcommerceApp());
}
