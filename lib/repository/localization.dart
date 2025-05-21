// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

enum Localization {
  undefined(
    toShow: "setting.localization_dialog.undefined",
    string: "",
  ),
  simplifiedChinese(
    toShow: "setting.localization_dialog.simplifiedChinese",
    string: "zh_CN",
  ),
  traditionalChinese(
    toShow: "setting.localization_dialog.traditionalChinese",
    string: "zh_TW",
  ),
  english(
    toShow: "setting.localization_dialog.english",
    string: "en_US",
  );
  // english under construction.

  const Localization({
    required this.toShow,
    this.string = "",
  });

  final String string;
  final String toShow;
}
