import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:watermeter/generated/translations.g.dart';
import 'package:watermeter/page/setting/groups/ui_section/localization_setting_view.dart';
import 'package:watermeter/repository/preference.dart' as preference;

void main() {
  testWidgets('language selection updates the page and persists old locale codes',
      (tester) async {
    final previousPlatform = SharedPreferencesAsyncPlatform.instance;
    SharedPreferencesAsyncPlatform.instance = InMemorySharedPreferencesAsync.empty();
    addTearDown(() {
      SharedPreferencesAsyncPlatform.instance = previousPlatform;
      LocaleSettings.setLocaleSync(AppLocale.zh);
    });
    preference.prefs = await SharedPreferencesWithCache.create(
      cacheOptions: const SharedPreferencesWithCacheOptions(),
    );
    await preference.setString(preference.Preference.localization, 'zh_CN');
    LocaleSettings.setLocaleSync(AppLocale.zh);

    await tester.pumpWidget(TranslationProvider(
      child: Builder(builder: (context) => MaterialApp(
        locale: context.t.$meta.locale.flutterLocale,
        supportedLocales: AppLocaleUtils.supportedLocales,
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        home: Scaffold(body: Column(children: [
          const LocalizationSettingView(),
          Builder(builder: (context) => Text(context.t.setting.sections.display)),
        ])),
      )),
    ));

    expect(find.text('修改语言'), findsOneWidget);
    await tester.tap(find.text('修改语言'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('英语'));
    await tester.pumpAndSettle();

    final english = AppLocale.en.buildSync();
    expect(find.text(english.setting.localizationDialog.title), findsOneWidget);
    expect(find.text(english.setting.sections.display), findsOneWidget);
    expect(preference.getString(preference.Preference.localization), 'en_US');
    expect(LocaleSettings.currentLocale, AppLocale.en);
    expect(tester.takeException(), isNull);
  });
}
