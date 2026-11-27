// Copyright 2026 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'style_config_preference_functions.dart';

/// Configuration and persistence for frosted surfaces in the timetable.
class GlassStyleConfig {
  static bool enabled = true;
  static double cardSigma = 12;
  static double timeLineSigma = 12;
  static double dateRowSigma = 12;
  static double weekBarSigma = 12;
  static double bannerSigma = 12;
  static double appBarSigma = 12;

  static const double minSigma = 0;
  static const double maxSigma = 40;

  static void loadFromPreference() {
    enabled = _readBool(
      StyleConfigPreferenceKey.classStyleGlassEnabled,
      enabled,
    );
    cardSigma = _readDouble(
      StyleConfigPreferenceKey.classStyleGlassCardSigma,
      cardSigma,
    );
    timeLineSigma = _readDouble(
      StyleConfigPreferenceKey.classStyleGlassTimeLineSigma,
      timeLineSigma,
    );
    dateRowSigma = _readDouble(
      StyleConfigPreferenceKey.classStyleGlassDateRowSigma,
      dateRowSigma,
    );
    weekBarSigma = _readDouble(
      StyleConfigPreferenceKey.classStyleGlassWeekBarSigma,
      weekBarSigma,
    );
    bannerSigma = _readDouble(
      StyleConfigPreferenceKey.classStyleGlassBannerSigma,
      bannerSigma,
    );
    appBarSigma = _readDouble(
      StyleConfigPreferenceKey.classStyleGlassAppBarSigma,
      appBarSigma,
    );
  }

  static Future<void> saveToPreference() async {
    await StyleConfigPreferenceFunctions.setBool(
      StyleConfigPreferenceKey.classStyleGlassEnabled,
      enabled,
    );
    await _saveDouble(
      StyleConfigPreferenceKey.classStyleGlassCardSigma,
      cardSigma,
    );
    await _saveDouble(
      StyleConfigPreferenceKey.classStyleGlassTimeLineSigma,
      timeLineSigma,
    );
    await _saveDouble(
      StyleConfigPreferenceKey.classStyleGlassDateRowSigma,
      dateRowSigma,
    );
    await _saveDouble(
      StyleConfigPreferenceKey.classStyleGlassWeekBarSigma,
      weekBarSigma,
    );
    await _saveDouble(
      StyleConfigPreferenceKey.classStyleGlassBannerSigma,
      bannerSigma,
    );
    await _saveDouble(
      StyleConfigPreferenceKey.classStyleGlassAppBarSigma,
      appBarSigma,
    );
  }

  static Future<void> setEnabled(bool value) async {
    enabled = value;
    await saveToPreference();
  }

  static bool _readBool(StyleConfigPreferenceKey key, bool fallback) =>
      StyleConfigPreferenceFunctions.contains(key)
      ? StyleConfigPreferenceFunctions.getBool(key)
      : fallback;

  static double _readDouble(StyleConfigPreferenceKey key, double fallback) =>
      StyleConfigPreferenceFunctions.contains(key)
      ? StyleConfigPreferenceFunctions.getDouble(
          key,
        ).clamp(minSigma, maxSigma).toDouble()
      : fallback;

  static Future<void> _saveDouble(StyleConfigPreferenceKey key, double value) =>
      StyleConfigPreferenceFunctions.setDouble(
        key,
        value.clamp(minSigma, maxSigma).toDouble(),
      );
}
