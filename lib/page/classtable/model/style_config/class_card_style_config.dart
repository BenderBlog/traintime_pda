// Copyright 2026 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'style_config_preference_functions.dart';

/// Active and completed course-card appearance, with its preference persistence.
class ClassCardStyleConfig {
  static bool completedEnabled = false;
  static double completedSaturationFactor = 0.25;
  static double completedBrightnessFactor = 0.75;
  static double completedTextSaturationFactor = 0.75;
  static double completedBorderAlpha = 0.75;
  static double completedInnerAlpha = 0.62;
  static double activeBrightnessFactor = 1.0;
  static double activeBorderAlpha = 1.0;
  static double activeInnerAlpha = 0.78;

  static void loadFromPreference() {
    completedEnabled = _readBool(
      StyleConfigPreferenceKey.classStyleCompletedEnabled,
      completedEnabled,
    );
    activeBrightnessFactor = _readDouble(
      StyleConfigPreferenceKey.classStyleActiveBrightnessFactor,
      activeBrightnessFactor,
      0.5,
      1,
    );
    activeBorderAlpha = _readDouble(
      StyleConfigPreferenceKey.classStyleActiveBorderAlpha,
      activeBorderAlpha,
      0.1,
      1,
    );
    activeInnerAlpha = _readDouble(
      StyleConfigPreferenceKey.classStyleActiveInnerAlpha,
      activeInnerAlpha,
      0.1,
      1,
    );
    completedSaturationFactor = _readDouble(
      StyleConfigPreferenceKey.classStyleCompletedSaturationFactor,
      completedSaturationFactor,
      0.1,
      1,
    );
    completedBrightnessFactor = _readDouble(
      StyleConfigPreferenceKey.classStyleCompletedBrightnessFactor,
      completedBrightnessFactor,
      0.5,
      1,
    );
    completedTextSaturationFactor = _readDouble(
      StyleConfigPreferenceKey.classStyleCompletedTextSaturationFactor,
      completedTextSaturationFactor,
      0.1,
      1,
    );
    completedBorderAlpha = _readDouble(
      StyleConfigPreferenceKey.classStyleCompletedBorderAlpha,
      completedBorderAlpha,
      0.1,
      1,
    );
    completedInnerAlpha = _readDouble(
      StyleConfigPreferenceKey.classStyleCompletedInnerAlpha,
      completedInnerAlpha,
      0.1,
      1,
    );
  }

  static Future<void> saveToPreference() async {
    await StyleConfigPreferenceFunctions.setBool(
      StyleConfigPreferenceKey.classStyleCompletedEnabled,
      completedEnabled,
    );
    await _saveDouble(
      StyleConfigPreferenceKey.classStyleActiveBrightnessFactor,
      activeBrightnessFactor,
      0.5,
      1,
    );
    await _saveDouble(
      StyleConfigPreferenceKey.classStyleActiveBorderAlpha,
      activeBorderAlpha,
      0.1,
      1,
    );
    await _saveDouble(
      StyleConfigPreferenceKey.classStyleActiveInnerAlpha,
      activeInnerAlpha,
      0.1,
      1,
    );
    await _saveDouble(
      StyleConfigPreferenceKey.classStyleCompletedSaturationFactor,
      completedSaturationFactor,
      0.1,
      1,
    );
    await _saveDouble(
      StyleConfigPreferenceKey.classStyleCompletedBrightnessFactor,
      completedBrightnessFactor,
      0.5,
      1,
    );
    await _saveDouble(
      StyleConfigPreferenceKey.classStyleCompletedTextSaturationFactor,
      completedTextSaturationFactor,
      0.1,
      1,
    );
    await _saveDouble(
      StyleConfigPreferenceKey.classStyleCompletedBorderAlpha,
      completedBorderAlpha,
      0.1,
      1,
    );
    await _saveDouble(
      StyleConfigPreferenceKey.classStyleCompletedInnerAlpha,
      completedInnerAlpha,
      0.1,
      1,
    );
  }

  static bool _readBool(StyleConfigPreferenceKey key, bool fallback) =>
      StyleConfigPreferenceFunctions.contains(key)
      ? StyleConfigPreferenceFunctions.getBool(key)
      : fallback;

  static double _readDouble(
    StyleConfigPreferenceKey key,
    double fallback,
    double min,
    double max,
  ) => StyleConfigPreferenceFunctions.contains(key)
      ? StyleConfigPreferenceFunctions.getDouble(key).clamp(min, max).toDouble()
      : fallback;

  static Future<void> _saveDouble(
    StyleConfigPreferenceKey key,
    double value,
    double min,
    double max,
  ) => StyleConfigPreferenceFunctions.setDouble(
    key,
    value.clamp(min, max).toDouble(),
  );
}
