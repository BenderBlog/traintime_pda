// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0 OR  Apache-2.0

import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:watermeter/model/xidian_ids/exam.dart';
import 'package:watermeter/page/public_widget/both_side_sheet.dart';
import 'package:watermeter/page/classtable/arrangement_detail/course_detail.dart';
import 'package:watermeter/page/classtable/classtable_state.dart';

/// The card in [classSubRow], metioned in [ClassTableView].
class ClassCard extends StatelessWidget {
  final List<dynamic> conflict;
  final MaterialColor color;
  final String name;
  final String? place;
  const ClassCard({
    super.key,
    required this.color,
    required this.name,
    required this.place,
    required this.conflict,
  });

  @override
  Widget build(BuildContext context) {
    ClassTableWidgetState classTableState =
        ClassTableState.of(context)!.controllers;

    /// This is the result of the class info card.
    return Padding(
      padding: const EdgeInsets.all(2),
      child: ClipRRect(
        // Out
        borderRadius: BorderRadius.circular(10),
        child: Container(
          // Border
          color: color.shade300.withOpacity(0.8),
          padding: conflict.length == 1
              ? const EdgeInsets.all(2)
              : const EdgeInsets.fromLTRB(2, 2, 2, 8),
          child: ClipRRect(
            // Inner
            borderRadius: BorderRadius.circular(8),
            child: Container(
              color: color.shade100.withOpacity(0.7),
              child: TextButton(
                style: ButtonStyle(
                  padding: MaterialStateProperty.resolveWith(
                    (status) => EdgeInsets.zero,
                  ),
                  overlayColor: MaterialStateProperty.resolveWith(
                    (status) => Colors.transparent,
                  ),
                ),
                onPressed: () {
                  /// The way to show the class info of the period.
                  BothSideSheet.show(
                    title: "课程信息",
                    child: ClassDetailPopUp(
                      information: List.generate(conflict.length, (index) {
                        if (conflict.elementAt(index) is Subject) {
                          return conflict.elementAt(index);
                        } else {
                          return (
                            classTableState.getClassDetail(
                              classTableState.timeArrangement
                                  .indexOf(conflict.elementAt(index)),
                            ),
                            conflict.elementAt(index),
                          );
                        }
                      }),
                      currentWeek: classTableState.currentWeek,
                    ),
                    context: context,
                  );
                },
                child: Text(
                  "$name\n${place ?? "未知教室"}",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: color.shade900,
                  ),
                ).center().padding(all: 2),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
