import 'package:flutter/material.dart';

class AppBreakpoints {
  AppBreakpoints._();

  static const double tinyPhone = 350;
  static const double phone = 600;
  static const double tablet = 900;
  static const double desktop = 1200;
}

class ResponsiveLayout {
  ResponsiveLayout._();

  static Size sizeOf(BuildContext context) => MediaQuery.sizeOf(context);

  static bool isTinyPhone(BuildContext context) =>
      sizeOf(context).width < AppBreakpoints.tinyPhone;

  static bool isPhone(BuildContext context) =>
      sizeOf(context).width < AppBreakpoints.phone;

  static bool isTablet(BuildContext context) {
    final width = sizeOf(context).width;
    return width >= AppBreakpoints.phone && width < AppBreakpoints.tablet;
  }

  static double pagePadding(BuildContext context) {
    final width = sizeOf(context).width;
    if (width < AppBreakpoints.tinyPhone) return 14;
    if (width < AppBreakpoints.phone) return 20;
    if (width < AppBreakpoints.tablet) return 28;
    return 40;
  }

  static int productColumns(double width) {
    if (width < 370) return 1;
    if (width < 680) return 2;
    if (width < 1000) return 3;
    return 4;
  }
}
