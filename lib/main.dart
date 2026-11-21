// Copyright 2026 Hazuki Keatsu
// SPDX-License-Identifier: MPL-2.0

import 'dart:async';

import 'package:catcher_2/catcher_2.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:signals/signals_flutter.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'package:watermeter/core/interfaces/logger_interface.dart';
import 'package:watermeter/core/interfaces/theme_store_interface.dart';
import 'package:watermeter/core/logging/talker_app_logger.dart';
import 'package:watermeter/core/logging/talker_report_handler.dart';
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
  final t = LocaleSettings.instance.getTranslations(LocaleSettings.currentLocale);

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
  runApp(
    TranslationProvider(
      child: MultiProvider(
        providers: [
          Provider<LoggerInterface>.value(value: logger),
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

  // This widget is the root of your application.
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

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: .center,
          children: [
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            ThemeSettingsCard(),
          ],
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
