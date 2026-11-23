// Copyright 2026 Hazuki Keatsu
// SPDX-License-Identifier: MPL-2.0

import 'dart:async';

import 'package:catcher_2/catcher_2.dart';
import 'package:material_ui/material_ui.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:provider/provider.dart';
import 'package:signals/signals_flutter.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'package:watermeter/core/logging/logger_interface.dart';
import 'package:watermeter/integration/database/xdyou_database.dart';
import 'package:watermeter/core/languages/language_store_interface.dart';
import 'package:watermeter/core/themes/theme_store_interface.dart';
import 'package:watermeter/core/logging/talker_app_logger.dart';
import 'package:watermeter/core/logging/talker_report_handler.dart';
import 'package:watermeter/core/languages/data/preference_language_store.dart';
import 'package:watermeter/core/languages/presentation/language_settings_card.dart';
import 'package:watermeter/core/preferences/data/shared_preference_store.dart';
import 'package:watermeter/core/preferences/preference_store_interface.dart';
import 'package:watermeter/core/presentation/app_shell/app_shell.dart';
import 'package:watermeter/core/presentation/app_shell/app_shell_page_interface.dart';
import 'package:watermeter/core/presentation/grid_page/grid_page.dart';
import 'package:watermeter/core/presentation/grid_page/grid_page_card_interface.dart';
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
  final database = XDYouDatabase();
  try {
    await database.customSelect('SELECT 1').get();
    final themePreferences = await SharedPreferenceStore.forOwner('theme');
    final languagePreferences = await SharedPreferenceStore.forOwner(
      'language',
    );
    final gridPreferences = await SharedPreferenceStore.forOwner('grid_page');
    runApp(
      TranslationProvider(
        child: MultiProvider(
          providers: [
            Provider<XDYouDatabase>(
              lazy: false,
              create: (_) => database,
              dispose: (_, database) => unawaited(database.close()),
            ),
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
          child: MyApp(gridPreferences: gridPreferences),
        ),
      ),
    );
  } catch (_) {
    await database.close();
    rethrow;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.gridPreferences});

  final PreferenceStoreInterface gridPreferences;

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
          home: AppShell(
            pages: [
              GridPage(
                icons: const GridPageIcons(
                  icon: Icon(Icons.school_outlined),
                  selectedIcon: Icon(Icons.school),
                ),
                navigationLabel: context.t.core.gridPage.label,
                cards: const [
                  _PlaceholderGridCard('wide_1', 4),
                  _PlaceholderGridCard('wide_2', 4),
                  _PlaceholderGridCard('small_1', 1),
                  _PlaceholderGridCard('small_2', 1),
                ],
                preferences: gridPreferences,
              ),
              const MyHomePage(title: 'XDYou'),
            ],
          ),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}

class _PlaceholderGridCard implements GridPageCardInterface {
  const _PlaceholderGridCard(this.id, this._flex);

  @override
  final String id;
  final int _flex;

  @override
  int flex() => _flex;

  @override
  String title(BuildContext context) => id;

  @override
  Widget buildCard(BuildContext context, bool editMode) => Stack(
    fit: StackFit.expand,
    children: [
      const Placeholder(),
      Center(child: Text(id)),
    ],
  );
}

class MyHomePage extends StatefulWidget implements AppShellPageInterface {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  String label(BuildContext context) => context.t.core.theme.display;

  @override
  Widget icon(BuildContext context) =>
      const Icon(MingCuteIcons.mgc_user_2_line);

  @override
  Widget selectedIcon(BuildContext context) =>
      const Icon(MingCuteIcons.mgc_user_2_fill);

  @override
  Widget buildPage(BuildContext context) => this;

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
