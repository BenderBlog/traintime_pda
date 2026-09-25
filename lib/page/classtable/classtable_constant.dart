// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0 OR Apache-2.0

// These are some constant used in the class table.

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

/// The width of the button.
const weekButtonWidth = 74.0;

/// The horizontal padding of the button.
const weekButtonHorizontalPadding = 2.0;

/// The width one week choice button occupies in the top row, padding included.
const double weekChoiceItemExtent =
    weekButtonWidth + 2 * weekButtonHorizontalPadding;

/// The width reserved for the time line down the left side of the class table.
///
/// Wide enough that the start/end times fit inside the floating panel once it takes its inset.
const double leftRow = 40;

/// Inset of the floating time-line panel from the edge of the table, on all four sides.
///
/// The panel is purely decorative: the time labels are laid out separately and keep the grid's full
/// height, so insetting the panel cannot push them out of step with the class blocks.
const double timeLineInset = 4;

/// Corner radius of the floating time-line panel.
const double timeLineRadius = 8;

/// Width of the floating time-line panel once it is inset.
const double timeLineWidth = leftRow - 2 * timeLineInset;

/// Opacity of the floating time-line panel. Kept below 1 so a decorated background still reads.
const double timeLineSurfaceAlpha = 0.95;

/// Opacity of the panel's drop shadow.
const double timeLineShadowAlpha = 0.18;

/// The height of the top row.
const topRowHeightBig = 96.0;
const topRowHeightSmall = 50.0;

/// Change page time in milliseconds.
const changePageTime = 200;

/// How long the collapsed week bar takes to pop out over the table, and to go away again.
const weekBarPopDuration = Duration(milliseconds: 180);

/// How long the page takes to make room once the week bar docks.
///
/// Slightly longer than the pop so the bar visibly settles into place first and the table follows,
/// instead of both moving at once.
const weekBarDockDuration = Duration(milliseconds: 260);

/// The height of the middle row.
const midRowHeight = 54.0;

String getWeekString(BuildContext context, int index) {
  List<String> weekList = [
    'monday',
    'tuesday',
    'wednesday',
    'thursday',
    'friday',
    'saturday',
    'sunday',
  ];
  return FlutterI18n.translate(context, "weekday.${weekList[index]}");
}
