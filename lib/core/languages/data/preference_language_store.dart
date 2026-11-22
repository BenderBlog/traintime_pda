import 'package:signals/signals.dart';
import 'package:watermeter/core/languages/language_store_interface.dart';
import 'package:watermeter/core/preferences/preference_store_interface.dart';
import 'package:watermeter/generated/translations.g.dart';

final class PreferenceLanguageStore implements LanguageStoreInterface {
  PreferenceLanguageStore(this._preferences)
    : _language = signal(_read(_preferences)) {
    _apply(_language.value);
  }

  final PreferenceStoreInterface _preferences;
  final Signal<AppLanguage> _language;
  Future<void> _pending = Future.value();

  static AppLanguage _read(PreferenceStoreInterface preferences) {
    final saved = preferences.getString('language');
    for (final language in AppLanguage.values) {
      if (language.name == saved) return language;
    }
    return AppLanguage.system;
  }

  static void _apply(AppLanguage language) {
    switch (language) {
      case AppLanguage.system:
        LocaleSettings.useDeviceLocaleSync();
      case AppLanguage.simplifiedChinese:
        LocaleSettings.setLocaleSync(AppLocale.zh);
      case AppLanguage.traditionalChinese:
        LocaleSettings.setLocaleSync(AppLocale.zhTw);
      case AppLanguage.english:
        LocaleSettings.setLocaleSync(AppLocale.en);
    }
  }

  @override
  ReadonlySignal<AppLanguage> get language => _language.readonly();

  @override
  Future<void> setLanguage(AppLanguage language) {
    final operation = _pending.then((_) async {
      await _preferences.setString('language', language.name);
      _language.value = language;
      _apply(language);
    });
    _pending = operation.catchError((Object _) {});
    return operation;
  }

  @override
  void dispose() => _language.dispose();
}
