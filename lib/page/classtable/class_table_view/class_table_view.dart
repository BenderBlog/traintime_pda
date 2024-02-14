// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0 OR Apache-2.0

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:auto_size_text/auto_size_text.dart';

import 'package:watermeter/model/xidian_ids/classtable.dart';
import 'package:watermeter/page/classtable/class_table_view/class_card.dart';
import 'package:watermeter/page/classtable/class_table_view/class_organized_data.dart';
import 'package:watermeter/page/classtable/class_table_view/classtable_date_row.dart';
import 'package:watermeter/page/classtable/classtable_constant.dart';
import 'package:watermeter/page/classtable/classtable_state.dart';
import 'package:watermeter/page/public_widget/public_widget.dart';

/// THe classtable view, the way the the classtable sheet rendered.
class ClassTableView extends StatefulWidget {
  final int index;
  final BoxConstraints constraint;

  const ClassTableView({
    super.key,
    required this.constraint,
    required this.index,
  });

  @override
  State<ClassTableView> createState() => _ClassTableViewState();
}

///
/// Classtable blanks below per blocks.
///  * Morning 1-4 each 5 blocks.
///  * Noon break 2 blocks, means 12:00, 13:00, 14:00,
///  * Afternoon 5-8 each 5 blocks.
///  * Supper time 3 blocks, means 17:30, 18:00, 18:30, 19:00.
///  * Evening time 9-11 each 5 blocks.
/// Total 60 parts, 48 as phone divider.
///
class _ClassTableViewState extends State<ClassTableView> {
  late ClassTableWidgetState classTableState;
  late Size mediaQuerySize;

  /// The height of the class card.
  double blockheight(double count) =>
      count *
      (widget.constraint.minHeight - midRowHeightVertical) /
      (isPhone(context) ? 48 : 60);

  double get blockwidth => (mediaQuerySize.width - leftRow) / 7;

  bool _checkIsOverlapping(
    double eStart1,
    double eEnd1,
    double eStart2,
    double eEnd2,
  ) =>
      (eStart1 >= eStart2 && eStart1 < eEnd2) ||
      (eEnd1 > eStart2 && eEnd1 <= eEnd2) ||
      (eStart2 >= eStart1 && eStart2 < eEnd1) ||
      (eEnd2 > eStart1 && eEnd2 <= eEnd1);

  /// The class table are divided into 8 rows, the leftest row is the index row.
  List<Widget> classSubRow(int index) {
    if (index != 0) {
      /// Fetch all class in this range
      List<ClassOrgainzedData> events = [];
      for (final i in classTableState.timeArrangement) {
        if (i.weekList.length > widget.index &&
            i.weekList[widget.index] &&
            i.day == index) {
          events.add(ClassOrgainzedData.fromTimeArrangement(
            i,
            classTableState
                .getClassDetail(classTableState.timeArrangement.indexOf(i))
                .name,
          ));
        }
      }

      for (final i in classTableState.subjects) {
        int diff = i.startTime
            .diff(Jiffy.parseFromDateTime(classTableState.startDay),
                unit: Unit.day)
            .toInt();

        if (diff ~/ 7 == widget.index && diff % 7 + 1 == index) {
          events.add(ClassOrgainzedData.fromSubject(i));
        }
      }

      /// TODO: Add Experiment

      /// Sort it with the ascending order of start time.
      events.sort((a, b) => a.start.compareTo(b.start));

      /// The arrangement to use
      List<ClassOrgainzedData> arrangedEvents = [];
      List<Widget> thisRow = [];

      for (final event in events) {
        final startTime = event.start;
        final endTime = event.stop;

        var eventIndex = -1;
        final arrangeEventLen = arrangedEvents.length;

        for (var i = 0; i < arrangeEventLen; i++) {
          final arrangedEventStart = arrangedEvents[i].start;
          final arrangedEventEnd = arrangedEvents[i].stop;

          if (_checkIsOverlapping(
              arrangedEventStart, arrangedEventEnd, startTime, endTime)) {
            eventIndex = i;
            break;
          }
        }

        if (eventIndex == -1) {
          arrangedEvents.add(event);
        } else {
          final arrangedEventData = arrangedEvents[eventIndex];

          final arrangedEventStart = arrangedEventData.start;
          final arrangedEventEnd = arrangedEventData.stop;

          final startDuration = math.min(startTime, arrangedEventStart);
          final endDuration = math.max(endTime, arrangedEventEnd);

          bool shouldNew = (event.stop - event.start) >=
              (arrangedEventData.stop - arrangedEventData.start);

          final top = startDuration;
          // TODO: check whether it is good.
          final bottom = endDuration;

          final newEvent = ClassOrgainzedData(
            start: top,
            stop: bottom,
            data: [
              ...arrangedEventData.data,
              ...event.data,
            ],
            name: shouldNew ? event.name : arrangedEventData.name,
            place: shouldNew ? event.place : arrangedEventData.place,
          );

          arrangedEvents[eventIndex] = newEvent;
        }
      }

      /// Choice the day and render it!
      for (var i in arrangedEvents) {
        /// Generate the row.
        thisRow.add(Positioned(
          top: blockheight(i.start),
          height: blockheight(i.stop - i.start),
          left: leftRow + blockwidth * (index - 1),
          width: blockwidth,
          child: ClassCard(
            color: Colors.blue,
            conflict: i.data,
            name: i.name,
            place: i.place,
          ),
        ));
      }

      return thisRow;
    } else {
      /// Leftest side, the index array.
      return List.generate(13, (index) {
        double height = blockheight(
          index == 4
              ? 2
              : index == 10
                  ? 3
                  : 5,
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

        return SizedBox(
          width: leftRow,
          height: height,
          child: Center(
            child: AutoSizeText.rich(
              TextSpan(children: [
                if (indexOfChar == -1)
                  const TextSpan(
                    text: "午休",
                    style: TextStyle(fontSize: 10),
                  )
                else if (indexOfChar == -2)
                  const TextSpan(
                    text: "晚饭",
                    style: TextStyle(fontSize: 10),
                  )
                else ...[
                  TextSpan(
                    text: "${indexOfChar + 1}\n",
                    style: const TextStyle(fontSize: 10),
                  ),
                  TextSpan(
                    text: "${time[indexOfChar * 2]}\n",
                    style: TextStyle(
                      fontSize: 8,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  TextSpan(
                    text: time[indexOfChar * 2 + 1],
                    style: TextStyle(
                      fontSize: 8,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ]),
              group: AutoSizeGroup(),
              textAlign: TextAlign.center,
              minFontSize: 6,
            ),
          ),
        );
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    classTableState = ClassTableState.of(context)!.controllers;
    mediaQuerySize = MediaQuery.of(context).size;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        /// The main class table.
        ClassTableDateRow(
          firstDay: classTableState.startDay
              .add(Duration(days: 7 * classTableState.offset))
              .add(Duration(days: 7 * widget.index)),
        ),

        /// The rest of the table.
        Stack(
          children: [
            Container(
              color: Colors.grey.shade200.withOpacity(0.75),
              width: leftRow,
              child: classSubRow(0).toColumn(),
            ).positioned(left: 0),
            for (int i in List.generate(7, (i) => i + 1)) ...classSubRow(i),
          ],
        )
            .constrained(
              height: blockheight(60),
              width: mediaQuerySize.width,
            )
            .scrollable()
            .expanded(),
      ],
    );
  }
}
