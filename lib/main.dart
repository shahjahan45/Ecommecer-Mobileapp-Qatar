import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Android 15+ enforces edge-to-edge for modern target SDKs. Configure the
  // system bars up front so the first Flutter frame and the rest of the app
  // use a consistent, bezel-less surface while SafeArea/insets continue to
  // protect interactive content.
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  runApp(const EcommerceApp());
}
