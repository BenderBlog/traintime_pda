// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'dart:io';
import 'dart:ui';

import 'package:catcher_2/catcher_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:home_widget/home_widget.dart';
import 'package:signals/signals_flutter.dart';
import 'package:watermeter/controller/theme_controller.dart';
import 'package:watermeter/page/homepage/home.dart';
import 'package:watermeter/page/login/login_window.dart';
import 'package:watermeter/repository/logger.dart';
import 'package:watermeter/repository/preference.dart' as preference;
import 'package:watermeter/repository/xidian_ids/ids_session.dart';
import 'package:watermeter/themes/app_theme.dart';

class XDYouApp extends StatefulWidget {
  final bool isFirst;

  const XDYouApp({super.key, required this.isFirst});

  @override
  State<XDYouApp> createState() => _XDYouAppState();
}

class _XDYouAppState extends State<XDYouApp> {
  final ThemeController appTheme = ThemeController.i;

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
      if (!mounted) return;
      final screenWidth =
          PlatformDispatcher.instance.views.first.physicalSize.width /
          PlatformDispatcher.instance.views.first.devicePixelRatio;
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
    return SignalBuilder(
      builder: (context) {
        final color = appTheme.colorSignal.value;
        final themeMode = appTheme.colorStateSignal.value;
        final i18nDelegate = appTheme.i18nDelegateSignal.value;

        return MaterialApp(
          localizationsDelegates: [
            i18nDelegate,
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
          scrollBehavior: XDYouScrollBehavior(),
          navigatorKey: preference.debuggerKey,
          title: Platform.isIOS || Platform.isMacOS || Platform.isAndroid
              ? "XDYou"
              : 'Traintime PDA',
          theme: buildLightAppTheme(color.first),
          darkTheme: buildDarkAppTheme(color.last),
          themeMode: themeMode,
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
        );
      },
    );
  }
}

class XDYouScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.trackpad,
  };
}
