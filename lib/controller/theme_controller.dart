// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

// TODO: Add logic related to writing to preference.

import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:material_ui/material_ui.dart';
import 'package:watermeter/generated/translations.g.dart';
import 'package:watermeter/repository/localization.dart';
import 'package:signals/signals.dart';
import 'package:watermeter/repository/logger.dart';
import 'package:watermeter/repository/preference.dart' as preference;
import 'package:watermeter/themes/color_seed.dart';
import 'package:watermeter/themes/font_setting.dart';

class ThemeController {
  static final ThemeController i = ThemeController._();

  ThemeController._() {
    updateTheme();
  }

  final colorStateSignal = signal(ThemeMode.system);
  final localeSignal = signal(const Locale("zh", "CN"));
  final colorSignal = signal<List<FlexSchemeColor>>([pdaColorScheme.first]);
  final fontScaleSignal = signal<double>(defaultFontScale);
  final fontWeightSignal = signal<double>(defaultFontWeight);

  final savedLocale = signal<Localization>(Localization.undefined);

  void updateTheme() {
    log.info("[ThemeController] Changing color...");
    int index = preference.getInt(preference.Preference.color);
    colorSignal.value = pdaColorScheme.sublist(index * 2, index * 2 + 1);

    log.info("[ThemeController] Changing brightness...");
    colorStateSignal.value =
        brightnessModeList[preference.getInt(
          preference.Preference.brightness,
        )]!;
    log.info("[ThemeController] Changing font scale...");
    fontScaleSignal.value = preference.contains(preference.Preference.fontScale)
        ? preference
              .getDouble(preference.Preference.fontScale)
              .clamp(minFontScale, maxFontScale)
              .toDouble()
        : defaultFontScale;
    log.info("[ThemeController] Changing font weight...");
    fontWeightSignal.value =
        preference.contains(preference.Preference.fontWeight)
        ? preference
              .getDouble(preference.Preference.fontWeight)
              .clamp(minFontWeight, maxFontWeight)
              .toDouble()
        : defaultFontWeight;
    log.info("[ThemeController] Changing locale...");
    savedLocale.value = Localization.fromPreference();
    _applyLocale();
  }

  /// Call when the user picks a language. Updates UI immediately and persists
  /// asynchronously.
  Future<void> setLocale(Localization value) async {
    savedLocale.value = value;
    _applyLocale();
    await value.saveToPreference();
  }

  void _applyLocale() {
    final localization = savedLocale.value.resolved;
    log.info("[ThemeController] Locale to set ${localization.string}");
    localeSignal.value = localization.flutterLocale!;
    LocaleSettings.setLocaleSync(localization.appLocale);
  }
}
