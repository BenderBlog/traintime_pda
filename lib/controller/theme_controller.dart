// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:watermeter/repository/logger.dart';
import 'package:watermeter/repository/preference.dart' as preference;
import 'package:watermeter/themes/color_seed.dart';
//import 'package:watermeter/themes/color_seed.dart';
//import 'package:watermeter/themes/demo_blue.dart';

class ThemeController extends GetxController {
  late ThemeMode colorState;
  late Locale locale;
  late FlexScheme color;

  @override
  void onInit() {
    super.onInit();
    onUpdate();
  }

  void onUpdate() {
    log.info("[ThemeController] Changing color...");
    color =
        ColorSeed.values[preference.getInt(preference.Preference.color)].color;

    log.info("[ThemeController] Changing brightness...");
    colorState =
        demoBlueModeMap[preference.getInt(preference.Preference.brightness)]!;
    log.info("[ThemeController] Changing locale...");
    String localization = preference.getString(
      preference.Preference.localization,
    );
    locale = Locale.fromSubtags(
      languageCode: localization.isNotEmpty ? localization : "und",
    );

    update();
  }
}
