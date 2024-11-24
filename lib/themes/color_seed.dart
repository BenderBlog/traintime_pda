// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:watermeter/themes/default_color.dart';

/// Colors for the class information card.
const colorList = [
  Colors.red,
  Colors.pink,
  Colors.purple,
  Colors.deepPurple,
  Colors.indigo,
  Colors.blue,
  Colors.lightBlue,
  Colors.cyan,
  Colors.teal,
  Colors.green,
  Colors.lightGreen,
  Colors.lime,
  Colors.yellow,
  Colors.orange,
  Colors.deepOrange,
  Colors.brown,
];

/// Bright mode select
const demoBlueModeMap = {
  0: ThemeMode.system,
  1: ThemeMode.light,
  2: ThemeMode.dark,
};

List<FlexSchemeColor> pdaColorScheme = [
  DefaultColor.light,
  DefaultColor.dark,
  FlexScheme.blue.colors(Brightness.light),
  FlexScheme.blue.colors(Brightness.dark),
  FlexScheme.deepPurple.colors(Brightness.light),
  FlexScheme.deepPurple.colors(Brightness.dark),
  FlexScheme.green.colors(Brightness.light),
  FlexScheme.green.colors(Brightness.dark),
  FlexScheme.orangeM3.colors(Brightness.light),
  FlexScheme.orangeM3.colors(Brightness.dark),
  FlexScheme.sakura.colors(Brightness.light),
  FlexScheme.sakura.colors(Brightness.dark),
];

enum ColorSeed {
  indigo('default', 0),
  blue('blue', 1),
  deepPurple('deepPurple', 2),
  green('green', 3),
  orange('orange', 4),
  pink('pink', 5);

  const ColorSeed(this.label, this.colorOffset);
  final String label;
  final int colorOffset;
}

/// Colors for class information card which not in this week.
const uselessColor = Colors.grey;
