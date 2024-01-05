// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

// Intro of the watermeter program.

import 'dart:developer' as developer;
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:watermeter/controller/theme_controller.dart';
import 'package:watermeter/repository/message_session.dart' as message;
import 'package:watermeter/repository/network_session.dart' as repo_general;
import 'package:watermeter/repository/network_session.dart';
import 'package:watermeter/repository/preference.dart' as preference;
import 'package:watermeter/page/homepage/home.dart';
import 'package:watermeter/page/login/login_window.dart';
import 'dart:developer' as developer;
import 'package:get/get.dart';
import 'package:watermeter/repository/xidian_ids/ids_session.dart';
import 'package:watermeter/themes/demo_blue.dart';
import 'package:home_widget/home_widget.dart';
import 'package:work_manager/work_manager.dart';

void main() async {
  developer.log(
    "Watermeter is written by BenderBlog Rodriguez and contributors.",
    name: "Watermeter",
  );

  // Make sure the library is initialized.
  WidgetsFlutterBinding.ensureInitialized();

  // Init the homepage widget data.
  Workmanager().initialize(callbackDispatcher, isInDebugMode: kDebugMode);

  // Disable horizontal screen in phone.
  // See https://stackoverflow.com/questions/57755174/getting-screen-size-in-a-class-without-buildcontext-in-flutter
  final data = WidgetsBinding.instance.platformDispatcher.views.first;

  developer.log(
    "Shortest size: ${data.physicalSize.width} ${data.physicalSize.height} "
    "${min(data.physicalSize.width, data.physicalSize.height) / data.devicePixelRatio}",
    name: "Watermeter",
  );

  if (min(data.physicalSize.width, data.physicalSize.height) /
          data.devicePixelRatio <
      480) {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  // Loading cookiejar.
  repo_general.supportPath = await getApplicationSupportDirectory();
  preference.prefs = await SharedPreferences.getInstance();
  preference.packageInfo = await PackageInfo.fromPlatform();

  // Get message of the app.
  message.checkMessage();

  // Have user registered?
  String username = preference.getString(preference.Preference.idsAccount);
  String password = preference.getString(preference.Preference.idsPassword);
  bool isFirst = username.isEmpty || password.isEmpty;

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
    //TODO replace YOUR_GROUP_ID with the proper one
    HomeWidget.setAppGroupId('YOUR_GROUP_ID');
    HomeWidget.registerBackgroundCallback(backgroundCallback);

    if (widget.isFirst) {
      loginState = IDSLoginState.manual;
      IDSSession().dio.get("https://www.xidian.edu.cn");
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _checkForWidgetLaunch();
    HomeWidget.widgetClicked.listen(_launchedFromWidget);
  }

  void _checkForWidgetLaunch() {
    HomeWidget.initiallyLaunchedFromHomeWidget().then(_launchedFromWidget);
  }

  void _launchedFromWidget(Uri? uri) {
    if (uri != null) {
      //TODO do work when start app from home widgets
      print(uri);
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
        theme: demoBlue,
        darkTheme: demoBlueDark,
        themeMode: c.colorState,
        home: DefaultTextStyle.merge(
          style: const TextStyle(textBaseline: TextBaseline.ideographic),
          child: widget.isFirst ? const LoginWindow() : const HomePage(),
        ),
      ),
    );
  }
}
