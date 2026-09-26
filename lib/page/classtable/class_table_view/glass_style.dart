// Copyright 2026 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

// How strongly each control's own background is blurred.

import 'package:watermeter/repository/preference.dart' as preference;

/// Blur strength of the frosted controls, in logical pixels.
///
/// Every control that sits over the table — the class cards, the time line, the date row, the week
/// bar and the status banner — blurs its own background; the wallpaper behind them stays sharp. One
/// value per control, because what looks right depends on what passes behind it: a card over the
/// wallpaper wants less than a bar that has cards sliding underneath.
class GlassStyleConfig {
  /// Whether the controls blur their backgrounds at all.
  ///
  /// Off leaves them as plain translucent panels: a matter of taste, and a way out on a device that
  /// cannot keep up with a tableful of backdrop filters.
  static bool enabled = true;

  /// Class cards.
  static double cardSigma = 12;

  /// The floating time line down the left edge.
  static double timeLineSigma = 12;

  /// The date row over the top of the table.
  static double dateRowSigma = 12;

  /// The week bar, docked or floating.
  static double weekBarSigma = 12;

  /// The inline loading/cache banner.
  static double bannerSigma = 12;

  /// Range the settings dialog offers.
  static const double minSigma = 0;
  static const double maxSigma = 40;

  static double _clamp(double value) =>
      value.clamp(minSigma, maxSigma).toDouble();

  static void loadFromPreference() {
    if (preference.contains(preference.Preference.classStyleGlassEnabled)) {
      enabled = preference.getBool(preference.Preference.classStyleGlassEnabled);
    }
    if (preference.contains(preference.Preference.classStyleGlassCardSigma)) {
      cardSigma = _clamp(
        preference.getDouble(preference.Preference.classStyleGlassCardSigma),
      );
    }
    if (preference.contains(
      preference.Preference.classStyleGlassTimeLineSigma,
    )) {
      timeLineSigma = _clamp(
        preference.getDouble(preference.Preference.classStyleGlassTimeLineSigma),
      );
    }
    if (preference.contains(preference.Preference.classStyleGlassDateRowSigma)) {
      dateRowSigma = _clamp(
        preference.getDouble(preference.Preference.classStyleGlassDateRowSigma),
      );
    }
    if (preference.contains(preference.Preference.classStyleGlassWeekBarSigma)) {
      weekBarSigma = _clamp(
        preference.getDouble(preference.Preference.classStyleGlassWeekBarSigma),
      );
    }
    if (preference.contains(preference.Preference.classStyleGlassBannerSigma)) {
      bannerSigma = _clamp(
        preference.getDouble(preference.Preference.classStyleGlassBannerSigma),
      );
    }
  }

  static Future<void> saveToPreference() async {
    await preference.setBool(
      preference.Preference.classStyleGlassEnabled,
      enabled,
    );
    await preference.setDouble(
      preference.Preference.classStyleGlassCardSigma,
      _clamp(cardSigma),
    );
    await preference.setDouble(
      preference.Preference.classStyleGlassTimeLineSigma,
      _clamp(timeLineSigma),
    );
    await preference.setDouble(
      preference.Preference.classStyleGlassDateRowSigma,
      _clamp(dateRowSigma),
    );
    await preference.setDouble(
      preference.Preference.classStyleGlassWeekBarSigma,
      _clamp(weekBarSigma),
    );
    await preference.setDouble(
      preference.Preference.classStyleGlassBannerSigma,
      _clamp(bannerSigma),
    );
  }
}
