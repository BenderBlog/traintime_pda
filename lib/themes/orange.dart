// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

// Asuka Orange

import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';

sealed class OrangeColor {
  /// Light [ColorScheme] made with FlexColorScheme v8.0.1.
  /// Requires Flutter 3.22.0 or later.
  static FlexSchemeColor light = const FlexSchemeColor(
    // Custom
    primary: Color(0xffdb683f),
    primaryContainer: Color(0xffd0e4ff),
    primaryLightRef: Color(0xffdb683f),
    secondary: Color(0xffac3306),
    secondaryContainer: Color(0xffffdbcf),
    secondaryLightRef: Color(0xffac3306),
    tertiary: Color(0xff006875),
    tertiaryContainer: Color(0xff95f0ff),
    tertiaryLightRef: Color(0xff006875),
    appBarColor: Color(0xffffdbcf),
    error: Color(0xffba1a1a),
    errorContainer: Color(0xffffdad6),
  );

  /// Dark [ColorScheme] made with FlexColorScheme v8.0.1.
  /// Requires Flutter 3.22.0 or later.
  static FlexSchemeColor dark = const FlexSchemeColor(
    // Custom
    primary: Color(0xff9fc9ff),
    primaryContainer: Color(0xff00325b),
    primaryLightRef: Color(0xffdb683f),
    secondary: Color(0xffffb59d),
    secondaryContainer: Color(0xff872100),
    secondaryLightRef: Color(0xffac3306),
    tertiary: Color(0xff86d2e1),
    tertiaryContainer: Color(0xff004e59),
    tertiaryLightRef: Color(0xff006875),
    appBarColor: Color(0xffffdbcf),
    error: Color(0xffffb4ab),
    errorContainer: Color(0xff93000a),
  );
}
