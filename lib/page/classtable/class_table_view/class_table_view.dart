// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0 OR Apache-2.0

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:styled_widget/styled_widget.dart';

import 'package:watermeter/model/xidian_ids/classtable.dart';
import 'package:watermeter/page/classtable/class_table_view/class_card.dart';
import 'package:watermeter/page/classtable/class_table_view/class_organized_data.dart';
import 'package:watermeter/page/classtable/class_table_view/classtable_date_row.dart';
import 'package:watermeter/page/classtable/classtable_constant.dart';
import 'package:watermeter/page/classtable/classtable_state.dart';
import 'package:watermeter/page/public_widget/public_widget.dart';
import 'package:watermeter/repository/preference.dart' as preference;

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
///  * Noon break 3 blocks
///  * Afternoon 5-8 each 5 blocks.
///  * Supper time 3 blocks.
///  * Evening time 9-11 each 5 blocks.
/// Total 61 parts, 49 as phone divider.
///
class _ClassTableViewState extends State<ClassTableView> {
  late ClassTableWidgetState classTableState;
  late BoxConstraints size;

  /// The height of the class card.
  double blockheight(double count) =>
      count *
      (widget.constraint.minHeight - midRowHeight) /
      (isPhone(context) ? 48 : 61);

  double get blockwidth => (size.maxWidth - leftRow) / 7;

  /// The class table are divided into 8 rows, the leftest row is the index row.
  List<Widget> classSubRow(bool isRest) {
    if (isRest) {
      List<Widget> thisRow = [];
      for (var index = 1; index <= 7; ++index) {
        List<ClassOrgainzedData> arrangedEvents = classTableState
            .getArrangement(weekIndex: widget.index, dayIndex: index);

        /// Choice the day and render it!
        for (var i in arrangedEvents) {
          /// Generate the row.
          thisRow.add(
            Positioned(
              top: blockheight(i.start),
              height: blockheight(i.stop - i.start),
              left: leftRow + blockwidth * (index - 1),
              width: blockwidth,
              child: ClassCard(detail: i),
            ),
          );
        }
      }

      if (thisRow.isEmpty &&
          !preference.getBool(preference.Preference.decorated)) {
        thisRow.add(
          Center(
            child: Column(
              children: [
                SizedBox(height: blockheight(8)),
                Image.asset("assets/art/pda_classtable_empty.png", scale: 2),
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

        return DefaultTextStyle.merge(
          style: const TextStyle(fontSize: 14, color: Colors.black87),
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
                    text: "${time[indexOfChar * 2]}\n",
                    style: const TextStyle(fontSize: 8),
                  ),
                  TextSpan(
                    text: time[indexOfChar * 2 + 1],
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
    classTableState = ClassTableState.of(context)!.controllers;
    classTableState.addListener(_reload);
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
                .decorated(color: Colors.grey.shade200.withValues(alpha: 0.75))
                .constrained(width: leftRow)
                .positioned(left: 0),
            ...classSubRow(true),
          ]
          .toStack()
          .constrained(height: blockheight(61), width: size.maxWidth)
          .scrollable()
          .expanded(),
    ].toColumn();
  }
}
