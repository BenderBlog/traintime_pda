// Copyright 2026 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

/// Visible, isolated preview of every timetable style setting.
///
/// Run with:
/// `flutter run -d macos -t test/harness/classtable_style_settings_window.dart`
///
/// All preference callbacks are in-memory, and any selected background image is copied into a
/// temporary support directory instead of the user's application data.
import 'dart:io';

import 'package:material_ui/material_ui.dart';
import 'package:watermeter/generated/translations.g.dart';
import 'package:watermeter/page/classtable/model/style_config/style_config_preference_functions.dart';
import 'package:watermeter/page/setting/groups/classtable_section/classtable_style_page/class_table_style_page.dart';
import 'package:watermeter/repository/network_client.dart' as network;

final Map<StyleConfigPreferenceKey, Object> _settings = {};

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  network.supportPath = await Directory.systemTemp.createTemp(
    'classtable-style-settings-preview-',
  );

  StyleConfigPreferenceFunctions.install(
    getBool: (key) => _settings[key] as bool? ?? false,
    getDouble: (key) => _settings[key] as double? ?? 0,
    setBool: (key, value) async => _settings[key] = value,
    setDouble: (key, value) async => _settings[key] = value,
    contains: _settings.containsKey,
  );

  await LocaleSettings.setLocale(AppLocale.zh);

  runApp(
    TranslationProvider(
      child: MaterialApp(
        title: '课表样式设置预览',
        locale: AppLocale.zh.flutterLocale,
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: AppLocaleUtils.supportedLocales,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF3976D2)),
        ),
        home: Localizations(
          locale: const Locale('en', 'US'),
          delegates: GlobalMaterialLocalizations.delegates,
          child: const ClassTableStylePage(),
        ),
      ),
    ),
  );
}
