// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:watermeter/repository/preference.dart';

extension BuildContextExt on BuildContext {
  Future<T?> push<T extends Object?>(Widget page) =>
      (splitViewKey.currentState ?? Navigator.of(this))
          .push(MaterialPageRoute<T>(builder: (_) => page));

  Future<T?> pushReplacement<T extends Object?>(Widget page) {
    if (splitViewKey.currentState != null) {
      return splitViewKey.currentState!.pushAndRemoveUntil(
        MaterialPageRoute<T>(builder: (_) => page),
        (route) => route.isFirst && route.isActive,
      );
    } else {
      return Navigator.of(this).pushReplacement(MaterialPageRoute<T>(
        builder: (_) => page,
      ));
    }
  }

  ///( ?? );

  void pop<T extends Object?>([T? result]) => Navigator.pop(this, result);

  Future<T?> pushDialog<T>(
    Widget dialog, {
    bool barrierDismissible = true,
    Color? barrierColor,
    String? barrierLabel,
    bool useSafeArea = true,
    bool useRootNavigator = true,
    RouteSettings? routeSettings,
    Offset? anchorPoint,
    TraversalEdgeBehavior? traversalEdgeBehavior,
  }) =>
      (splitViewKey.currentState ?? Navigator.of(this)).push(
        DialogRoute(
          context: splitViewKey.currentState?.context ?? this,
          builder: (context) =>
              Material(type: MaterialType.transparency, child: dialog),
        ),
      );
}
