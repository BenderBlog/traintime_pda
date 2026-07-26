// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'package:watermeter/generated/l10n.dart';

enum Localization {
  undefined(string: ""),
  simplifiedChinese(string: "zh_CN"),
  traditionalChinese(string: "zh_TW"),
  english(string: "en_US");

  const Localization({this.string = ""});
  final String string;

  String displayName(I18n i18n) => switch (this) {
    Localization.undefined => i18n.settingLocalizationDialogUndefined,
    Localization.simplifiedChinese => i18n.settingLocalizationDialogSimplifiedchinese,
    Localization.traditionalChinese => i18n.settingLocalizationDialogTraditionalchinese,
    Localization.english => i18n.settingLocalizationDialogEnglish,
  };
}
