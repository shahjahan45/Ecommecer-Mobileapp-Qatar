import 'package:flutter/material.dart';

extension DcxThemeContext on BuildContext {
  ColorScheme get dcxScheme => Theme.of(this).colorScheme;
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  Color get dcxBackground => Theme.of(this).scaffoldBackgroundColor;
  Color get dcxSurface => dcxScheme.surface;
  Color get dcxSurfaceMuted => dcxScheme.surfaceContainer;
  Color get dcxSurfaceStrong => dcxScheme.surfaceContainerHigh;
  Color get dcxTextPrimary => dcxScheme.onSurface;
  Color get dcxTextSecondary => dcxScheme.onSurfaceVariant;
  Color get dcxTextTertiary => dcxScheme.onSurfaceVariant.withValues(alpha: .72);
  Color get dcxBorder => dcxScheme.outlineVariant;
}
