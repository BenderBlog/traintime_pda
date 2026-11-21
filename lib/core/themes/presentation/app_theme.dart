// Copyright 2026 Hazuki Keatsu
// SPDX-License-Identifier: MPL-2.0

import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:material_ui/material_ui.dart';
import 'package:watermeter/core/interfaces/theme_store_interface.dart';

final class AppTheme {
  static Color paletteColor(ThemePalette palette) =>
      _colors(palette, Brightness.light).primary;

  static ThemeMode mode(ThemeBrightness brightness) => switch (brightness) {
    ThemeBrightness.system => ThemeMode.system,
    ThemeBrightness.light => ThemeMode.light,
    ThemeBrightness.dark => ThemeMode.dark,
  };

  static ThemeData light(ThemeSettings settings) => _build(settings, false);
  static ThemeData dark(ThemeSettings settings) => _build(settings, true);

  static ThemeData _build(ThemeSettings settings, bool dark) {
    final colors = _colors(
      settings.palette,
      dark ? Brightness.dark : Brightness.light,
    );
    final theme = dark
        ? FlexThemeData.dark(colors: colors, usedColors: 1)
        : FlexThemeData.light(colors: colors, usedColors: 1);
    final weight =
        FontWeight.values[(settings.fontWeight * 4).round().clamp(0, 4) + 2];
    TextStyle? apply(TextStyle? style) => style?.copyWith(fontWeight: weight);
    final text = theme.textTheme;
    return theme.copyWith(
      textTheme: text.copyWith(
        displayLarge: apply(text.displayLarge),
        displayMedium: apply(text.displayMedium),
        displaySmall: apply(text.displaySmall),
        headlineLarge: apply(text.headlineLarge),
        headlineMedium: apply(text.headlineMedium),
        headlineSmall: apply(text.headlineSmall),
        titleLarge: apply(text.titleLarge),
        titleMedium: apply(text.titleMedium),
        titleSmall: apply(text.titleSmall),
        bodyLarge: apply(text.bodyLarge),
        bodyMedium: apply(text.bodyMedium),
        bodySmall: apply(text.bodySmall),
        labelLarge: apply(text.labelLarge),
        labelMedium: apply(text.labelMedium),
        labelSmall: apply(text.labelSmall),
      ),
    );
  }

  static FlexSchemeColor _colors(ThemePalette palette, Brightness brightness) {
    final dark = brightness == Brightness.dark;
    return switch (palette) {
      ThemePalette.indigo => dark ? _indigoDark : _indigoLight,
      ThemePalette.blue => FlexScheme.blue.colors(brightness),
      ThemePalette.deepPurple => FlexScheme.deepPurple.colors(brightness),
      ThemePalette.green => dark ? _greenDark : _greenLight,
      ThemePalette.orange => dark ? _orangeDark : _orangeLight,
      ThemePalette.pink => FlexScheme.pinkM3.colors(brightness),
    };
  }
}

const _indigoLight = FlexSchemeColor(
  primary: Color(0xff3f5f90),
  primaryContainer: Color(0xffd0e4ff),
  primaryLightRef: Color(0xff3f5f90),
  secondary: Color(0xff526070),
  secondaryContainer: Color(0xffffdbcf),
  secondaryLightRef: Color(0xff526070),
  tertiary: Color(0xff006875),
  tertiaryContainer: Color(0xff95f0ff),
  tertiaryLightRef: Color(0xff006875),
  appBarColor: Color(0xffffdbcf),
  error: Color(0xffba1a1a),
  errorContainer: Color(0xffffdad6),
);

const _indigoDark = FlexSchemeColor(
  primary: Color(0xff9fc9ff),
  primaryContainer: Color(0xff00325b),
  primaryLightRef: Color(0xff3f5f90),
  secondary: Color(0xffffb59d),
  secondaryContainer: Color(0xff872100),
  secondaryLightRef: Color(0xff526070),
  tertiary: Color(0xff86d2e1),
  tertiaryContainer: Color(0xff004e59),
  tertiaryLightRef: Color(0xff006875),
  appBarColor: Color(0xffffdbcf),
  error: Color(0xffffb4ab),
  errorContainer: Color(0xff93000a),
);

const _greenLight = FlexSchemeColor(
  primary: Color(0xff4ea34c),
  primaryContainer: Color(0xff92c692),
  primaryLightRef: Color(0xff4ea34c),
  secondary: Color(0xffa5e0bd),
  secondaryContainer: Color(0xff5fc889),
  secondaryLightRef: Color(0xffa5e0bd),
  tertiary: Color(0xff7cba34),
  tertiaryContainer: Color(0xffafd583),
  tertiaryLightRef: Color(0xff7cba34),
  appBarColor: Color(0xff5fc889),
  error: Color(0xffc33a26),
  errorContainer: Color(0xffffcdd3),
);

const _greenDark = FlexSchemeColor(
  primary: Color(0xff4ea34c),
  primaryContainer: Color(0xff73fa70),
  primaryLightRef: Color(0xff4ea34c),
  secondary: Color(0xff489466),
  secondaryContainer: Color(0xff5fc889),
  secondaryLightRef: Color(0xffa5e0bd),
  tertiary: Color(0xff7cba34),
  tertiaryContainer: Color(0xffabff4a),
  tertiaryLightRef: Color(0xff7cba34),
  appBarColor: Color(0xff5fc889),
  error: Color(0xffc33a26),
  errorContainer: Color(0xff8e1003),
);

const _orangeLight = FlexSchemeColor(
  primary: Color(0xffdb683f),
  primaryContainer: Color(0xffd0e4ff),
  primaryLightRef: Color(0xffdb683f),
  secondary: Color(0xffac3306),
  secondaryContainer: Color(0xffffdbcf),
  secondaryLightRef: Color(0xffac3306),
  tertiary: Color(0xff006875),
  tertiaryContainer: Color(0xff95f0ff),
  tertiaryLightRef: Color(0xff006875),
  appBarColor: Color(0xffffdbcf),
  error: Color(0xffba1a1a),
  errorContainer: Color(0xffffdad6),
);

const _orangeDark = FlexSchemeColor(
  primary: Color(0xff9fc9ff),
  primaryContainer: Color(0xff00325b),
  primaryLightRef: Color(0xffdb683f),
  secondary: Color(0xffffb59d),
  secondaryContainer: Color(0xff872100),
  secondaryLightRef: Color(0xffac3306),
  tertiary: Color(0xff86d2e1),
  tertiaryContainer: Color(0xff004e59),
  tertiaryLightRef: Color(0xff006875),
  appBarColor: Color(0xffffdbcf),
  error: Color(0xffffb4ab),
  errorContainer: Color(0xff93000a),
);
