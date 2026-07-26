// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'dart:io';

import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:signals/signals.dart';
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

  void updateTheme() {
    log.info("[ThemeController] Changing color...");
    int index = preference.getInt(preference.Preference.color);
    colorSignal.value = pdaColorScheme.sublist(index * 2, index * 2 + 1);

    log.info("[ThemeController] Changing brightness...");
    colorStateSignal.value =
        demoBlueModeMap[preference.getInt(preference.Preference.brightness)]!;
    log.info("[ThemeController] Changing locale...");
    String localization = preference.getString(
      preference.Preference.localization,
    );
    if (localization.isEmpty) {
      String systemLocale = Platform.localeName;
      log.info("[ThemeController] System lang $systemLocale");
      if (systemLocale.contains("zh")) {
        if (Platform.isIOS || Platform.isMacOS) {
          if (systemLocale.contains("Hans")) {
            localization = "zh_CN";
          } else {
            localization = "zh_TW";
          }
        } else {
          if (systemLocale.contains("CN") || systemLocale.contains("SG")) {
            localization = "zh_CN";
          } else {
            localization = "zh_TW";
          }
        }
      } else {
        localization = "en_US";
      }
    }
    log.info("[ThemeController] Locale to set $localization");
    final parts = localization.split("_");
    localeSignal.value = parts.length == 2
        ? Locale(parts[0], parts[1])
        : Locale.fromSubtags(languageCode: localization);
  }
}
