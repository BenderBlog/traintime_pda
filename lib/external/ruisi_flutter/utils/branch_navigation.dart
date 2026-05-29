// Copyright 2026 BenderBlog Rodriguez and Contributors.
// SPDX-License-Identifier: BSD-3-Clause

import 'package:flutter/material.dart';
import 'package:watermeter/repository/preference.dart';

extension RuisiBranchNavigation on BuildContext {
  /// 从 Ruisi 主入口打开一条新的页面分支。
  ///
  /// 在分屏模式下会替换右侧当前历史，
  /// 在单栏模式下会保留根页并打开新的顶层页面。
  Future<T?> pushRuisiBranch<T extends Object?>(Widget page) {
    final navigator = splitViewKey.currentState ?? Navigator.of(this);
    return navigator.pushAndRemoveUntil(
      MaterialPageRoute<T>(builder: (_) => page),
      (route) => route.isFirst && route.isActive,
    );
  }
}
