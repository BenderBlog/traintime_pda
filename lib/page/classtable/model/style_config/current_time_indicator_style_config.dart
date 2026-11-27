// Copyright 2026 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'style_config_preference_functions.dart';

/// Configuration and persistence for the current-time indicator.
class CurrentTimeIndicatorConfig {
  static bool enabled = true;
  static bool showTimeLabel = true;
  static bool showTodayColumnHighlight = true;
  static double lineAlpha = 0.9;
  static double lineThickness = 2;
  static double labelHeight = 13;
  static double labelFontSize = 7;
  static double labelBackgroundAlpha = 1.0;
  static double labelHorizontalPadding = 1;
  static double labelVerticalPadding = 1;
  static double labelBorderRadius = 4;
  static double dayColumnHighlightAlpha = 0.25;
  static double dayColumnHighlightRadius = 8;

  static void loadFromPreference() {
    enabled = _readBool(
      StyleConfigPreferenceKey.currentTimeIndicatorEnabled,
      enabled,
    );
    showTimeLabel = _readBool(
      StyleConfigPreferenceKey.currentTimeIndicatorShowTimeLabel,
      showTimeLabel,
    );
    showTodayColumnHighlight = _readBool(
      StyleConfigPreferenceKey.currentTimeIndicatorShowTodayColumnHighlight,
      showTodayColumnHighlight,
    );
  }

  static Future<void> saveToPreference() async {
    await StyleConfigPreferenceFunctions.setBool(
      StyleConfigPreferenceKey.currentTimeIndicatorEnabled,
      enabled,
    );
    await StyleConfigPreferenceFunctions.setBool(
      StyleConfigPreferenceKey.currentTimeIndicatorShowTimeLabel,
      showTimeLabel,
    );
    await StyleConfigPreferenceFunctions.setBool(
      StyleConfigPreferenceKey.currentTimeIndicatorShowTodayColumnHighlight,
      showTodayColumnHighlight,
    );
  }

  static Future<void> setEnabled(bool value) async {
    enabled = value;
    await saveToPreference();
  }

  static Future<void> setShowTimeLabel(bool value) async {
    showTimeLabel = value;
    await saveToPreference();
  }

  static Future<void> setShowTodayColumnHighlight(bool value) async {
    showTodayColumnHighlight = value;
    await saveToPreference();
  }

  static bool _readBool(StyleConfigPreferenceKey key, bool fallback) =>
      StyleConfigPreferenceFunctions.contains(key)
      ? StyleConfigPreferenceFunctions.getBool(key)
      : fallback;
}
