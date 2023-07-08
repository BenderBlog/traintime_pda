/*
Intro of the watermeter program.
Copyright 2022 SuperBart

This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.

*/

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:watermeter/controller/theme_controller.dart';
import 'package:watermeter/repository/network_session.dart' as repo_general;
import 'package:watermeter/repository/network_session.dart';
import 'package:watermeter/repository/preference.dart' as preference;
import 'package:watermeter/page/home.dart';
import 'package:watermeter/page/login/login.dart';
import 'dart:developer' as developer;
import 'package:get/get.dart';
import 'package:watermeter/repository/xidian_ids/ids_session.dart';

void main() async {
  developer.log(
    "Watermeter, by BenderBlog, with dragon power.",
    name: "Watermeter",
  );
  // Make sure the library is initialized.
  WidgetsFlutterBinding.ensureInitialized();

  // Loading cookiejar.
  repo_general.supportPath = await getApplicationSupportDirectory();
  preference.prefs = await SharedPreferences.getInstance();
  // Have user registered?
  bool isFirst = false;
  String username = preference.getString(preference.Preference.idsAccount);
  String password = preference.getString(preference.Preference.idsPassword);
  if (username.isNotEmpty && password.isNotEmpty) {
    await IDSSession().checkAndLogin(
      target:
          "https://ehall.xidian.edu.cn/login?service=https://ehall.xidian.edu.cn/new/index.html",
    );
  } else {
    isFirst = true;
  }
  developer.log(
    "Registered in status: ${!isFirst}",
    name: "Watermeter",
  );

  runApp(MyApp(isFirst: isFirst));
}

class MyApp extends StatefulWidget {
  final bool isFirst;
  const MyApp({super.key, required this.isFirst});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeController appTheme = Get.put(ThemeController());

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeController>(
      builder: (c) => MaterialApp(
        navigatorKey: alice.getNavigatorKey(),
        title: 'WaterMeter Pre-Alpha',
        theme: c.apptheme,
        home: widget.isFirst ? const LoginWindow() : const HomePage(),
      ),
    );
  }
}
