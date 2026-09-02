import 'package:ecommerce_mobile/core/theme/app_theme.dart';
import 'package:ecommerce_mobile/core/theme/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('DCX exposes offline-safe Material 3 light and dark themes', () {
    expect(AppTheme.lightTheme.brightness, Brightness.light);
    expect(AppTheme.darkTheme.brightness, Brightness.dark);
    expect(AppTheme.lightTheme.useMaterial3, isTrue);
    expect(AppTheme.darkTheme.useMaterial3, isTrue);
    expect(AppTheme.lightTheme.colorScheme.primary, isNot(AppTheme.darkTheme.colorScheme.primary));
    expect(
      AppTheme.darkTheme.scaffoldBackgroundColor.computeLuminance(),
      lessThan(AppTheme.lightTheme.scaffoldBackgroundColor.computeLuminance()),
    );
  });

  test('in-memory theme switching does not require platform storage', () async {
    final controller = ThemeController.instance;

    await controller.setPreference(DcxThemePreference.dark, persist: false);
    expect(controller.themeMode, ThemeMode.dark);

    await controller.setPreference(DcxThemePreference.system, persist: false);
    expect(controller.themeMode, ThemeMode.system);
  });

  test('theme controller maps all appearance preferences correctly', () async {
    final controller = ThemeController.instance;

    await controller.setPreference(DcxThemePreference.system, persist: false);
    expect(controller.themeMode, ThemeMode.system);

    await controller.setPreference(DcxThemePreference.light, persist: false);
    expect(controller.themeMode, ThemeMode.light);

    await controller.setPreference(DcxThemePreference.dark, persist: false);
    expect(controller.themeMode, ThemeMode.dark);

    await controller.setPreference(DcxThemePreference.system, persist: false);
  });
}
