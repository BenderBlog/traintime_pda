// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0 OR Apache-2.0

// These are some constant used in the class table.

import 'package:material_ui/material_ui.dart';
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

/// The shortest one of the 61 blocks of a day may get.
///
/// A day is drawn with 61 blocks, of which a phone shows 48 at once, so a
/// block measures `(height - midRowHeight) / 48`. In a short window — a
/// floating window, a split screen, the landscape orientation — that would
/// squeeze a class into a couple of pixels and the text of its card would be
/// cut off, so the blocks keep this height and the table simply scrolls
/// further instead.
const double minBlockUnitHeight = 9.0;

/// The width below which a class card switches to smaller text.
///
/// Seven days have to fit next to the index row, which leaves narrow cards on
/// a phone sized window; with the regular sizes the name of a class would be
/// broken into one or two characters per line.
const double narrowClassCardWidth = 46.0;

/// The width below which a class card uses the smallest text it has.
const double tinyClassCardWidth = 32.0;

/// The height the blocks are scaled against by default, keeping card heights consistent
/// and independent of whether the week bar is docked or collapsed.
const double classTableHeightReference = 560.0;

/// 课表内容末尾留出的那点余地。
///
/// 滚到底时最后一节的下课时间会贴到面板底边、被自己的圆角切到，留一点就够它
/// 躲开；末尾的时间滑块也会停在该避让区域上方以避免遮挡文字。
const double classTableSheetEndGap = 20.0;

/// The blank strip the time line keeps above its first period.
///
/// Before the first class there is no block for the current time indicator to sit in: the top of
/// the grid *is* the 8:30 line, so the buoy lands on that label and reads as though the first
/// period had already started. This much room above period 1 gives it a place of its own at the
/// very top, level with the top edge of the table.
///
/// The floor is where the buoy's own bottom would meet the "8:30" label: the indicator hangs from
/// the top edge at `labelHeight / 2 + 1` and is `labelHeight` tall, while the first period already
/// pads its label 4.5 below the strip. With the default 13pt label that leaves about 9.5, so this
/// is deliberately close to the tightest it can be.
const double classTableTimeLineTopGap = 10.0;

/// The largest blur which can be applied to a user defined background image.
const double maxClassTableBackgroundBlur = 20.0;

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
