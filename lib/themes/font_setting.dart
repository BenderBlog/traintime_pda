// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

// Font size / weight global settings, used by the font size page.

import 'package:flutter/material.dart';

/// The range of the font scale slider.
const minFontScale = 0.8;
const maxFontScale = 1.4;

/// The default font scale.
const defaultFontScale = 1.0;

/// The default font weight slider value, maps to [FontWeight.w500].
const defaultFontWeight = 0.5;

/// Font weight slider value range: 0.0 to 1.0.
const minFontWeight = 0.0;
const maxFontWeight = 1.0;

/// Font weight slider steps, 5 levels from thin to bold.
const fontWeightSliderDivisions = 4;

/// Font weight label keys for i18n, aligned with slider levels.
const fontWeightLabels = [
  'thin',
  'regular',
  'medium',
  'semibold',
  'bold',
];

/// Map the slider value to a [FontWeight] in w300..w700.
FontWeight fontWeightFromSlider(double value) {
  final index = (value * fontWeightSliderDivisions).round().clamp(0, 4) + 2;
  return FontWeight.values[index];
}

/// The label index of the font weight slider value.
int fontWeightLabelIndex(double value) {
  return (value * fontWeightSliderDivisions).round().clamp(0, 4);
}

/// Apply a [FontWeight] to every style of the [TextTheme].
TextTheme applyFontWeightToTheme(TextTheme theme, FontWeight weight) {
  TextStyle? apply(TextStyle? style) => style?.copyWith(fontWeight: weight);
  return TextTheme(
    displayLarge: apply(theme.displayLarge),
    displayMedium: apply(theme.displayMedium),
    displaySmall: apply(theme.displaySmall),
    headlineLarge: apply(theme.headlineLarge),
    headlineMedium: apply(theme.headlineMedium),
    headlineSmall: apply(theme.headlineSmall),
    titleLarge: apply(theme.titleLarge),
    titleMedium: apply(theme.titleMedium),
    titleSmall: apply(theme.titleSmall),
    bodyLarge: apply(theme.bodyLarge),
    bodyMedium: apply(theme.bodyMedium),
    bodySmall: apply(theme.bodySmall),
    labelLarge: apply(theme.labelLarge),
    labelMedium: apply(theme.labelMedium),
    labelSmall: apply(theme.labelSmall),
  );
}

extension FontWeightThemeData on ThemeData {
  /// Returns a copy of this theme with the global font weight applied.
  ThemeData applyFontWeight(FontWeight weight) => copyWith(
    textTheme: applyFontWeightToTheme(textTheme, weight),
  );
}
