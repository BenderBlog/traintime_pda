// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:signals/signals.dart';
import 'package:watermeter/generated/translations.g.dart';
import 'package:watermeter/repository/localization.dart';
import 'package:watermeter/repository/logger.dart';
import 'package:watermeter/repository/preference.dart' as preference;
import 'package:watermeter/themes/color_seed.dart';

class ThemeController {
  static final ThemeController i = ThemeController._();

  ThemeController._() {
    updateTheme();
  }

  final colorStateSignal = signal(ThemeMode.system);
  final localeSignal = signal(const Locale("zh", "CN"));
  final colorSignal = signal<List<FlexSchemeColor>>([pdaColorScheme.first]);

  /// The locale the user picked, or [Localization.undefined] for follow-system.
  final savedLocale = signal<Localization>(Localization.undefined);

  void updateTheme() {
    log.info("[ThemeController] Changing color...");
    int index = preference.getInt(preference.Preference.color);
    colorSignal.value = pdaColorScheme.sublist(index * 2, index * 2 + 1);

    log.info("[ThemeController] Changing brightness...");
    colorStateSignal.value =
        demoBlueModeMap[preference.getInt(preference.Preference.brightness)]!;

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
