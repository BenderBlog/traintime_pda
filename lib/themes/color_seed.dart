// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';

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

/// App Color patten.
/// Copied from https://github.com/flutter/samples/blob/main/material_3_demo/lib/constants.dart
enum ColorSeed {
  indigo('default', FlexScheme.indigo),
  blue('blue', FlexScheme.blue),
  deepPurple('deepPurple', FlexScheme.deepPurple),
  green('green', FlexScheme.green),
  orange('orange', FlexScheme.orangeM3),
  pink('pink', FlexScheme.sakura);

  const ColorSeed(this.label, this.color);
  final String label;
  final FlexScheme color;
}

/// Colors for class information card which not in this week.
const uselessColor = Colors.grey;
