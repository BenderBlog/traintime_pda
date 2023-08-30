// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:watermeter/page/widget.dart';
import 'package:watermeter/repository/preference.dart' as preference;
import '../themes/demo_blue.dart';

class ThemeController extends GetxController {
  late ThemeData apptheme;

  @override
  void onInit() {
    super.onInit();
    onUpdate();
  }

  void onUpdate() {
    apptheme = ThemeData(
      useMaterial3: true,
      colorSchemeSeed: ColorSeed
          .values[preference.getInt(preference.Preference.color)].color,
    );
    apptheme = demo_blue;
    update();
  }
}
