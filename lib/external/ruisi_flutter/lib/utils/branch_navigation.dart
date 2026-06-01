// Copyright 2026 BenderBlog Rodriguez and Contributors.
// SPDX-License-Identifier: BSD-3-Clause

import 'package:flutter/material.dart';
import 'package:watermeter/repository/preference.dart';

extension RuisiBranchNavigation on BuildContext {
  static const String _homeTopicPreviewRouteName =
      'ruisi.home.topic_preview';

  /// 从 Ruisi 顶层入口打开一条新的页面分支。
  ///
  /// 在分屏模式下会重置右侧当前历史，只保留根页后再打开目标页面；
  /// 在单栏模式下会保留根页并打开新的顶层页面。
  Future<T?> pushRuisiBranch<T extends Object?>(Widget page) {
    final navigator = splitViewKey.currentState ?? Navigator.of(this);
    return navigator.pushAndRemoveUntil(
      MaterialPageRoute<T>(builder: (_) => page),
      (route) => route.isFirst && route.isActive,
    );
  }

  /// 从首页帖子列表打开帖子详情预览。
  ///
  /// 第一次进入时会在当前详情链上继续压栈；
  /// 如果当前顶部已经是首页帖子预览，则只替换顶部页面，
  /// 避免连续误触时无限叠栈。
  Future<T?> pushRuisiHomeTopicPreview<T extends Object?>(Widget page) {
    final navigator = splitViewKey.currentState ?? Navigator.of(this);
    final route = MaterialPageRoute<T>(
      builder: (_) => page,
      settings: const RouteSettings(name: _homeTopicPreviewRouteName),
    );

    Route<dynamic>? topRoute;
    navigator.popUntil((route) {
      topRoute = route;
      return true;
    });

    if (topRoute?.settings.name == _homeTopicPreviewRouteName) {
      return navigator.pushReplacement<T, Object?>(route);
    }

    return navigator.push<T>(route);
  }
}
