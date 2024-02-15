// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0 OR  Apache-2.0

import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:watermeter/model/xidian_ids/exam.dart';
import 'package:watermeter/page/classtable/class_table_view/class_organized_data.dart';
import 'package:watermeter/page/public_widget/both_side_sheet.dart';
import 'package:watermeter/page/classtable/arrangement_detail/arrangement_detail.dart';
import 'package:watermeter/page/classtable/classtable_state.dart';

/// The card in [classSubRow], metioned in [ClassTableView].
class ClassCard extends StatelessWidget {
  final ClassOrgainzedData detail;

  List<dynamic> get data => detail.data;
  MaterialColor get color => detail.color;
  String get name => detail.name;
  String? get place => detail.place;
  const ClassCard({
    super.key,
    required this.detail,
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
          padding: data.length == 1
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
                    title: "日程信息",
                    child: ArrangementDetail(
                      information: List.generate(data.length, (index) {
                        if (data.elementAt(index) is Subject) {
                          return data.elementAt(index);
                        } else {
                          return (
                            classTableState.getClassDetail(
                              classTableState.timeArrangement
                                  .indexOf(data.elementAt(index)),
                            ),
                            data.elementAt(index),
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
