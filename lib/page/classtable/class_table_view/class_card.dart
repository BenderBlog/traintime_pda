// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0 OR  Apache-2.0

import 'package:both_side_sheet/both_side_sheet.dart';
import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:watermeter/model/xidian_ids/exam.dart';
import 'package:watermeter/model/xidian_ids/experiment.dart';
import 'package:watermeter/page/classtable/class_table_view/class_organized_data.dart';
import 'package:watermeter/page/classtable/arrangement_detail/arrangement_detail.dart';
import 'package:watermeter/page/classtable/classtable_state.dart';
import 'package:watermeter/page/public_widget/public_widget.dart';

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
      padding: const EdgeInsets.all(1),
      child: ClipRRect(
        // Out
        borderRadius: BorderRadius.circular(8),
        child: Container(
          // Border
          color: color.shade300.withOpacity(0.8),
          padding: const EdgeInsets.all(2),
          child: Stack(
            children: [
              ClipRRect(
                // Inner
                borderRadius: BorderRadius.circular(6),
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
                            if (data.elementAt(index) is Subject ||
                                data.elementAt(index) is ExperimentData) {
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: color.shade900,
                            fontSize: isPhone(context) ? 12 : 14,
                          ),
                        ),
                        Text(
                          "@${place ?? "未知教室"}",
                          style: TextStyle(
                            color: color.shade900,
                            fontSize: isPhone(context) ? 10 : 12,
                          ),
                        ),
                        if (data.length > 1)
                          Text(
                            "还有${data.length - 1}个日程",
                            style: TextStyle(
                              color: color.shade900,
                              fontSize: isPhone(context) ? 10 : 12,
                            ),
                          ),
                      ],
                    ).alignment(Alignment.topLeft).padding(
                          horizontal: isPhone(context) ? 2 : 4,
                          vertical: 4,
                        ),
                  ),
                ),
              ),
              if (data.length > 1)
                ClipPath(
                  clipper: Triangle(),
                  child: Container(
                    color: color.shade300,
                  ).constrained(
                    width: 8,
                    height: 8,
                  ),
                ).alignment(Alignment.topRight),
            ],
          ),
        ),
      ),
    );
  }
}

class Triangle extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.addPolygon([
      const Offset(0, 0),
      Offset(size.width, 0),
      Offset(size.width, size.height),
    ], true);
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}
