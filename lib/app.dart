import 'package:flutter/material.dart';

import 'core/constants/app_constants.dart';
import 'core/scroll/app_scroll_behavior.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/splash/splash_page.dart';

class EcommerceApp extends StatelessWidget {
  const EcommerceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      scrollBehavior: const AppScrollBehavior(),
      theme: AppTheme.lightTheme,
      builder: (context, child) {
        if (child == null) return const SizedBox.shrink();

        // Keep the entire UI stable across very small phones, large phones,
        // tablets and devices with oversized system font settings. We still
        // respect accessibility scaling, but cap it at a level the mobile UI
        // kit is designed to support without clipped controls or RenderFlex
        // overflows.
        return MediaQuery.withClampedTextScaling(
          minScaleFactor: 0.90,
          maxScaleFactor: 1.20,
          child: child,
        );
      },
      home: const SplashPage(),
    );
  }
}
