// Copyright 2026 Traintime PDA authors, originally by Hazuki Keatsu
// SPDX-License-Identifier: MPL-2.0

import 'package:catcher_2/catcher_2.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart' as legacy;
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:provider/provider.dart';
import 'package:pda_repository/pda_repository.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'package:watermeter/integration/setup/start_app.dart';
import 'package:watermeter/core/presentation/app_shell/app_shell.dart';
import 'package:watermeter/core/presentation/grid_page/grid_page.dart';
import 'package:watermeter/core/languages/language_store_interface.dart';
import 'package:watermeter/core/languages/data/preference_language_store.dart';
import 'package:watermeter/core/themes/presentation/app_theme.dart';
import 'package:watermeter/core/preferences/preference_store_interface.dart';
import 'package:watermeter/core/logging/logger_interface.dart';
import 'package:watermeter/core/themes/theme_store_interface.dart';
import 'package:watermeter/core/logging/talker_app_logger.dart';
import 'package:watermeter/core/themes/data/preference_theme_store.dart';
import 'package:watermeter/core/themes/presentation/theme_settings_card.dart';
import 'package:watermeter/core/shared/widgets/settings/choice_control.dart';
import 'package:watermeter/core/shared/widgets/settings/color_choices.dart';
import 'package:watermeter/core/shared/widgets/settings/segmented_list.dart';
import 'package:watermeter/core/shared/widgets/settings/slider_tile.dart';
import 'package:watermeter/generated/translations.g.dart';
import 'package:watermeter/features/update/update.dart';
import 'package:watermeter/features/ids/ids.dart';
import 'package:watermeter/core/secure_storage/secure_store_interface.dart';
import 'package:watermeter/core/presentation/settings_page/settings_page_section_interface.dart';
import 'package:watermeter/features/settings/settings.dart';
import 'package:watermeter/generated/application_version.g.dart';

