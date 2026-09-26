// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0 OR Apache-2.0

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:watermeter/model/time_list.dart';

import 'package:watermeter/page/classtable/class_table_view/class_card.dart';
import 'package:watermeter/page/classtable/class_table_view/class_organized_data.dart';
import 'package:watermeter/page/classtable/class_table_view/classtable_date_row.dart';
import 'package:watermeter/page/classtable/class_table_view/current_time_indicator.dart';
import 'package:watermeter/page/classtable/classtable_constant.dart';
import 'package:watermeter/page/classtable/classtable_state.dart';
import 'package:watermeter/page/public_widget/public_widget.dart';
import 'package:watermeter/repository/preference.dart' as preference;

/// THe classtable view, the way the the classtable sheet rendered.
class ClassTableView extends StatefulWidget {
  final int index;
  final BoxConstraints constraint;
  final bool enableVerticalScrolling;

  const ClassTableView({
    super.key,
    required this.constraint,
    required this.index,
    this.enableVerticalScrolling = true,
  });

  @override
  State<ClassTableView> createState() => _ClassTableViewState();
}

///
/// Classtable blanks below per blocks.
///  * Morning 1-4 each 5 blocks.
///  * Noon break 3 blocks
///  * Afternoon 5-8 each 5 blocks.
///  * Supper time 3 blocks.
///  * Evening time 9-11 each 5 blocks.
/// Total 61 parts, 49 as phone divider.
///
class _ClassTableViewState extends State<ClassTableView> {
  late ClassTableWidgetState classTableState;
  late BoxConstraints size;
  bool _isListening = false;

  DateTime get _visibleWeekStart => classTableState.startDay
      .add(Duration(days: 7 * classTableState.offset))
      .add(Duration(days: 7 * widget.index));

  double _completedHeight(ClassOrgainzedData data, int dayIndex) {
    final now = classTableState.currentTime;
    final dayStart = _visibleWeekStart.add(Duration(days: dayIndex - 1));
    final today = DateTime(now.year, now.month, now.day);

    if (today.isBefore(dayStart)) {
      return 0;
    }
    if (today.isAfter(dayStart)) {
      return blockheight(data.stop - data.start);
    }

    final currentIndex = CurrentTimeIndicator.transferTimeToBlockIndex(now);
    if (currentIndex <= data.start) {
      return 0;
    }

    final completedBlocks = (currentIndex - data.start).clamp(
      0.0,
      data.stop - data.start,
    );
    return blockheight(completedBlocks);
  }

  Positioned? _currentTimeIndicator() => CurrentTimeIndicator.build(
    context: context,
    now: classTableState.currentTime,
    weekStart: _visibleWeekStart,
    leftRow: leftRow,
    blockWidth: blockwidth,
    blockHeight: blockheight,
  );

  Positioned? _currentDayColumnBox() => CurrentTimeIndicator.buildDayColumnBox(
    context: context,
    now: classTableState.currentTime,
    weekStart: _visibleWeekStart,
    leftRow: leftRow,
    blockWidth: blockwidth,
    blockHeight: blockheight,
  );

  /// The height of one of the 61 blocks of a day.
  ///
  /// It never falls below [minBlockUnitHeight]: in a window which is much
  /// shorter than the display of a phone the blocks would otherwise be squeezed
  /// until the cards of the classes lose their text.
  double get _blockUnit => math.max(
    (widget.constraint.minHeight - midRowHeight) / (isPhone(context) ? 48 : 61),
    minBlockUnitHeight,
  );

  /// The height of the class card.
  double blockheight(double count) => count * _blockUnit;

  double get blockwidth => (size.maxWidth - leftRow) / 7;

