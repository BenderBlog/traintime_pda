// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

// "Spring breeze green" by LichtYy
//  Flowers - Andy Warhol - 1964

import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';

sealed class GreenColor {
  // The defined light theme.
  static FlexSchemeColor light = const FlexSchemeColor(
    // Custom
    primary: Color(0xff4ea34c),
    primaryContainer: Color(0xff92c692),
    primaryLightRef: Color(0xff4ea34c),
    secondary: Color(0xffa5e0bd),
    secondaryContainer: Color(0xff5fc889),
    secondaryLightRef: Color(0xffa5e0bd),
    tertiary: Color(0xff7cba34),
    tertiaryContainer: Color(0xffafd583),
    tertiaryLightRef: Color(0xff7cba34),
    appBarColor: Color(0xff5fc889),
    error: Color(0xffc33a26),
    errorContainer: Color(0xffffcdd3),
  );
  // The defined dark theme.
  static FlexSchemeColor dark = const FlexSchemeColor(
    // Custom
    primary: Color(0xff4ea34c),
    primaryContainer: Color(0xff73fa70),
    primaryLightRef: Color(0xff4ea34c),
    secondary: Color(0xff489466),
    secondaryContainer: Color(0xff5fc889),
    secondaryLightRef: Color(0xffa5e0bd),
    tertiary: Color(0xff7cba34),
    tertiaryContainer: Color(0xffabff4a),
    tertiaryLightRef: Color(0xff7cba34),
    appBarColor: Color(0xff5fc889),
    error: Color(0xffc33a26),
    errorContainer: Color(0xff8e1003),
  );
}
