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

/// The inset of a week button's card inside its slot: the slot's margin plus the card's own.
const double weekChoiceCardInset = weekButtonHorizontalPadding + 4;

/// The vertical margin of a week button's card inside its slot.
const double weekChoiceCardMargin = 4;

/// Corner radius of a week button, matching the Material 3 card radius.
const double weekChoiceCardRadius = 12;

/// Alpha of the box behind the week button on show.
const double weekChoiceHighlightAlpha = 0.3;

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

/// Opacity of the floating time-line panel. Kept well below 1 so the blurred wallpaper underneath
/// reads through it: that, not a filter of its own, is what makes the panel look like frosted glass.
const double timeLineSurfaceAlpha = 0.72;

/// Opacity of the panel's drop shadow.
const double timeLineShadowAlpha = 0.18;

/// Opacity of the week bar's own tint, over its blurred backdrop.
///
/// Lower than the other panels on purpose: the strip behind the docked bar is the smoothest part of
/// the wallpaper, so there is little detail for the blur to soften there. Letting more of the
/// wallpaper's own colour through is what makes the bar read as glass instead of flat paint.
const double weekBarSurfaceAlpha = 0.42;

/// Opacity of the inline status banner's tint, over its blurred backdrop.
///
/// Higher than the week bar's: the banner carries two lines of small text, so it keeps more of its
/// own surface under them for contrast.
const double bannerSurfaceAlpha = 0.6;

/// Blur of the controls' own backgrounds, in logical pixels.
///
/// This is what makes a class card, the time line panel or the week bar look like frosted glass: the
/// wallpaper and the table behind the control stay sharp, only the control's background is blurred.
/// Controls that never overlap share one blur of the backdrop through a [BackdropGroup], so a table
/// full of cards still costs a single blur rather than one per card.
const double glassBlurSigma = 12;

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
