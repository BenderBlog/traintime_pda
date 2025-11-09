// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

// Intro of the watermeter program.

import 'dart:io';
import 'dart:ui';

import 'package:catcher_2/catcher_2.dart';
import 'package:chinese_font_library/chinese_font_library.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/util/legacy_to_async_migration_util.dart';
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
import 'package:home_widget/home_widget.dart';
import 'package:watermeter/repository/notification/course_reminder_service.dart';

void main() async {
  // Make sure the library is initialized.
  WidgetsFlutterBinding.ensureInitialized();

  log.info(
    "Traintime PDA Codebase is written by BenderBlog Rodriguez and contributors",
  );

  // Load cookiejar and other stuff
  repo_general.supportPath = await getApplicationSupportDirectory();

  // Load shared preference. Per the migration guide
  // https://pub.dev/packages/shared_preferences#migrating-from-sharedpreferences-to-sharedpreferencesasyncwithcache
  const SharedPreferencesOptions sharedPreferencesOptions =
      SharedPreferencesOptions();
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  if (prefs.getKeys().isNotEmpty) {
    await migrateLegacySharedPreferencesToSharedPreferencesAsyncIfNecessary(
      legacySharedPreferencesInstance: prefs,
      sharedPreferencesAsyncOptions: sharedPreferencesOptions,
      migrationCompletedKey: 'pdaMigrationCompleted',
    );
  }
  preference.prefs = await SharedPreferencesWithCache.create(
    cacheOptions: const SharedPreferencesWithCacheOptions(),
  );

  // Initialize notification service
  await CourseReminderService().initialize();
  log.info("Notification service initialized.");

  // Load package info.
  preference.packageInfo = await PackageInfo.fromPlatform();

  // Have user registered?
  String username = preference.getString(preference.Preference.idsAccount);
  String password = preference.getString(preference.Preference.idsPassword);
  bool isFirst = username.isEmpty || password.isEmpty;
  log.info("isFirstLogin: $isFirst");

  Catcher2(
    rootWidget: MyApp(isFirst: isFirst),
    debugConfig: preference.catcherOptions,
    releaseConfig: preference.catcherOptions,
    navigatorKey: preference.debuggerKey,
  );

  // Handle app launch from notification
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    await CourseReminderService().handleAppLaunchFromNotification();
  });
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
      try {
        IDSSession().dio.get("https://www.xidian.edu.cn");
        // Should the permission request be sent on iOS
        // ignore: empty_catches
      } catch (e) {}
    }

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      double screenWidth = MediaQuery.of(context).size.width;
      log.info("Screen width: $screenWidth.");
      if (screenWidth < 480) {
        log.info("Vertical vision mode disabled!");
        await SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
        ]);
      }
    });
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
                "[Locale] Missing Key: $key, "
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
          Locale('en', 'US'),
        ],
        debugShowCheckedModeBanner: false,
        scrollBehavior: MyCustomScrollBehavior(),
        navigatorKey: preference.debuggerKey,
        title: Platform.isIOS || Platform.isMacOS || Platform.isAndroid
            ? "XDYou"
            : 'Traintime PDA',
        theme: FlexThemeData.light(
          colors: c.color.first,
          usedColors: 1,
          surfaceMode: FlexSurfaceMode.highSurfaceLowScaffold,
          blendLevel: 2,
          tabBarStyle: FlexTabBarStyle.forAppBar,
          subThemesData: const FlexSubThemesData(
            interactionEffects: true,
            tintedDisabledControls: true,
            blendOnLevel: 8,
            useM2StyleDividerInM3: true,
            defaultRadius: 12.0,
            elevatedButtonSchemeColor: SchemeColor.onPrimaryContainer,
            elevatedButtonSecondarySchemeColor: SchemeColor.primaryContainer,
            outlinedButtonOutlineSchemeColor: SchemeColor.primary,
            toggleButtonsBorderSchemeColor: SchemeColor.primary,
            segmentedButtonSchemeColor: SchemeColor.primary,
            segmentedButtonBorderSchemeColor: SchemeColor.primary,
            unselectedToggleIsColored: true,
            sliderValueTinted: true,
            inputDecoratorSchemeColor: SchemeColor.primary,
            inputDecoratorIsFilled: true,
            inputDecoratorContentPadding: EdgeInsetsDirectional.fromSTEB(
              12,
              16,
              12,
              12,
            ),
            inputDecoratorBackgroundAlpha: 7,
            inputDecoratorBorderSchemeColor: SchemeColor.primary,
            inputDecoratorBorderType: FlexInputBorderType.outline,
            inputDecoratorRadius: 8.0,
            inputDecoratorUnfocusedBorderIsColored: true,
            inputDecoratorBorderWidth: 1.0,
            inputDecoratorFocusedBorderWidth: 2.0,
            inputDecoratorPrefixIconSchemeColor:
                SchemeColor.onPrimaryFixedVariant,
            inputDecoratorSuffixIconSchemeColor: SchemeColor.primary,
            fabUseShape: true,
            fabAlwaysCircular: true,
            fabSchemeColor: SchemeColor.secondary,
            popupMenuRadius: 8.0,
            popupMenuElevation: 3.0,
            alignedDropdown: true,
            dialogBackgroundSchemeColor: SchemeColor.secondaryContainer,
            drawerIndicatorRadius: 12.0,
            drawerIndicatorSchemeColor: SchemeColor.primary,
            bottomNavigationBarMutedUnselectedLabel: false,
            bottomNavigationBarMutedUnselectedIcon: false,
            menuRadius: 8.0,
            menuElevation: 3.0,
            menuBarRadius: 0.0,
            menuBarElevation: 2.0,
            menuBarShadowColor: Color(0x00000000),
            searchBarElevation: 1.0,
            searchViewElevation: 1.0,
            searchUseGlobalShape: true,
            navigationBarSelectedLabelSchemeColor: SchemeColor.primary,
            navigationBarSelectedIconSchemeColor: SchemeColor.onPrimary,
            navigationBarIndicatorSchemeColor: SchemeColor.primary,
            navigationBarIndicatorRadius: 12.0,
            navigationRailSelectedLabelSchemeColor: SchemeColor.primary,
            navigationRailSelectedIconSchemeColor: SchemeColor.onPrimary,
            navigationRailUseIndicator: true,
            navigationRailIndicatorSchemeColor: SchemeColor.primary,
            navigationRailIndicatorOpacity: 1.00,
            navigationRailIndicatorRadius: 12.0,
            navigationRailBackgroundSchemeColor: SchemeColor.surface,
            navigationRailLabelType: NavigationRailLabelType.all,
          ),
          keyColors: const FlexKeyColors(keepPrimary: true),
          tones: FlexSchemeVariant.jolly.tones(Brightness.light),
          visualDensity: FlexColorScheme.comfortablePlatformDensity,
          cupertinoOverrideTheme: const CupertinoThemeData(
            applyThemeToAll: true,
          ),
        ).useSystemChineseFont(Brightness.light),
        darkTheme: FlexThemeData.dark(
          colors: c.color.last,
          usedColors: 1,
          surfaceMode: FlexSurfaceMode.highScaffoldLowSurface,
          blendLevel: 2,
          tabBarStyle: FlexTabBarStyle.forAppBar,
          subThemesData: const FlexSubThemesData(
            interactionEffects: true,
            tintedDisabledControls: true,
            blendOnLevel: 10,
            blendOnColors: true,
            useM2StyleDividerInM3: true,
            defaultRadius: 12.0,
            elevatedButtonSchemeColor: SchemeColor.onPrimaryContainer,
            elevatedButtonSecondarySchemeColor: SchemeColor.primaryContainer,
            outlinedButtonOutlineSchemeColor: SchemeColor.primary,
            toggleButtonsBorderSchemeColor: SchemeColor.primary,
            segmentedButtonSchemeColor: SchemeColor.primary,
            segmentedButtonBorderSchemeColor: SchemeColor.primary,
            unselectedToggleIsColored: true,
            sliderValueTinted: true,
            inputDecoratorSchemeColor: SchemeColor.primary,
            inputDecoratorIsFilled: true,
            inputDecoratorContentPadding: EdgeInsetsDirectional.fromSTEB(
              12,
              16,
              12,
              12,
            ),
            inputDecoratorBackgroundAlpha: 40,
            inputDecoratorBorderSchemeColor: SchemeColor.primary,
            inputDecoratorBorderType: FlexInputBorderType.outline,
            inputDecoratorRadius: 8.0,
            inputDecoratorUnfocusedBorderIsColored: true,
            inputDecoratorBorderWidth: 1.0,
            inputDecoratorFocusedBorderWidth: 2.0,
            inputDecoratorPrefixIconSchemeColor: SchemeColor.primaryFixed,
            inputDecoratorSuffixIconSchemeColor: SchemeColor.primary,
            fabUseShape: true,
            fabAlwaysCircular: true,
            fabSchemeColor: SchemeColor.secondary,
            popupMenuRadius: 8.0,
            popupMenuElevation: 3.0,
            alignedDropdown: true,
            drawerIndicatorRadius: 12.0,
            drawerIndicatorSchemeColor: SchemeColor.primary,
            bottomNavigationBarMutedUnselectedLabel: false,
            bottomNavigationBarMutedUnselectedIcon: false,
            menuRadius: 8.0,
            menuElevation: 3.0,
            menuBarRadius: 0.0,
            menuBarElevation: 2.0,
            menuBarShadowColor: Color(0x00000000),
            searchBarElevation: 1.0,
            searchViewElevation: 1.0,
            searchUseGlobalShape: true,
            navigationBarSelectedLabelSchemeColor: SchemeColor.primary,
            navigationBarSelectedIconSchemeColor: SchemeColor.onPrimary,
            navigationBarIndicatorSchemeColor: SchemeColor.primary,
            navigationBarIndicatorRadius: 12.0,
            navigationRailSelectedLabelSchemeColor: SchemeColor.primary,
            navigationRailSelectedIconSchemeColor: SchemeColor.onPrimary,
            navigationRailUseIndicator: true,
            navigationRailIndicatorSchemeColor: SchemeColor.primary,
            navigationRailIndicatorOpacity: 1.00,
            navigationRailIndicatorRadius: 12.0,
            navigationRailBackgroundSchemeColor: SchemeColor.surface,
            navigationRailLabelType: NavigationRailLabelType.all,
          ),
          keyColors: const FlexKeyColors(),
          tones: FlexSchemeVariant.jolly.tones(Brightness.dark),
          visualDensity: FlexColorScheme.comfortablePlatformDensity,
          cupertinoOverrideTheme: const CupertinoThemeData(
            applyThemeToAll: true,
          ),
        ).useSystemChineseFont(Brightness.dark),
        themeMode: c.colorState,
        home: DefaultTextStyle.merge(
          style: const TextStyle(textBaseline: TextBaseline.ideographic),
          child: widget.isFirst ? const LoginWindow() : const HomePage(),
        ),
        builder: (context, widget) {
          Catcher2.addDefaultErrorWidget(
            showStacktrace: true,
            title: "Unexpected problem:P",
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
