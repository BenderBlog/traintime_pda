// Copyright 2026 Traintime PDA authors, originally by Hazuki Keatsu
// SPDX-License-Identifier: MPL-2.0

import 'package:signals/signals.dart';

// Order matches the existing `color` preference values.
enum ThemePalette { indigo, blue, deepPurple, green, orange, pink }

// Order matches the existing `brightness` preference values.
enum ThemeBrightness { system, light, dark }

final class ThemeSettings {
  ThemeSettings({
    this.palette = ThemePalette.indigo,
    this.brightness = ThemeBrightness.system,
    this.fontScale = 1.0,
    this.fontWeight = 0.5,
  }) {
    if (!fontScale.isFinite || fontScale < 0.8 || fontScale > 1.4) {
      throw RangeError.value(fontScale, 'fontScale', 'must be within 0.8..1.4');
    }
    if (!fontWeight.isFinite || fontWeight < 0.0 || fontWeight > 1.0) {
      throw RangeError.value(
        fontWeight,
        'fontWeight',
        'must be within 0.0..1.0',
      );
    }
  }

  final ThemePalette palette;
  final ThemeBrightness brightness;
  final double fontScale;
  final double fontWeight;

  ThemeSettings copyWith({
    ThemePalette? palette,
    ThemeBrightness? brightness,
    double? fontScale,
    double? fontWeight,
  }) => ThemeSettings(
    palette: palette ?? this.palette,
    brightness: brightness ?? this.brightness,
    fontScale: fontScale ?? this.fontScale,
    fontWeight: fontWeight ?? this.fontWeight,
  );
}

abstract interface class ThemeStoreInterface {
  ReadonlySignal<ThemeSettings> get settings;
  Future<void> setPalette(ThemePalette palette);
  Future<void> setBrightness(ThemeBrightness brightness);
  Future<void> setFontScale(double scale);
  Future<void> setFontWeight(double weight);
  void dispose();
}
