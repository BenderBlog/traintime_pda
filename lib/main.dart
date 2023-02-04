/*
Intro of the watermeter program.
Copyright 2022 SuperBart

This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.

Please refer to ADDITIONAL TERMS APPLIED TO WATERMETER SOURCE CODE
if you want to use.
*/

import 'dart:async';
import 'dart:io';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:watermeter/model/xidian_ids/classtable.dart';
import 'package:watermeter/repository/general.dart';
import 'package:watermeter/model/user.dart';
import 'package:watermeter/page/home.dart';
import 'package:watermeter/page/login.dart';
import 'package:watermeter/page/classtable/classtable.dart';
import 'package:watermeter/page/score/score.dart';
import 'package:watermeter/page/setting/setting.dart';
import 'package:watermeter/page/sport/sport_window.dart';
import 'package:watermeter/page/xidian_directory/xidian_directory.dart';
import 'dart:developer' as developer;
import 'package:get/get.dart';
import 'package:watermeter/repository/xidian_ids/classtable_session.dart';

void main() async {
  developer.log(
    "Watermeter, by BenderBlog, with dragon power.",
    name: "Watermeter",
  );
  // Make sure the library is initialized.
  WidgetsFlutterBinding.ensureInitialized();
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
  } on String {
    isFirst = true;
  }
  developer.log(
    "Logged in status: ${!isFirst}",
    name: "Watermeter",
  );
  runApp(MyApp(isFirst: isFirst));
}

class MyApp extends StatelessWidget {
  final bool isFirst;

  const MyApp({Key? key, required this.isFirst}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'WaterMeter Pre-Alpha',
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.deepPurple,
      ),
      initialRoute: '/',
      getPages: [
        GetPage(name: '/', page: () => HomePage()),
        GetPage(name: '/login', page: () => const LoginWindow()),
        GetPage(name: '/sport', page: () => const SportWindow()),
        GetPage(name: '/score', page: () => const ScoreWindow()),
        GetPage(name: '/directory', page: () => const XidianDirWindow()),
        GetPage(name: '/setting', page: () => const SettingWindow()),
      ],
      home: isFirst ? const LoginWindow() : HomePage(),
    );
  }
}
