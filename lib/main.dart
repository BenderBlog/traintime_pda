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

import 'package:alice/alice.dart';
import 'package:cookie_jar/cookie_jar.dart';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:watermeter/page/widget.dart';
import 'package:watermeter/repository/general.dart';
import 'package:watermeter/model/user.dart';
import 'package:watermeter/page/home.dart';
import 'package:watermeter/page/login/login.dart';
import 'dart:developer' as developer;
import 'package:get/get.dart';

Alice alice = Alice(
    //showNotification: true,
    );

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

class MyApp extends StatefulWidget {
  final bool isFirst;
  const MyApp({super.key, required this.isFirst});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      navigatorKey: alice.getNavigatorKey(),
      title: 'WaterMeter Pre-Alpha',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed:
            ColorSeed.values[int.parse(user["color"] ?? "0")].color,
      ),
      home: widget.isFirst ? const LoginWindow() : const HomePage(),
    );
  }
}