void main() {
  testWidgets('about settings opens the application information', (
    tester,
  ) async {
    LocaleSettings.setLocaleSync(AppLocale.en);
    final store = PreferenceThemeStore(
      _MemoryPreferences(),
      _RecordingLogger(),
    );
    final appInfo = PackageApplicationInfo();
    await tester.pumpWidget(
      TranslationProvider(
        child: MultiProvider(
          providers: [
            Provider<ThemeStoreInterface>.value(value: store),
            Provider<LoggerInterface>.value(value: _RecordingLogger()),
            Provider<PackageApplicationInfo>.value(value: appInfo),
          ],
          child: MyApp(
            gridPreferences: _MemoryPreferences(),
            headers: const [],
            settingsSections: [_AboutTestSection(appInfo)],
          ),
        ),
      ),
    );
    await tester.tap(find.byIcon(MingCuteIcons.mgc_user_2_line));
    await tester.pumpAndSettle();
    await tester.tap(find.text('About this APP'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(
      find.text('NOEL - PDA Third Year Anniversary Edition'),
      findsOneWidget,
    );
    store.dispose();
  });

  test('logger maps its supported levels to Talker', () {
    final talker = Talker(logger: TalkerLogger(output: (_) {}));
    final LoggerInterface logger = TalkerAppLogger(talker);

    logger.debug('debug');
    logger.info('info');
    logger.warning('warning');
    logger.error('error');

    expect(
      [for (final entry in talker.history) (entry.message, entry.logLevel)],
      [
        ('debug', LogLevel.debug),
        ('info', LogLevel.info),
        ('warning', LogLevel.warning),
        ('error', LogLevel.error),
      ],
    );
  });

  test('Talker logger records error details without changing them', () {
    final talker = Talker(logger: TalkerLogger(output: (_) {}));
    final error = StateError('write failed');
    final stackTrace = StackTrace.current;

    TalkerAppLogger(talker)
        .error('Failed to save theme settings', error, stackTrace);

    final entry = talker.history.single;
    expect(entry.message, 'Failed to save theme settings');
    expect(entry.exception, same(error));
    expect(entry.stackTrace, same(stackTrace));
  });

  test('built-in palettes use FlexScheme for each brightness', () {
    for (final (palette, scheme) in [
      (ThemePalette.blue, FlexScheme.blue),
      (ThemePalette.deepPurple, FlexScheme.deepPurple),
      (ThemePalette.pink, FlexScheme.pinkM3),
    ]) {
      final settings = ThemeSettings(palette: palette);
      expect(
        AppTheme.light(settings).colorScheme,
        FlexThemeData.light(
          colors: scheme.colors(Brightness.light),
          usedColors: 1,
        ).colorScheme,
      );
      expect(
        AppTheme.dark(settings).colorScheme,
        FlexThemeData.dark(
          colors: scheme.colors(Brightness.dark),
          usedColors: 1,
        ).colorScheme,
      );
    }
  });

  test(
    'reads owned theme keys and publishes only successful changes',
    () async {
      final preferences = _MemoryPreferences()
        ..values.addAll({
          'palette': 3,
          'brightness': 2,
          'fontScale': 1.2,
          'fontWeight': 0.75,
        });
      final logger = _RecordingLogger();
      final ThemeStoreInterface store = PreferenceThemeStore(
        preferences,
        logger,
      );

      expect(store.settings.value.palette, ThemePalette.green);
      expect(store.settings.value.brightness, ThemeBrightness.dark);
      expect(store.settings.value.fontScale, 1.2);
      expect(store.settings.value.fontWeight, 0.75);

      await store.setPalette(ThemePalette.orange);
      await store.setBrightness(ThemeBrightness.light);
      await store.setFontScale(1.4);
      await store.setFontWeight(0.25);
      expect(store.settings.value.palette, ThemePalette.orange);
      expect(preferences.values, containsPair('palette', 4));
      expect(preferences.values, containsPair('brightness', 1));
      expect(preferences.values, containsPair('fontScale', 1.4));
      expect(preferences.values, containsPair('fontWeight', 0.25));

      preferences.failWrites = true;
      await expectLater(store.setPalette(ThemePalette.blue), throwsStateError);
      expect(store.settings.value.palette, ThemePalette.orange);
      expect(logger.errors, hasLength(1));
      expect(logger.errors.single.$1, 'Failed to save theme settings');
      expect(logger.errors.single.$2, isA<StateError>());
      expect(logger.errors.single.$3, isA<StackTrace>());
      preferences.failWrites = false;
      await store.setPalette(ThemePalette.blue);
      expect(store.settings.value.palette, ThemePalette.blue);
      store.dispose();
    },
  );

  test('old keys are ignored and invalid owned values use defaults', () {
    final preferences = _MemoryPreferences()
      ..values.addAll({
        'color': 3,
        'palette': 99,
        'brightness': -1,
        'fontScale': 20.0,
        'fontWeight': -5.0,
      });
    final ThemeStoreInterface store = PreferenceThemeStore(
      preferences,
      _RecordingLogger(),
    );
    expect(store.settings.value.palette, ThemePalette.indigo);
    expect(store.settings.value.brightness, ThemeBrightness.system);
    expect(store.settings.value.fontScale, 1.4);
    expect(store.settings.value.fontWeight, 0.0);
    store.dispose();
  });

  test('rejects an invalid font setting', () {
    expect(() => ThemeSettings(fontScale: double.nan), throwsRangeError);
    expect(() => ThemeSettings(fontWeight: 1.5), throwsRangeError);
  });

  testWidgets('MaterialApp follows theme changes', (tester) async {
    LocaleSettings.setLocaleSync(AppLocale.zh);
    final languageStore = PreferenceLanguageStore(_MemoryPreferences());
    await languageStore.setLanguage(AppLanguage.simplifiedChinese);
    final ThemeStoreInterface store = PreferenceThemeStore(
      _MemoryPreferences(),
      _RecordingLogger(),
    );
    final updateFeature = UpdateFeature(
      _StaticUpdateRepository(),
      localVersion: '2.0.0',
    );
    await tester.pumpWidget(
      TranslationProvider(
        child: MultiProvider(
          providers: [
            Provider<ThemeStoreInterface>.value(value: store),
            Provider<LanguageStoreInterface>.value(value: languageStore),
          ],
          child: MyApp(
            gridPreferences: _MemoryPreferences(),
            headers: [updateFeature.card],
            settingsSections: const [],
          ),
        ),
      ),
    );
    expect(Catcher2.navigatorKey.currentState?.overlay, isNotNull);
    expect(
      tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
      ThemeMode.system,
    );
    expect(find.byType(AppShell), findsOneWidget);
    expect(find.byType(GridPage), findsOneWidget);
    expect(find.byType(Placeholder), findsNWidgets(4));
    expect(find.text('wide_1'), findsOneWidget);
    expect(find.byIcon(Icons.school), findsOneWidget);
    await tester.tap(find.byIcon(MingCuteIcons.mgc_user_2_line));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.school_outlined), findsOneWidget);
    expect(find.byIcon(MingCuteIcons.mgc_user_2_fill), findsOneWidget);
    expect(find.text('设置'), findsWidgets);
    expect(
      find.text('You have pushed the button this many times:'),
      findsNothing,
    );
    await store.setPalette(ThemePalette.green);
    await store.setBrightness(ThemeBrightness.dark);
    await tester.pump();
    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.themeMode, ThemeMode.dark);
    expect(app.theme!.colorScheme.primary, const Color(0xff4ea34c));
    store.dispose();
    languageStore.dispose();
    updateFeature.dispose();
  });

  testWidgets('MyApp starts on login only when no IDS account is saved', (
    tester,
  ) async {
    LocaleSettings.setLocaleSync(AppLocale.zh);
    final preferences = _MemoryPreferences();
    final themeStore = PreferenceThemeStore(preferences, _RecordingLogger());
    final secure = _TestSecureStore();
    final credentials = SecureIdsCredentialsStore(secure);
    final signedOut = IdsUseCase(credentials, _TestIdsNetwork());
    await signedOut.restore();

    await tester.pumpWidget(
      TranslationProvider(
        child: Provider<ThemeStoreInterface>.value(
          value: themeStore,
          child: MyApp(
            gridPreferences: preferences,
            headers: const [],
            settingsSections: const [],
            idsUseCase: signedOut,
          ),
        ),
      ),
    );
    expect(find.byType(IdsGate), findsOneWidget);
    expect(find.byType(AppShell), findsNothing);
    await tester.enterText(find.byType(legacy.TextField).first, 'alice');
    await tester.enterText(find.byType(legacy.TextField).last, 'secret');
    await tester.tap(find.text('登录'));
    await tester.pumpAndSettle();
    expect(find.byType(AppShell), findsOneWidget);
    expect(find.byType(legacy.TextField), findsNothing);

    await tester.pumpWidget(const legacy.SizedBox());
    final signedIn = IdsUseCase(credentials, _TestIdsNetwork());
    await signedIn.restore();
    await tester.pumpWidget(
      TranslationProvider(
        child: Provider<ThemeStoreInterface>.value(
          value: themeStore,
          child: MyApp(
            gridPreferences: preferences,
            headers: const [],
            settingsSections: const [],
            idsUseCase: signedIn,
          ),
        ),
      ),
    );
    expect(find.byType(AppShell), findsOneWidget);
    expect(find.byType(legacy.TextField), findsNothing);
    signedOut.dispose();
    signedIn.dispose();
    themeStore.dispose();
  });

  testWidgets('Talker routes inherit legacy Material localizations', (
    tester,
  ) async {
    LocaleSettings.setLocaleSync(AppLocale.en);
    final languageStore = PreferenceLanguageStore(_MemoryPreferences());
    final ThemeStoreInterface store = PreferenceThemeStore(
      _MemoryPreferences(),
      _RecordingLogger(),
    );
    final talker = Talker(logger: TalkerLogger(output: (_) {}));
    talker.info('copy target');
    await tester.pumpWidget(
      TranslationProvider(
        child: MultiProvider(
          providers: [
            Provider<ThemeStoreInterface>.value(value: store),
            Provider<LanguageStoreInterface>.value(value: languageStore),
            Provider<Talker>.value(value: talker),
          ],
          child: MyApp(
            gridPreferences: _MemoryPreferences(),
            headers: const [],
            settingsSections: [_TalkerSection(talker)],
          ),
        ),
      ),
    );

    await tester.tap(find.byIcon(MingCuteIcons.mgc_user_2_line));
    await tester.pumpAndSettle();
    await tester.tap(find.text('View network interceptor and logs'));
    await tester.pumpAndSettle();
    expect(find.byType(TalkerScreen), findsOneWidget);
    await tester.tap(find.byIcon(Icons.copy).first);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Log item is copied in clipboard'), findsOneWidget);
    await store.setPalette(ThemePalette.green);
    await store.setBrightness(ThemeBrightness.dark);
    await tester.pumpAndSettle();
    final talkerTheme = tester
        .widget<TalkerScreen>(find.byType(TalkerScreen))
        .theme;
    final appColors = AppTheme.dark(store.settings.value).colorScheme;
    expect(
      Theme.of(tester.element(find.byType(TalkerScreen))).colorScheme.surface,
      appColors.surface,
    );
    expect(
      legacy.Theme.of(tester.element(find.byType(TalkerScreen)))
          .colorScheme
          .surface,
      appColors.surface,
    );
    expect(talkerTheme.backgroundColor, appColors.surface);
    expect(talkerTheme.textColor, appColors.onSurface);
    expect(talkerTheme.logColors, TalkerScreenTheme().logColors);

    await tester.tap(find.byIcon(Icons.monitor_heart_outlined));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Talker Monitor'), findsOneWidget);

    store.dispose();
    languageStore.dispose();
  });

  testWidgets('theme settings card updates its own store', (tester) async {
    LocaleSettings.setLocaleSync(AppLocale.en);
    final preferences = _MemoryPreferences();
    final logger = _RecordingLogger();
    final ThemeStoreInterface store = PreferenceThemeStore(preferences, logger);
    await tester.pumpWidget(
      TranslationProvider(
        child: Provider<ThemeStoreInterface>.value(
          value: store,
          child: const MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(child: ThemeSettingsCard()),
            ),
          ),
        ),
      ),
    );

    expect(find.byType(SettingSegmentedList), findsNWidgets(2));
    expect(find.byIcon(MingCuteIcons.mgc_palette_line), findsOneWidget);
    expect(find.byIcon(MingCuteIcons.mgc_brightness_line), findsWidgets);
    expect(find.byType(SettingColorChoices<ThemePalette>), findsOneWidget);
    expect(find.byType(SettingChoiceControl<ThemeBrightness>), findsOneWidget);
    expect(find.byType(SettingSliderTile), findsNWidgets(2));

    await tester.tap(find.text('Dark').last);
    await tester.pumpAndSettle();

    expect(store.settings.value.brightness, ThemeBrightness.dark);
    expect(preferences.getInt('brightness'), 2);

    preferences.failWrites = true;
    await tester.tap(find.text('Sky Blue').last);
    await tester.pumpAndSettle();
    expect(find.text('Unable to save theme settings'), findsOneWidget);
    expect(find.textContaining('write failed'), findsNothing);
    expect(logger.errors, hasLength(1));
    store.dispose();
  });

  testWidgets('theme settings card follows the Slang locale', (tester) async {
    LocaleSettings.setLocaleSync(AppLocale.zh);
    final ThemeStoreInterface store = PreferenceThemeStore(
      _MemoryPreferences(),
      _RecordingLogger(),
    );
    await tester.pumpWidget(
      TranslationProvider(
        child: Provider<ThemeStoreInterface>.value(
          value: store,
          child: const MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(child: ThemeSettingsCard()),
            ),
          ),
        ),
      ),
    );

    expect(find.text('显示'), findsOneWidget);
    expect(find.textContaining('颜色设置', findRichText: true), findsOneWidget);
    expect(find.textContaining('字体大小', findRichText: true), findsOneWidget);
    expect(find.text('默认颜色'), findsOneWidget);
    expect(find.textContaining('100%', findRichText: true), findsOneWidget);
    await LocaleSettings.setLocale(AppLocale.en);
    await tester.pumpAndSettle();
    expect(find.text('Display'), findsOneWidget);
    expect(
      find.textContaining('Color theme', findRichText: true),
      findsOneWidget,
    );
    expect(
      find.textContaining('Font size', findRichText: true),
      findsOneWidget,
    );
    expect(find.text('Default'), findsOneWidget);
    expect(find.textContaining('100%', findRichText: true), findsOneWidget);
    store.dispose();
  });
}