  /// The class table are divided into 8 rows, the leftest row is the index row.
  List<Widget> classSubRow(bool isRest) {
    if (isRest) {
      List<Widget> thisRow = [];
      final currentDayColumnBox = _currentDayColumnBox();
      if (currentDayColumnBox != null) {
        thisRow.add(currentDayColumnBox);
      }

      for (var index = 1; index <= 7; ++index) {
        List<ClassOrgainzedData> arrangedEvents = classTableState
            .getArrangement(weekIndex: widget.index, dayIndex: index);

        /// Choice the day and render it!
        for (var i in arrangedEvents) {
          /// Generate the row.
          final completedHeight = _completedHeight(i, index);
          thisRow.add(
            Positioned(
              top: blockheight(i.start),
              height: blockheight(i.stop - i.start),
              left: leftRow + blockwidth * (index - 1),
              width: blockwidth,
              child: ClassCard(detail: i, completedHeight: completedHeight),
            ),
          );
        }
      }

      final timeIndicator = _currentTimeIndicator();
      if (timeIndicator != null) {
        thisRow.add(timeIndicator);
      }

      if (thisRow.isEmpty &&
          !preference.getBool(preference.Preference.decorated)) {
        thisRow.add(
          Center(
            child: Column(
              children: [
                SizedBox(height: blockheight(8)),
                Image.asset("assets/art/pda_classtable_empty.webp", scale: 2),
                const SizedBox(height: 20),
                ...FlutterI18n.translate(
                  context,
                  "classtable.no_class",
                ).split("\n").map((e) => Text(e)),
              ],
            ),
          ).padding(left: leftRow),
        );
      }

      return thisRow;
    } else {
      /// Leftest side, the index array.
      return List.generate(13, (index) {
        double height = blockheight(index != 4 && index != 9 ? 5 : 3);

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

        /// 每一节的上下课时间贴着这一格的上下边，节次写在中间。
        ///
        /// 三行都挤在格子中间时，当前时间线落在格子的哪一段是看不出来的 ——
        /// 它压在中间那几行字上，很容易被读成压在两个节次的分界上。贴着边写，
        /// 线夹在哪两条时间之间，就是哪一节。
        final Widget cell;
        if (indexOfChar == -1 || indexOfChar == -2) {
          cell = Text(
            FlutterI18n.translate(
              context,
              indexOfChar == -1
                  ? "classtable.noon_break"
                  : "classtable.supper_break",
            ),
            style: const TextStyle(fontSize: 12),
            textAlign: TextAlign.center,
          ).center();
        } else {
          cell = Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                timeList[indexOfChar * 2],
                style: const TextStyle(fontSize: 8),
                textAlign: TextAlign.center,
              ),
              Text("${indexOfChar + 1}", textAlign: TextAlign.center),
              Text(
                timeList[indexOfChar * 2 + 1],
                style: const TextStyle(fontSize: 8),
                textAlign: TextAlign.center,
              ),
            ],
          );
        }

        return DefaultTextStyle.merge(
          style: TextStyle(
            fontSize: 14,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          child: SizedBox(width: leftRow, height: height, child: cell),
        );
      });
    }
  }

  /// This function will be triggered when user changed class info.
  void _reload() {
    if (mounted) {
      setState(() {});
    }
  }

  void updateSize() => size = ClassTableState.of(context)!.constraints;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isListening) {
      classTableState = ClassTableState.of(context)!.controllers;
      classTableState.addListener(_reload);
      _isListening = true;
    }
    updateSize();
  }

  @override
  void dispose() {
    classTableState.removeListener(_reload);
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant ClassTableView oldWidget) {
    super.didUpdateWidget(oldWidget);
    updateSize();
  }

  @override
  Widget build(BuildContext context) {
    return [
      /// The main class table.
      ClassTableDateRow(
        firstDay: classTableState.startDay
            .add(Duration(days: 7 * classTableState.offset))
            .add(Duration(days: 7 * widget.index)),
      ),

      /// The rest of the table.
      [
            classSubRow(false)
                .toColumn()
                .decorated(
                  color: Theme.of(
                    context,
                  ).colorScheme.surface.withValues(alpha: 0.75),
                )
                .constrained(width: leftRow)
                .positioned(left: 0),
            ...classSubRow(true),
          ]
          .toStack()
          .constrained(height: blockheight(61), width: size.maxWidth)
          .scrollable(
            /// The safe area of the screen is handled by the page which hosts
            /// the table, the sheet itself only has to be scrollable here.
            physics: widget.enableVerticalScrolling
                ? null
                : const NeverScrollableScrollPhysics(),
          )
          .expanded(),
    ].toColumn();
  }
}
