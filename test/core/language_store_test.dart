// Copyright 2026 Hazuki Keatsu
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:watermeter/core/languages/language_store_interface.dart';
import 'package:watermeter/core/preferences/preference_store_interface.dart';
import 'package:watermeter/core/languages/data/preference_language_store.dart';
import 'package:watermeter/core/languages/presentation/language_settings_card.dart';
import 'package:watermeter/generated/translations.g.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('restores, changes, and saves an explicit language', () async {
    final preferences = _Preferences()..value = 'english';
    final store = PreferenceLanguageStore(preferences);
    expect(store.language.value, AppLanguage.english);
    expect(LocaleSettings.currentLocale, AppLocale.en);

    await store.setLanguage(AppLanguage.simplifiedChinese);
    expect(preferences.value, 'simplifiedChinese');
    expect(store.language.value, AppLanguage.simplifiedChinese);
    expect(LocaleSettings.currentLocale, AppLocale.zh);

    await store.setLanguage(AppLanguage.traditionalChinese);
    expect(LocaleSettings.currentLocale, AppLocale.zhTw);
    expect(preferences.value, 'traditionalChinese');

    preferences.fail = true;
    await expectLater(store.setLanguage(AppLanguage.english), throwsStateError);
    expect(store.language.value, AppLanguage.traditionalChinese);
    expect(LocaleSettings.currentLocale, AppLocale.zhTw);
    store.dispose();
  });

  test('unknown saved language falls back to system selection', () {
    final store = PreferenceLanguageStore(_Preferences()..value = 'unknown');
    expect(store.language.value, AppLanguage.system);
    store.dispose();
  });

  testWidgets('language card changes translated text and saves selection', (
    tester,
  ) async {
    final preferences = _Preferences()..value = 'simplifiedChinese';
    final store = PreferenceLanguageStore(preferences);
    await tester.pumpWidget(
      TranslationProvider(
        child: Provider<LanguageStoreInterface>.value(
          value: store,
          child: const MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(child: LanguageSettingsCard()),
            ),
          ),
        ),
      ),
    );
    expect(find.textContaining('应用语言', findRichText: true), findsOneWidget);
    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();
    expect(find.textContaining('App language', findRichText: true), findsOneWidget);
    expect(preferences.value, 'english');
    store.dispose();
  });
}

class _Preferences extends Fake implements PreferenceStoreInterface {
  String? value;
  bool fail = false;

  @override
  String? getString(String key) => value;

  @override
  Future<void> setString(String key, String value) async {
    if (fail) throw StateError('write failed');
    this.value = value;
  }
}
