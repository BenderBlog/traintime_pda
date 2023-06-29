/*
Intro of the watermeter program.
Copyright 2022 SuperBart

This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.

Please refer to ADDITIONAL TERMS APPLIED TO WATERMETER SOURCE CODE
if you want to use.
*/

import 'dart:io';
import 'dart:math';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:watermeter/controller/theme_controller.dart';
import 'package:watermeter/repository/general.dart';
import 'package:watermeter/model/user.dart';
import 'package:watermeter/page/home.dart';
import 'package:watermeter/page/login/login.dart';
import 'dart:developer' as developer;
import 'package:get/get.dart';
import 'package:watermeter/repository/xidian_ids/ehall_session.dart';
import 'package:home_widget/home_widget.dart';
import 'package:workmanager/workmanager.dart';

/// Used for Background Updates using Workmanager Plugin
@pragma("vm:entry-point")
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) {
    final now = DateTime.now();
    return Future.wait<bool?>([
      HomeWidget.saveWidgetData(
        'title',
        'Updated from Background',
      ),
      HomeWidget.saveWidgetData(
        'message',
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
      ),
      HomeWidget.updateWidget(
        name: 'HomeWidgetExampleProvider',
        iOSName: 'HomeWidgetExample',
      ),
    ]).then((value) {
      return !value.contains(false);
    });
  });
}

/// Called when Doing Background Work initiated from Widget
@pragma("vm:entry-point")
void backgroundCallback(Uri? data) async {
  print(data);

  if (data?.host == 'titleclicked') {
    final greetings = [
      'Hello',
      'Hallo',
      'Bonjour',
      'Hola',
      'Ciao',
      '哈洛',
      '안녕하세요',
      'xin chào'
    ];
    final selectedGreeting = greetings[Random().nextInt(greetings.length)];

    await HomeWidget.saveWidgetData<String>('title', selectedGreeting);
    await HomeWidget.updateWidget(
        name: 'HomeWidgetExampleProvider', iOSName: 'HomeWidgetExample');
  }
}

void main() async {
  developer.log(
    "Watermeter, by BenderBlog, with dragon power.",
    name: "Watermeter",
  );

  // Make sure the library is initialized.
  WidgetsFlutterBinding.ensureInitialized();

  // Init the widget data.
  Workmanager().initialize(callbackDispatcher, isInDebugMode: kDebugMode);

  // Loading cookiejar.
  Directory supportPath = await getApplicationSupportDirectory();
  SportCookieJar = PersistCookieJar(
      ignoreExpires: true, storage: FileStorage("${supportPath.path}/sport"));
  IDSCookieJar = PersistCookieJar(
      ignoreExpires: true, storage: FileStorage("${supportPath.path}/ids"));
  // Have user registered?
  bool isFirst = false;
  try {
    await initUser();
    await EhallSession().loginEhall(
        username: user["idsAccount"]!, password: user["idsPassword"]!);
  } on String {
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
