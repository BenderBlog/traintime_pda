// Copyright 2026 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

/// Preference keys used by timetable style configs. Names match the app's storage enum.
enum StyleConfigPreferenceKey {
  currentTimeIndicatorEnabled,
  currentTimeIndicatorShowTimeLabel,
  currentTimeIndicatorShowTodayColumnHighlight,
  classStyleActiveBrightnessFactor,
  classStyleActiveBorderAlpha,
  classStyleActiveInnerAlpha,
  classStyleCompletedSaturationFactor,
  classStyleCompletedBrightnessFactor,
  classStyleCompletedEnabled,
  classStyleCompletedTextSaturationFactor,
  classStyleCompletedBorderAlpha,
  classStyleCompletedInnerAlpha,
  classStyleGlassEnabled,
  classStyleGlassCardSigma,
  classStyleGlassTimeLineSigma,
  classStyleGlassDateRowSigma,
  classStyleGlassWeekBarSigma,
  classStyleGlassBannerSigma,
  classStyleGlassAppBarSigma,
  decorated,
  decoration,
  classTableBackgroundBlur,
  classTableWeekBarCollapsed,
}

typedef StyleBoolReader = bool Function(StyleConfigPreferenceKey key);
typedef StyleDoubleReader = double Function(StyleConfigPreferenceKey key);
typedef StyleBoolWriter =
    Future<void> Function(StyleConfigPreferenceKey key, bool value);
typedef StyleDoubleWriter =
    Future<void> Function(StyleConfigPreferenceKey key, double value);
typedef StyleContains = bool Function(StyleConfigPreferenceKey key);

/// Storage functions are injected at application startup so config logic is storage independent.
class StyleConfigPreferenceFunctions {
  StyleConfigPreferenceFunctions._();

  static late StyleBoolReader _getBool;
  static late StyleDoubleReader _getDouble;
  static late StyleBoolWriter _setBool;
  static late StyleDoubleWriter _setDouble;
  static late StyleContains _contains;

  static void install({
    required StyleBoolReader getBool,
    required StyleDoubleReader getDouble,
    required StyleBoolWriter setBool,
    required StyleDoubleWriter setDouble,
    required StyleContains contains,
  }) {
    _getBool = getBool;
    _getDouble = getDouble;
    _setBool = setBool;
    _setDouble = setDouble;
    _contains = contains;
  }

  static bool getBool(StyleConfigPreferenceKey key) => _getBool(key);
  static double getDouble(StyleConfigPreferenceKey key) => _getDouble(key);
  static Future<void> setBool(StyleConfigPreferenceKey key, bool value) =>
      _setBool(key, value);
  static Future<void> setDouble(StyleConfigPreferenceKey key, double value) =>
      _setDouble(key, value);
  static bool contains(StyleConfigPreferenceKey key) => _contains(key);
}
