// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:watermeter/repository/preference.dart' as preference;
import 'package:watermeter/themes/demo_blue.dart';
//import 'package:watermeter/themes/color_seed.dart';
//import 'package:watermeter/themes/demo_blue.dart';

class ThemeController extends GetxController {
  late ThemeMode colorState;

  @override
  void onInit() {
    super.onInit();
    onUpdate();
  }

  void onUpdate() {
    colorState =
        demoBlueModeMap[preference.getInt(preference.Preference.brightness)]!;
    update();
  }
}
