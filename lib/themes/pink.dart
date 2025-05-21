// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

// "Fox Pink" refer to fn by LichtYy
// Dancers in Pink - Edgar Degas - 1876

import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

sealed class PinkColor {
  // The defined light theme.
  static FlexSchemeColor light = const FlexSchemeColor(
    // Custom
    primary: Color(0xfff47b8c),
    primaryContainer: Color(0xffffd9dc),
    primaryLightRef: Color(0xfff47b8c),
    secondary: Color(0xffbec9c8),
    secondaryContainer: Color(0xff18a78f),
    secondaryLightRef: Color(0xffbec9c8),
    tertiary: Color(0xffd8734c),
    tertiaryContainer: Color(0xfff5d1c4),
    tertiaryLightRef: Color(0xffd8734c),
    appBarColor: Color(0xff18a78f),
    error: Color(0xffe01a05),
    errorContainer: Color(0xffffb4a8),
  );
  // The defined dark theme.
  static FlexSchemeColor dark = const FlexSchemeColor(
    // Custom
    primary: Color(0xfff47b8c),
    primaryContainer: Color(0xffe91e63),
    primaryLightRef: Color(0xfff47b8c),
    secondary: Color(0xff506864),
    secondaryContainer: Color(0xff18a78f),
    secondaryLightRef: Color(0xffbec9c8),
    tertiary: Color(0xffd8734c),
    tertiaryContainer: Color(0xfffa4e0c),
    tertiaryLightRef: Color(0xffd8734c),
    appBarColor: Color(0xff18a78f),
    error: Color(0xffe01a05),
    errorContainer: Color(0xff8e1003),
  );
}
