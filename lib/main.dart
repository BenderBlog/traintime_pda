// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

// Intro of the watermeter program.

import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:catcher_2/catcher_2.dart';
import 'package:chinese_font_library/chinese_font_library.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:watermeter/repository/logger.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:watermeter/controller/theme_controller.dart';
import 'package:watermeter/repository/network_session.dart' as repo_general;
import 'package:watermeter/repository/preference.dart' as preference;
import 'package:watermeter/page/homepage/home.dart';
import 'package:watermeter/page/login/login_window.dart';
import 'package:get/get.dart';
import 'package:watermeter/repository/xidian_ids/ids_session.dart';
import 'package:watermeter/themes/color_seed.dart';
import 'package:home_widget/home_widget.dart';

void main() async {
  // Make sure the library is initialized.
  WidgetsFlutterBinding.ensureInitialized();

  log.info(
    "Traintime PDA Codebase is written by BenderBlog Rodriguez and contributors",
  );

  // Init the homepage widget data.
  // Register to receive BackgroundFetch events after app is terminated.
  // Requires {stopOnTerminate: false, enableHeadless: true}
  // Disable horizontal screen in phone.
  // See https://stackoverflow.com/questions/57755174/getting-screen-size-in-a-class-without-buildcontext-in-flutter
  final data = WidgetsBinding.instance.platformDispatcher.views.first;

  log.info(
    "Shortest size: ${data.physicalSize.width} ${data.physicalSize.height} "
    "${min(data.physicalSize.width, data.physicalSize.height) / data.devicePixelRatio}",
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

  // Have user registered?
  String username = preference.getString(preference.Preference.idsAccount);
  String password = preference.getString(preference.Preference.idsPassword);
  bool isFirst = username.isEmpty || password.isEmpty;
  log.info(
    "isFirstLogin: $isFirst",
  );

  Catcher2(
    rootWidget: MyApp(isFirst: isFirst),
    debugConfig: preference.catcherOptions,
    releaseConfig: preference.catcherOptions,
    navigatorKey: preference.debuggerKey,
  );
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
    if (Platform.isIOS) HomeWidget.setAppGroupId(preference.appId);
    //HomeWidget.registerInteractivityCallback(backgroundCallback);

    if (widget.isFirst) {
      loginState = IDSLoginState.manual;
      IDSSession().dio.get("https://www.xidian.edu.cn");
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeController>(
      builder: (c) => MaterialApp(
        localizationsDelegates: [
          FlutterI18nDelegate(
            translationLoader: FileTranslationLoader(
              fallbackFile: "zh_CN",
              useCountryCode: true,
              forcedLocale: c.locale,
            ),
            missingTranslationHandler: (key, locale) {
              log.info(
                "--- Missing Key: $key, "
                "languageCode: ${locale?.languageCode ?? "unknown"}",
              );
            },
          ),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('zh', 'CN'),
          Locale('zh', 'TW'),
        ],
        debugShowCheckedModeBanner: false,
        scrollBehavior: MyCustomScrollBehavior(),
        navigatorKey: preference.debuggerKey,
        title: Platform.isIOS || Platform.isMacOS ? "XDYou" : 'Traintime PDA',
        theme: FlexThemeData.light(
          scheme: c.color,
          subThemesData: const FlexSubThemesData(
            interactionEffects: true,
            tintedDisabledControls: true,
            useM2StyleDividerInM3: true,
            inputDecoratorIsFilled: true,
            inputDecoratorBorderType: FlexInputBorderType.outline,
            alignedDropdown: true,
            navigationRailUseIndicator: true,
            navigationRailLabelType: NavigationRailLabelType.all,
          ),
          visualDensity: FlexColorScheme.comfortablePlatformDensity,
          cupertinoOverrideTheme:
              const CupertinoThemeData(applyThemeToAll: true),
        ).useSystemChineseFont(Brightness.light),
        darkTheme: FlexThemeData.dark(
          scheme: c.color,
          subThemesData: const FlexSubThemesData(
            interactionEffects: true,
            tintedDisabledControls: true,
            blendOnColors: true,
            useM2StyleDividerInM3: true,
            inputDecoratorIsFilled: true,
            inputDecoratorBorderType: FlexInputBorderType.outline,
            alignedDropdown: true,
            navigationRailUseIndicator: true,
            navigationRailLabelType: NavigationRailLabelType.all,
          ),
          visualDensity: FlexColorScheme.comfortablePlatformDensity,
          cupertinoOverrideTheme:
              const CupertinoThemeData(applyThemeToAll: true),
        ).useSystemChineseFont(Brightness.dark),
        themeMode: c.colorState,
        home: DefaultTextStyle.merge(
          style: const TextStyle(textBaseline: TextBaseline.ideographic),
          child: widget.isFirst ? const LoginWindow() : const HomePage(),
        ),
        builder: (context, widget) {
          Catcher2.addDefaultErrorWidget(
            showStacktrace: true,
            title: "未预期情况发生！",
            description: "An unexpected behaviour occured!",
            maxWidthForSmallMode: 150,
          );
          if (widget != null) return widget;
          throw StateError('widget is null');
        },
      ),
    );
  }
}

class MyCustomScrollBehavior extends MaterialScrollBehavior {
  // Override behavior methods and getters like dragDevices
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
      };
}
