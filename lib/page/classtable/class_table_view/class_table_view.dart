// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0 OR Apache-2.0

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:watermeter/page/classtable/class_table_view/class_card.dart';
import 'package:watermeter/page/classtable/class_table_view/classtable_date_row.dart';
import 'package:watermeter/page/classtable/classtable_constant.dart';
import 'package:watermeter/page/classtable/classtable_state.dart';

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

class _ClassTableViewState extends State<ClassTableView> {
  late ClassTableState classTableState;
  late Size mediaQuerySize;

  /// The height is suitable to show 1-8 class, 9-10 are hidden at the bottom.
  double classTableContentHeight(int count) =>
      count * widget.constraint.minHeight / 8;

  /// The class table are divided into 8 rows, the leftest row is the index row.
  List<Widget> classSubRow(int index) {
    if (index != 0) {
      List<Widget> thisRow = [];

      /// Choice the day and render it!
      for (int i = 0; i < 10; ++i) {
        /// Places in the onTable array.
        int places =
            classTableState.pretendLayout[widget.index][index - 1][i].first;

        /// The length to render.
        int count = 1;
        Set<int> conflict =
            classTableState.pretendLayout[widget.index][index - 1][i].toSet();

        /// Decide the length to render. i limit the end.
        while (i < 9 &&
            classTableState
                    .pretendLayout[widget.index][index - 1][i + 1].first ==
                places) {
          count++;
          i++;
          conflict.addAll(classTableState.pretendLayout[widget.index][index - 1]
                  [i]
              .toSet());
        }

        /// Do not include empty spaces...
        conflict.remove(-1);

        /// Generate the row.
        thisRow.add(ClassCard(
          index: places,
          height: classTableContentHeight(count),
          conflict: conflict,
        ));
      }

      return thisRow;
    } else {
      /// Leftest side, the index array.
      return List.generate(
        10,
        (index) => SizedBox(
          width: leftRow,
          height: classTableContentHeight(1),
          child: Center(
            child: AutoSizeText(
              "${index + 1}",
              group: AutoSizeGroup(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.black,
              ),
            ),
          ),
        ),
      );
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    classTableState = ClassTableState.of(context)!;
    mediaQuerySize = MediaQuery.of(context).size;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        /// The main class table.
        ClassTableDateRow(
          firstDay: ClassTableState.of(context)!
              .startDay
              .add(
                Duration(days: 7 * ClassTableState.of(context)!.offset),
              )
              .add(
                Duration(days: 7 * widget.index),
              ),
        ),

        /// The rest of the table.
        Expanded(
          child: SingleChildScrollView(
            child: Row(
              children: List.generate(
                8,
                (i) => Container(
                  color: i == 0 ? Colors.grey.shade200.withOpacity(0.75) : null,
                  child: SizedBox(
                    width:
                        i > 0 ? (mediaQuerySize.width - leftRow) / 7 : leftRow,
                    child: Column(
                      children: classSubRow(i),
                    ),
                  ),
                ),
              ),
            ),
          ),
        )
      ],
    );
  }
}