final class _AboutTestSection implements SettingsPageSectionInterface {
  _AboutTestSection(this.appInfo);
  final PackageApplicationInfo appInfo;
  @override
  IconData? icon() => null;
  @override
  String? title() => null;
  @override
  List<SettingsPageSectionEntry> items(BuildContext context) => [
    aboutTile(context, appInfo),
  ];
}

final class _TalkerSection implements SettingsPageSectionInterface {
  const _TalkerSection(this.talker);
  final Talker talker;
  @override
  IconData? icon() => null;
  @override
  String? title() => null;
  @override
  List<SettingsPageSectionEntry> items(BuildContext context) => [
    talkerTile(context, talker),
  ];
}

class _StaticUpdateRepository implements UpdateRepository {
  @override
  Future<UpdateReleaseData> fetchLatest() async => (
    code: '2.0.0',
    changes: <String>[],
    iosUrl: 'https://example.org/ios',
    androidUrl: 'https://example.org/android',
    githubUrl: 'https://example.org/releases',
  );
}

final class _TestSecureStore implements SecureStoreInterface {
  final values = <String, String>{};

  @override
  Future<String?> read(String key) async => values[key];

  @override
  Future<void> write(String key, String value) async => values[key] = value;

  @override
  Future<void> delete(String key) async => values.remove(key);
}

