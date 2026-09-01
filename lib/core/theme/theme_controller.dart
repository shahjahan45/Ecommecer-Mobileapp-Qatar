import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum DcxThemePreference { system, light, dark }

extension DcxThemePreferenceX on DcxThemePreference {
  String get storageValue => name;

  String get label {
    switch (this) {
      case DcxThemePreference.system:
        return 'Use device setting';
      case DcxThemePreference.light:
        return 'Light';
      case DcxThemePreference.dark:
        return 'Dark';
    }
  }

  ThemeMode get themeMode {
    switch (this) {
      case DcxThemePreference.system:
        return ThemeMode.system;
      case DcxThemePreference.light:
        return ThemeMode.light;
      case DcxThemePreference.dark:
        return ThemeMode.dark;
    }
  }
}

class ThemeController extends ChangeNotifier {
  ThemeController._();

  static final ThemeController instance = ThemeController._();
  static const _storageKey = 'dcx.theme.preference';

  SharedPreferencesAsync? _preferences;

  SharedPreferencesAsync _preferencesStore() {
    return _preferences ??= SharedPreferencesAsync();
  }

  DcxThemePreference _preference = DcxThemePreference.system;
  bool _loaded = false;

  DcxThemePreference get preference => _preference;
  ThemeMode get themeMode => _preference.themeMode;
  bool get loaded => _loaded;

  Future<void> load() async {
    if (_loaded) return;
    try {
      final stored = await _preferencesStore().getString(_storageKey);
      _preference = DcxThemePreference.values.firstWhere(
        (value) => value.storageValue == stored,
        orElse: () => DcxThemePreference.system,
      );
    } catch (_) {
      _preference = DcxThemePreference.system;
    }
    _loaded = true;
    notifyListeners();
  }

  Future<void> setPreference(
    DcxThemePreference value, {
    bool persist = true,
  }) async {
    if (_preference == value && _loaded) return;
    _preference = value;
    _loaded = true;
    notifyListeners();
    if (!persist) return;
    try {
      await _preferencesStore().setString(_storageKey, value.storageValue);
    } catch (_) {
      // Theme selection remains active for the current session even if the
      // platform preference store is temporarily unavailable.
    }
  }
}
