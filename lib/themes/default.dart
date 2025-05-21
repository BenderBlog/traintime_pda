// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/cupertino.dart';

/// Original demo_blue theme.
sealed class DefaultColor {
  static FlexSchemeColor light = const FlexSchemeColor(
    primary: Color(0xff3f5f90),
    primaryContainer: Color(0xffd0e4ff),
    primaryLightRef: Color(0xff3f5f90),
    secondary: Color(0xff526070),
    secondaryContainer: Color(0xffffdbcf),
    secondaryLightRef: Color(0xff526070),
    tertiary: Color(0xff006875),
    tertiaryContainer: Color(0xff95f0ff),
    tertiaryLightRef: Color(0xff006875),
    appBarColor: Color(0xffffdbcf),
    error: Color(0xffba1a1a),
    errorContainer: Color(0xffffdad6),
  );
  static FlexSchemeColor dark = const FlexSchemeColor(
    primary: Color(0xff9fc9ff),
    primaryContainer: Color(0xff00325b),
    primaryLightRef: Color(0xff3f5f90),
    secondary: Color(0xffffb59d),
    secondaryContainer: Color(0xff872100),
    secondaryLightRef: Color(0xff526070),
    tertiary: Color(0xff86d2e1),
    tertiaryContainer: Color(0xff004e59),
    tertiaryLightRef: Color(0xff006875),
    appBarColor: Color(0xffffdbcf),
    error: Color(0xffffb4ab),
    errorContainer: Color(0xff93000a),
  );
}
