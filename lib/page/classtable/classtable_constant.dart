import 'package:watermeter/generated/translations.g.dart';
// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0 OR Apache-2.0

// These are some constant used in the class table.

import 'package:flutter/material.dart';

/// The width of the button.
const weekButtonWidth = 74.0;

/// The horizontal padding of the button.
const weekButtonHorizontalPadding = 2.0;

/// The width ratio for the week column.
const double leftRow = 26;

/// The height of the top row.
const topRowHeightBig = 96.0;
const topRowHeightSmall = 50.0;

/// Change page time in milliseconds.
const changePageTime = 200;

/// The height of the middle row.
const midRowHeight = 54.0;

String getWeekString(BuildContext context, int index) {
  List weekList = [
    context.t.weekday.monday,
    context.t.weekday.tuesday,
    context.t.weekday.wednesday,
    context.t.weekday.thursday,
    context.t.weekday.friday,
    context.t.weekday.saturday,
    context.t.weekday.sunday,
  ];
  return weekList[index];
}
