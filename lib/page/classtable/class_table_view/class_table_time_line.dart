// Copyright 2026 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

// The time line down the left side of the class table.

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:watermeter/model/time_list.dart';
import 'package:watermeter/page/classtable/class_table_view/glass_blur.dart';
import 'package:watermeter/page/classtable/class_table_view/glass_style.dart';
import 'package:watermeter/page/classtable/classtable_constant.dart';
import 'package:watermeter/page/public_widget/public_widget.dart';

/// Pixel height of [count] blocks of the class grid.
///
/// [available] is the height of the whole class table area. Scaling to it is what keeps a block the
/// same size in the grid, in the time line and in the settings preview.
double classTableBlockHeight(
  BuildContext context,
  double available,
  double count,
) =>
    count * (available - midRowHeight) / (isPhone(context) ? 48 : 61);

/// The time line: the period numbers with their start and end times.
///
/// It is laid out once for the whole table instead of once per week page, so it stays still while
/// the weeks page horizontally. It still moves with the vertical scroll, which the sheet owns.
class ClassTableTimeLine extends StatelessWidget {
  const ClassTableTimeLine({super.key, required this.available});

  /// The height of the class table area, used to scale the blocks.
  final double available;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        /// The panel. Frosted, like the other controls over the table: the wallpaper behind it is
        /// blurred inside the panel's own rounded bounds while it stays sharp everywhere else.
        ///
        /// Kept separate from the class-card blur group because this panel stays fixed above the
        /// scrolling grid and needs its own backdrop read on every vertical scroll frame.
        Positioned(
          left: timeLineInset,
          top: timeLineInset,
          bottom: timeLineInset,
          width: timeLineWidth,
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
          width: leftRow,
          child: Column(children: _labels(context)),
        ),
      ],
    );
  }

  /// Thirteen rows: eleven periods and the two breaks, sized in grid blocks.
  List<Widget> _labels(BuildContext context) {
    return List.generate(13, (index) {
      final double height = classTableBlockHeight(
        context,
        available,
        index != 4 && index != 9 ? 5 : 3,
      );

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

      return DefaultTextStyle.merge(
        style: TextStyle(
          fontSize: 14,
          color: Theme.of(context).colorScheme.onSurface,
        ),
        child: Text.rich(
          TextSpan(
            children: [
              if (indexOfChar == -1)
                TextSpan(
                  text: FlutterI18n.translate(
                    context,
                    "classtable.noon_break",
                  ),
                  style: const TextStyle(fontSize: 12),
                )
              else if (indexOfChar == -2)
                TextSpan(
                  text: FlutterI18n.translate(
                    context,
                    "classtable.supper_break",
                  ),
                  style: const TextStyle(fontSize: 12),
                )
              else ...[
                TextSpan(text: "${indexOfChar + 1}\n"),
                TextSpan(
                  text: "${timeList[indexOfChar * 2]}\n",
                  style: const TextStyle(fontSize: 8),
                ),
                TextSpan(
                  text: timeList[indexOfChar * 2 + 1],
                  style: const TextStyle(fontSize: 8),
                ),
              ],
            ],
          ),
          textAlign: TextAlign.center,
        ),
      ).center().constrained(width: leftRow, height: height);
    });
  }
}
