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
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:watermeter/communicate/general.dart';
import 'package:watermeter/ui/login.dart';
import 'package:watermeter/ui/home.dart';
import 'package:watermeter/dataStruct/user.dart';

import 'package:watermeter/communicate/IDS/ids.dart';


void main() async {
  // Make sure the library is initialized.
  WidgetsFlutterBinding.ensureInitialized();
  // Loading cookiejar.
  Directory supportPath = await getApplicationSupportDirectory();
  SportCookieJar = PersistCookieJar(storage: FileStorage("${supportPath.path}/sport"));
  IDSCookieJar = PersistCookieJar(storage: FileStorage("${supportPath.path}/ids"));
  // Have user registered?
  bool isFirst = false;
  try {
    await initUser();
  } on String {
    isFirst = true;
  }
  if (kDebugMode) {
    print("isFirst = $isFirst");
  }
  if (!isFirst) {
    // For test purpose.
    try {
      await ids.isLoggedIn();
    } on String {
      print("没登录，呜哇");
      try {
        await ids.login(username: user["idsAccount"]!, password: user["idsPassword"]!, target: "http://ehall.xidian.edu.cn/login?service=http://ehall.xidian.edu.cn/new/index.html");
      } on DioError catch (e) {
        print(e.response);
      }
    } finally {
      print("希望这样登录了吧");
    }
  }
  runApp(MyApp(isFirst: isFirst));
}


class MyApp extends StatelessWidget {
  final bool isFirst;
  const MyApp({Key? key, required this.isFirst}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WaterMeter Pre-Alpha',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: isFirst ? const LoginWindow() : const HomePage(),
    );
  }
}
