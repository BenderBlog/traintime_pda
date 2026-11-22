import 'package:signals/signals.dart';

enum AppLanguage { system, simplifiedChinese, traditionalChinese, english }

abstract interface class LanguageStoreInterface {
  ReadonlySignal<AppLanguage> get language;
  Future<void> setLanguage(AppLanguage language);
  void dispose();
}
