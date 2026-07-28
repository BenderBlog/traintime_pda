// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0
import 'dart:io';
import 'dart:ui';
import 'package:watermeter/generated/translations.g.dart';
import 'package:watermeter/repository/preference.dart' as preference;

enum Localization {
  undefined(string: ""),
  simplifiedChinese(string: "zh_CN"),
  traditionalChinese(string: "zh_TW"),
  english(string: "en_US");

  const Localization({this.string = ""});
  final String string;

  String displayName(Translations tr) => switch (this) {
    Localization.undefined => tr.setting.localizationDialog.undefined,
    Localization.simplifiedChinese =>
      tr.setting.localizationDialog.simplifiedChinese,
    Localization.traditionalChinese =>
      tr.setting.localizationDialog.traditionalChinese,
    Localization.english => tr.setting.localizationDialog.english,
  };

  AppLocale get appLocale => switch (this) {
    Localization.undefined => throw StateError(
      'Cannot resolve undefined to AppLocale',
    ),
    Localization.simplifiedChinese => AppLocale.zhCn,
    Localization.traditionalChinese => AppLocale.zhTw,
    Localization.english => AppLocale.en,
  };

  Locale? get flutterLocale => switch (this) {
    Localization.undefined => null,
    Localization.simplifiedChinese => const Locale("zh", "CN"),
    Localization.traditionalChinese => const Locale("zh", "TW"),
    Localization.english => const Locale("en", "US"),
  };

  /// The resolved locale: detect from system if follow-system, else self.
  Localization get resolved =>
      this == Localization.undefined ? Localization.detectSystem() : this;

  /// Detect the current system locale.
  static Localization detectSystem() {
    String systemLocale = Platform.localeName;
    if (systemLocale.contains("zh")) {
      if (Platform.isIOS || Platform.isMacOS) {
        return systemLocale.contains("Hans")
            ? Localization.simplifiedChinese
            : Localization.traditionalChinese;
      } else {
        return (systemLocale.contains("CN") || systemLocale.contains("SG"))
            ? Localization.simplifiedChinese
            : Localization.traditionalChinese;
      }
    }
    return Localization.english;
  }

  /// Load the saved locale from preferences.
  static Localization fromPreference() {
    final raw = preference.getString(preference.Preference.localization);
    return Localization.values.firstWhere(
      (l) => l.string == raw,
      orElse: () => Localization.undefined,
    );
  }

  /// Persist this locale to preferences.
  Future<void> saveToPreference() async {
    await preference.setString(preference.Preference.localization, string);
  }
}
