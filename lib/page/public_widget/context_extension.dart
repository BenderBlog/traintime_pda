// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:watermeter/repository/preference.dart';
import 'package:watermeter/routing/routes.dart';

extension BuildContextExt on BuildContext {
  /// Track the current detail route name to prevent duplicate pushes.
  static String? _currentDetailRoute;

  /// Whether [name] matches the tracked detail route AND that page
  /// is still on the navigator stack (i.e. the user hasn't popped it
  /// via the system back button).
  static bool _isAlreadyOnRoute(NavigatorState navigator, String name) {
    if (_currentDetailRoute != name) return false;
    // canPop == true  → a detail page is on top → duplicate, skip
    // canPop == false → user popped back to placeholder → allow push
    return navigator.canPop();
  }

  Future<T?> push<T extends Object?>(Widget page) =>
      (splitViewKey.currentState ?? Navigator.of(this)).push(
        MaterialPageRoute<T>(builder: (_) => page),
      );

  Future<T?> pushReplacement<T extends Object?>(Widget page) {
    _currentDetailRoute = null;
    if (splitViewKey.currentState != null) {
      return splitViewKey.currentState!.pushAndRemoveUntil(
        MaterialPageRoute<T>(builder: (_) => page),
        (route) => route.isFirst && route.isActive,
      );
    } else {
      return Navigator.of(
        this,
      ).pushReplacement(MaterialPageRoute<T>(builder: (_) => page));
    }
  }

  /// Push a named route. Skips if the top route already has the same name.
  Future<T?> pushNamed<T extends Object?>(
    String name, {
    Object? arguments,
  }) {
    final navigator = splitViewKey.currentState ?? Navigator.of(this);
    if (_isAlreadyOnRoute(navigator, name)) return Future.value(null);
    _currentDetailRoute = name;
    return navigator.push<T>(
      Routes.resolveRoute<T>(name, arguments: arguments),
    );
  }

  /// Replace the current detail page with a named route.
  /// Skips if the top route already has the same name.
  Future<T?> pushReplacementNamed<T extends Object?>(
    String name, {
    Object? arguments,
  }) {
    final navigator = splitViewKey.currentState ?? Navigator.of(this);
    if (_isAlreadyOnRoute(navigator, name)) return Future.value(null);
    _currentDetailRoute = name;
    final route = Routes.resolveRoute<T>(name, arguments: arguments);
    if (splitViewKey.currentState != null) {
      return splitViewKey.currentState!.pushAndRemoveUntil<T>(
        route,
        (r) => r.isFirst && r.isActive,
      );
    } else {
      return Navigator.of(this).pushReplacement(route);
    }
  }

  void pop<T extends Object?>([T? result]) {
    _currentDetailRoute = null;
    Navigator.pop(this, result);
  }

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
