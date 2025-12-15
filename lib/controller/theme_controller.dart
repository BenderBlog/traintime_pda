// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'dart:io';

import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:get/get.dart';
import 'package:watermeter/repository/logger.dart';
import 'package:watermeter/repository/preference.dart' as preference;
import 'package:watermeter/themes/color_seed.dart';
//import 'package:watermeter/themes/color_seed.dart';
//import 'package:watermeter/themes/demo_blue.dart';

class ThemeController extends GetxController {
  late ThemeMode colorState;
  late Locale locale;
  late List<FlexSchemeColor> color;

  /// Cache FlutterI18nDelegate to avoid reload i18n files every time when build
  FlutterI18nDelegate? _i18nDelegate;
  Locale? _cachedLocale;

  /// Get the instance of FlutterI18nDelegate when locale change actually
  FlutterI18nDelegate getI18nDelegate() {
    if (_i18nDelegate == null || _cachedLocale != locale) {
      _cachedLocale = locale;
      _i18nDelegate = FlutterI18nDelegate(
        translationLoader: FileTranslationLoader(
          fallbackFile: "zh_CN",
          useCountryCode: true,
          forcedLocale: locale,
        ),
        missingTranslationHandler: (key, locale) {
          log.info(
            "[Locale] Missing Key: $key, "
            "languageCode: ${locale?.languageCode ?? "unknown"}",
          );
        },
      );
    }
    return _i18nDelegate!;
  }

  @override
  void onInit() {
    super.onInit();
    updateTheme();
  }

  void updateTheme() {
    log.info("[ThemeController] Changing color...");
    int index = preference.getInt(preference.Preference.color);
    color = pdaColorScheme.sublist(index * 2, index * 2 + 1);

    log.info("[ThemeController] Changing brightness...");
    colorState =
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
    locale = Locale.fromSubtags(languageCode: localization);

    update();
  }
}
