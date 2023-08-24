/*
Intro of the watermeter program.
Copyright 2023 SuperBart

This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.

*/

import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:package_info_plus/package_info_plus.dart';
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

  // Disable horizontal screen in phone.
  // See https://stackoverflow.com/questions/57755174/getting-screen-size-in-a-class-without-buildcontext-in-flutter
  final data = WidgetsBinding.instance.platformDispatcher.views.first;

  developer.log(
    "Shortest size: ${data.physicalSize.width} ${data.physicalSize.height} ${min(data.physicalSize.width, data.physicalSize.height) / data.devicePixelRatio}",
    name: "Watermeter",
  );

  if (min(data.physicalSize.width, data.physicalSize.height) /
          data.devicePixelRatio <
      480) {
    await SystemChrome.setPreferredOrientations(
      [
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ],
    );
  }

  // Loading cookiejar.
  repo_general.supportPath = await getApplicationSupportDirectory();
  preference.prefs = await SharedPreferences.getInstance();
  preference.packageInfo = await PackageInfo.fromPlatform();

  // Have user registered?
  bool isFirst = false;
  String username = preference.getString(preference.Preference.idsAccount);
  String password = preference.getString(preference.Preference.idsPassword);
  if (username.isNotEmpty && password.isNotEmpty) {
    try {
      await IDSSession().checkAndLogin(
        target:
            "https://ehall.xidian.edu.cn/login?service=https://ehall.xidian.edu.cn/new/index.html",
      );
    } catch (e, s) {
      developer.log(
        "Offline mode activated! Because of the following error: ",
        name: "Watermeter",
      );
      developer.log(
        "$e\nThe stack of the error is: $s",
        name: "Watermeter",
      );
      offline = true;
    }
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
  void initState() {
    super.initState();
    if (widget.isFirst) {
      IDSSession().dio.get("https://www.xidian.edu.cn");
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeController>(
      builder: (c) => MaterialApp(
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('zh', ''),
        ],
        navigatorKey: alice.getNavigatorKey(),
        title: Platform.isIOS || Platform.isMacOS ? "XDYou" : 'Traintime PDA',
        theme: c.apptheme,
        home: DefaultTextStyle.merge(
          style: const TextStyle(textBaseline: TextBaseline.ideographic),
          child: widget.isFirst ? const LoginWindow() : const HomePage(),
        ),
      ),
    );
  }
}
