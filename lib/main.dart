// Copyright 2026 Hazuki Keatsu
// SPDX-License-Identifier: MPL-2.0

import 'dart:async';

import 'package:catcher_2/catcher_2.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:signals/signals_flutter.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'package:watermeter/core/interfaces/logger_interface.dart';
import 'package:watermeter/core/interfaces/language_store_interface.dart';
import 'package:watermeter/core/interfaces/theme_store_interface.dart';
import 'package:watermeter/core/logging/talker_app_logger.dart';
import 'package:watermeter/core/logging/talker_report_handler.dart';
import 'package:watermeter/core/languages/data/preference_language_store.dart';
import 'package:watermeter/core/languages/presentation/language_settings_card.dart';
import 'package:watermeter/core/preferences/shared_preference_store.dart';
import 'package:watermeter/core/themes/presentation/app_theme.dart';
import 'package:watermeter/core/themes/data/preference_theme_store.dart';
import 'package:watermeter/core/themes/presentation/theme_settings_card.dart';
import 'package:watermeter/generated/translations.g.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Init logger
  final logger = TalkerAppLogger(TalkerFlutter.init());

  // Init slang
  LocaleSettings.useDeviceLocaleSync();
  final t = LocaleSettings.instance.getTranslations(
    LocaleSettings.currentLocale,
  );

  // Init catcher_2
  Catcher2.addDefaultErrorWidget(
    showStacktrace: true,
    title: t.common.unexpectProblemTitle,
    description: t.common.unexpectProblemHint,
    maxWidthForSmallMode: 150,
  );
  final options = Catcher2Options(
    PageReportMode(showStackTrace: true),
    [
      EmailManualHandler(
        ["superbart_chen@qq.com"],
        emailTitle: "PDA 发生故障",
        emailHeader: "请作者尽快修复",
      ),
      ConsoleHandler(),
    ],
    localizationOptions: [
      LocalizationOptions.buildDefaultChineseOptions(),
      LocalizationOptions.buildDefaultEnglishOptions(),
    ],
    logger: PDACatcher2Logger(logger),
  );

  Catcher2(
    runAppFunction: () => unawaited(_startApp(logger)),
    debugConfig: options,
    profileConfig: options,
    releaseConfig: options,
    enableLogger: false,
  );
}

Future<void> _startApp(LoggerInterface logger) async {
  final themePreferences = await SharedPreferenceStore.forOwner('theme');
  final languagePreferences = await SharedPreferenceStore.forOwner('language');
  runApp(
    TranslationProvider(
      child: MultiProvider(
        providers: [
          Provider<LoggerInterface>.value(value: logger),
          Provider<LanguageStoreInterface>.value(
            value: PreferenceLanguageStore(languagePreferences),
            updateShouldNotify: (_, _) => false,
          ),
          Provider<ThemeStoreInterface>(
            create: (context) => PreferenceThemeStore(
              themePreferences,
              context.read<LoggerInterface>(),
            ),
            dispose: (_, store) => store.dispose(),
          ),
        ],
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeStore = context.watch<ThemeStoreInterface>();
    final locale = context.t.$meta.locale.flutterLocale;
    return SignalBuilder(
      builder: (context) {
        final settings = themeStore.settings.value;
        return MaterialApp(
          title: 'XDYou',
          locale: locale,
          supportedLocales: AppLocaleUtils.supportedLocales,
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          theme: AppTheme.light(settings),
          darkTheme: AppTheme.dark(settings),
          themeMode: AppTheme.mode(settings.brightness),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: TextScaler.linear(settings.fontScale)),
            child: child!,
          ),
          home: const MyHomePage(title: 'XDYou'),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 12.0),
        child: Center(
          child: Column(
            mainAxisAlignment: .center,
            children: [
              const Text('You have pushed the button this many times:'),
              Text(
                '$_counter',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              ThemeSettingsCard(),
              LanguageSettingsCard(),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
