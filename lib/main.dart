/*
Intro of the watermeter program.
Copyright 2022 SuperBart

This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.

Please refer to ADDITIONAL TERMS APPLIED TO WATERMETER SOURCE CODE
if you want to use.
*/

import 'package:flutter/material.dart';
import 'package:watermeter/ui/login.dart';
import 'package:watermeter/ui/home.dart';
import 'package:watermeter/dataStruct/user.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  bool isFirst = false;
  try {
    await initUser();
  } on String {
    isFirst = true;
  }
  print("isFirst = $isFirst");
  runApp(MyApp(isFirst: isFirst,));
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
