// Copyright 2026 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

// The time line down the left side of the class table.

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:watermeter/model/time_list.dart';
import 'package:watermeter/page/classtable/class_table_view/class_table_time_column_layout.dart';
import 'package:watermeter/page/classtable/class_table_view/glass_blur.dart';
import 'package:watermeter/page/classtable/class_table_view/glass_style.dart';
import 'package:watermeter/page/classtable/classtable_constant.dart';
import 'package:watermeter/page/public_widget/public_widget.dart';

/// The height of one of the 61 blocks of a day.
///
/// [available] is the height of the whole class table area. Scaling to it is what keeps a block the
/// same size in the grid, in the time line and in the settings preview.
///
/// [minimumUnit] is the smallest a block may get. In a short window — a floating window, a split
/// screen, the landscape orientation — scaling alone would squeeze a class into a couple of pixels
/// and the text of its card would be cut off; the table then grows past the window and scrolls
/// instead. The time line measures the least room its own labels need and hands it in.
double classTableBlockUnit(
  BuildContext context,
  double available, {
  double minimumUnit = 0,
}) => math.max(
  (available - midRowHeight) / (isPhone(context) ? 48 : 61),
  minimumUnit,
);

/// The time line: the period numbers with their start and end times.
///
/// It is laid out once for the whole table instead of once per week page, so it stays still while
/// the weeks page horizontally. It still moves with the vertical scroll, which the sheet owns.
class ClassTableTimeLine extends StatelessWidget {
  const ClassTableTimeLine({
    super.key,
    required this.timeColumnWidth,
    required this.blockUnit,
  });

  /// The width of the time column, measured from the labels themselves so they are not clipped at a
  /// large font scale.
  final double timeColumnWidth;

  /// The height of one of the 61 blocks of a day.
  final double blockUnit;

  /// The width of the floating panel once it is inset from the column's edges.
  double get _panelWidth => timeColumnWidth - 2 * timeLineInset;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        /// The panel. Frosted, like the other controls over the table: the wallpaper behind it is
        /// blurred inside the panel's own rounded bounds while it stays sharp everywhere else.
        ///
        /// Grouped with the other controls under [BackdropGroup] because this panel sits alongside
        /// the class cards without overlapping them (x: [4, 36] vs x: [40, width]), allowing a single
        /// blur pass for the entire table.
        Positioned(
          left: timeLineInset,
          top: 0,
          bottom: 0,
          width: _panelWidth,
          child: DecoratedBox(
            /// The shadow is painted outside the clip so it is not blurred away with the backdrop.
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(timeLineRadius),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: timeLineShadowAlpha),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: GlassBlur(
              borderRadius: BorderRadius.circular(timeLineRadius),
              sigma: GlassStyleConfig.timeLineSigma,
              grouped: true,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHigh
                      .withValues(alpha: timeLineSurfaceAlpha),
                  borderRadius: BorderRadius.circular(timeLineRadius),
                ),
              ),
            ),
          ),
        ),

        /// The labels keep the grid's full height, so each row stays aligned with its blocks.
        Positioned(
          left: 0,
          top: 0,
          width: timeColumnWidth,
          child: Column(children: _labels(context)),
        ),
      ],
    );
  }

  /// Thirteen rows: eleven periods and the two breaks, sized in grid blocks.
  List<Widget> _labels(BuildContext context) {
    final layout = ClassTableTimeColumnLayout.of(context);
    return List.generate(13, (index) {
      final double height = blockUnit * (index != 4 && index != 9 ? 5 : 3);

      late int indexOfChar;
      if ([0, 1, 2, 3].contains(index)) {
        indexOfChar = index;
      } else if (index == 4) {
        indexOfChar = -1; // noon break
      } else if ([5, 6, 7, 8].contains(index)) {
        indexOfChar = index - 1;
      } else if (index == 9) {
        indexOfChar = -2; // supper break
      } else {
        //if ([10, 11, 12].contains(index))
        indexOfChar = index - 2;
      }

      final Widget cell;
      if (indexOfChar == -1 || indexOfChar == -2) {
        cell = Center(
          child: Text(
            FlutterI18n.translate(
              context,
              indexOfChar == -1
                  ? "classtable.noon_break"
                  : "classtable.supper_break",
            ),
            style: layout.breakStyle,
            textAlign: TextAlign.center,
          ),
        );
      } else {
        final bool isFirstPeriod = indexOfChar == 0;
        final bool isLastPeriod = indexOfChar == 10;
        final EdgeInsets cellPadding = isFirstPeriod
            ? const EdgeInsets.only(top: 4.5, bottom: 1.0)
            : isLastPeriod
            ? const EdgeInsets.only(top: 1.0, bottom: 4.5)
            : const EdgeInsets.symmetric(vertical: 1.0);

        cell = Padding(
          padding: cellPadding,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                timeList[indexOfChar * 2],
                style: layout.timeStyle,
                textAlign: TextAlign.center,
                maxLines: 1,
                softWrap: false,
              ),
              Text(
                "${indexOfChar + 1}",
                style: layout.periodStyle,
                textAlign: TextAlign.center,
                maxLines: 1,
                softWrap: false,
              ),
              Text(
                timeList[indexOfChar * 2 + 1],
                style: layout.timeStyle,
                textAlign: TextAlign.center,
                maxLines: 1,
                softWrap: false,
              ),
            ],
          ),
        );
      }

      return SizedBox(
        width: timeColumnWidth,
        height: height,
        child: cell,
      );
    });
  }
}
