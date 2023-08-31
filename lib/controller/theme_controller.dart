// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'package:get/get.dart';
import 'package:flutter/material.dart';
//import 'package:watermeter/repository/preference.dart' as preference;
//import 'package:watermeter/themes/color_seed.dart';
import '../themes/demo_blue.dart';

class ThemeController extends GetxController {
  late ThemeData apptheme;
  late ThemeData appthemeDark;

  @override
  void onInit() {
    super.onInit();
    onUpdate();
  }

  void onUpdate() {
    /*
    if (preference.getInt(preference.Preference.color) == 0) {
    } else {
      apptheme = ThemeData(
        useMaterial3: true,
        colorSchemeSeed: ColorSeed
            .values[preference.getInt(preference.Preference.color)].color,
      );
    }*/
    apptheme = demo_blue;
    appthemeDark = demo_blue_dark; // 暗色主题
    update();
  }
}
