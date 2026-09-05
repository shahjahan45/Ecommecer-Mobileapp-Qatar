import '../storefront/storefront_controller.dart';

class AppConstants {
  AppConstants._();

  static const String appName = 'DCX Online Store';
  static const String appVersion = '1.19.4';

  static String get currency => StorefrontController.instance.settingString(
        'general',
        'currency',
        'QAR',
      );
}
