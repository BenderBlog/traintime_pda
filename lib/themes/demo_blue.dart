// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'package:chinese_font_library/chinese_font_library.dart';
import 'package:flutter/material.dart';

const demoBlueModeMap = {
  0: ThemeMode.system,
  1: ThemeMode.light,
  2: ThemeMode.dark,
};

final demoBlue = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color.fromRGBO(49, 78, 122, 1),
    primary: const Color.fromRGBO(49, 78, 122, 1),
    primaryContainer: const Color.fromRGBO(49, 78, 122, 1),
    onPrimaryContainer: const Color.fromRGBO(255, 255, 255, 1),
    surface: const Color.fromRGBO(245, 245, 245, 1),
    secondary: const Color.fromRGBO(226, 232, 243, 1),
    secondaryContainer: const Color.fromRGBO(226, 232, 243, 1),
    onSecondaryContainer: const Color.fromRGBO(49, 78, 122, 1),
  ),
).useSystemChineseFont(Brightness.light);

final demoBlueDark = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  colorScheme: ColorScheme.fromSeed(
    brightness: Brightness.dark,
    seedColor: const Color.fromRGBO(17, 40, 64, 1), // Darker base color
    primary: const Color.fromARGB(252, 250, 243, 240),
    primaryContainer: const Color.fromRGBO(17, 40, 64, 1),
    onPrimaryContainer: const Color.fromRGBO(255, 255, 255, 1),
    surface: const Color.fromRGBO(20, 20, 20, 1), // Dark background
    secondary:
        const Color.fromRGBO(30, 30, 30, 1), // Slightly lighter secondary
    secondaryContainer: const Color.fromRGBO(30, 30, 30, 1),
    onSecondaryContainer: const Color.fromRGBO(255, 255, 255, 1),
  ),
).useSystemChineseFont(Brightness.dark);
