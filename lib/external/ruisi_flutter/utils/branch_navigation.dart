// Copyright 2026 BenderBlog Rodriguez and Contributors.
// SPDX-License-Identifier: BSD-3-Clause

import 'package:flutter/material.dart';
import 'package:watermeter/repository/preference.dart';

extension RuisiBranchNavigation on BuildContext {
  static const String _homeTopicPreviewRouteName =
      'ruisi.home.topic_preview';

  Future<T?> pushRuisiBranch<T extends Object?>(Widget page) {
    final navigator = splitViewKey.currentState ?? Navigator.of(this);
    return navigator.pushAndRemoveUntil(
      MaterialPageRoute<T>(builder: (_) => page),
      (route) => route.isFirst && route.isActive,
    );
  }

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