final class _TestIdsNetwork implements IdsNetworkRepository {
  @override
  Future<void> login(
    String username,
    String password, {
    IdsInteraction interaction = const IdsInteraction(),
  }) async {}

  @override
  Future<void> authorize(
    Uri service, {
    IdsInteraction interaction = const IdsInteraction(),
  }) async {}

  @override
  Future<void> clear() async {}
}

class _RecordingLogger extends Fake implements LoggerInterface {
  final errors = <(String, Object?, StackTrace?)>[];

  @override
  void error(String message, [Object? error, StackTrace? stackTrace]) =>
      errors.add((message, error, stackTrace));
}

class _MemoryPreferences implements PreferenceStoreInterface {
  final Map<String, Object> values = {};
  bool failWrites = false;

  @override
  String? getString(String key) => values[key] as String?;
  @override
  bool? getBool(String key) => values[key] as bool?;
  @override
  int? getInt(String key) => values[key] as int?;
  @override
  double? getDouble(String key) => values[key] as double?;
  @override
  bool contains(String key) => values.containsKey(key);
  @override
  Future<void> setString(String key, String value) async => values[key] = value;
  @override
  Future<void> setBool(String key, bool value) async => values[key] = value;
  @override
  Future<void> setInt(String key, int value) async {
    if (failWrites) throw StateError('write failed');
    values[key] = value;
  }

  @override
  Future<void> setDouble(String key, double value) async => values[key] = value;
  @override
  Future<void> remove(String key) async => values.remove(key);
}
