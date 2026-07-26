import 'package:watermeter/generated/l10n.dart';
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
    I18n.of(context)!.weekdayMonday,
    I18n.of(context)!.weekdayTuesday,
    I18n.of(context)!.weekdayWednesday,
    I18n.of(context)!.weekdayThursday,
    I18n.of(context)!.weekdayFriday,
    I18n.of(context)!.weekdaySaturday,
    I18n.of(context)!.weekdaySunday,
  ];
  return weekList[index];
}
