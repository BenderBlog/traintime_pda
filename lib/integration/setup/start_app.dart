// Copyright 2026 Traintime PDA authors, originally by Hazuki Keatsu
// SPDX-License-Identifier: MPL-2.0

import 'dart:async';

import 'package:catcher_2/catcher_2.dart';
import 'package:flutter/material.dart' as legacy;
import 'package:material_ui/material_ui.dart';
import 'package:pda_network/pda_network.dart';
import 'package:pda_repository/pda_repository.dart';
import 'package:provider/provider.dart';
import 'package:signals/signals_flutter.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'package:watermeter/core/languages/data/preference_language_store.dart';
import 'package:watermeter/core/languages/language_store_interface.dart';
import 'package:watermeter/core/logging/logger_interface.dart';
import 'package:watermeter/core/preferences/data/shared_preference_store.dart';
import 'package:watermeter/core/preferences/preference_store_interface.dart';
import 'package:watermeter/core/presentation/app_shell/app_shell.dart';
import 'package:watermeter/core/presentation/grid_page/grid_page.dart';
import 'package:watermeter/core/presentation/grid_page/grid_page_card_interface.dart';
import 'package:watermeter/core/presentation/settings_page/settings_page.dart';
import 'package:watermeter/core/presentation/settings_page/settings_page_section_interface.dart';
import 'package:watermeter/core/themes/data/preference_theme_store.dart';
import 'package:watermeter/core/themes/presentation/app_theme.dart';
import 'package:watermeter/core/themes/theme_store_interface.dart';
import 'package:watermeter/features/update/update.dart';
import 'package:watermeter/generated/application_version.g.dart';
import 'package:watermeter/generated/translations.g.dart';
import 'package:watermeter/integration/database/xdyou_database.dart';
import 'package:watermeter/integration/setup/settings_sections.dart';

Future<void> startApp(LoggerInterface logger, Talker talker) async {
  final database = XDYouDatabase();
  final network = DioUpdateRepository();
  try {
    await database.customSelect('SELECT 1').get();
    final themePreferences = await SharedPreferenceStore.forOwner('theme');
    final languagePreferences = await SharedPreferenceStore.forOwner(
      'language',
    );
    final gridPreferences = await SharedPreferenceStore.forOwner('grid_page');
    final updateFeature = UpdateFeature(
      network,
      localVersion: PackageApplicationInfo.applicationVersion,
    );
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
            Provider<Talker>.value(value: talker),
            Provider<UpdateRepository>(
              lazy: false,
              create: (_) => network,
              dispose: (_, _) {
                updateFeature.dispose();
                network.close();
              },
            ),
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
          child: MyApp(
            gridPreferences: gridPreferences,
            headers: [updateFeature.card],
            settingsSections: [
              AboutSection(
                updateFeature: updateFeature,
                appInfo: PackageApplicationInfo(),
              ),
              CoreSection(talker: talker),
            ],
          ),
        ),
      ),
    );
    unawaited(updateFeature.start());
    logger.info('[startApp] App was started');
  } catch (e, stack) {
    logger.error("[startApp] Fail to start app", e, stack);
    network.close();
    await database.close();
    rethrow;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    required this.gridPreferences,
    required this.headers,
    required this.settingsSections,
  });

  final PreferenceStoreInterface gridPreferences;
  final List<GridPageCardInterface> headers;
  final List<SettingsPageSectionInterface> settingsSections;

  @override
  Widget build(BuildContext context) {
    final themeStore = context.watch<ThemeStoreInterface>();
    final locale = context.t.$meta.locale.flutterLocale;
    return SignalBuilder(
      builder: (context) {
        final settings = themeStore.settings.value;
        return MaterialApp(
          title: 'XDYou',
          // Catcher2 uses the root navigator to present error reports.
          navigatorKey: Catcher2.navigatorKey,
          locale: locale,
          supportedLocales: AppLocaleUtils.supportedLocales,
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          theme: AppTheme.light(settings),
          darkTheme: AppTheme.dark(settings),
          themeMode: AppTheme.mode(settings.brightness),
          // Talker's routes need the legacy Material theme and localizations.
          builder: (context, child) => MaterialUiCompatibilityBridge(
            child: legacy.ScaffoldMessenger(
              child: MediaQuery(
                data: MediaQuery.of(
                  context,
                ).copyWith(textScaler: TextScaler.linear(settings.fontScale)),
                child: child!,
              ),
            ),
          ),
          home: AppShell(
            pages: [
              GridPage(
                icons: const GridPageIcons(
                  icon: Icon(Icons.school_outlined),
                  selectedIcon: Icon(Icons.school),
                ),
                navigationLabel: context.t.core.gridPage.label,
                headers: headers,
                cards: const [
                  _PlaceholderGridCard('wide_1', 4),
                  _PlaceholderGridCard('wide_2', 4),
                  _PlaceholderGridCard('small_1', 1),
                  _PlaceholderGridCard('small_2', 1),
                ],
                preferences: gridPreferences,
              ),
              SettingsPage(sections: settingsSections),
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
