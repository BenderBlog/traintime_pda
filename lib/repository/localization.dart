// Copyright 2024 BenderBlog Rodriguez and contributors.
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
  );
  // english under construction.

  const Localization({
    required this.toShow,
    this.string = "",
  });

  final String string;
  final String toShow;
}
