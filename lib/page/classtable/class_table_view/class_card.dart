// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0 OR  Apache-2.0

import 'package:flutter/material.dart';
import 'package:watermeter/page/public_widget/both_side_sheet.dart';
import 'package:watermeter/page/classtable/class_detail/class_detail.dart';
import 'package:watermeter/page/classtable/classtable_state.dart';
import 'package:watermeter/themes/color_seed.dart';

/// The card in [classSubRow], metioned in [ClassTableView].
class ClassCard extends StatelessWidget {
  final int index;
  final Set<int> conflict;
  final double height;
  const ClassCard({
    super.key,
    required this.height,
    required this.index,
    required this.conflict,
  });

  @override
  Widget build(BuildContext context) {
    ClassTableWidgetState classTableState =
        ClassTableState.of(context)!.controllers;

    Widget inside = index == -1
        ?

        /// A empty card used to occupy the place which have no class.
        const Padding(
            padding: EdgeInsets.all(2),

            /// Easter egg, usless you read the code,
            /// or reverse engineering...
            child: Center(
              child: Text(
                "BOCCHI RULES!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.transparent,
                  letterSpacing: 1,
                ),
              ),
            ),
          )
        : TextButton(
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
                  information: List.generate(
                    conflict.length,
                    (index) => (
                      classTableState.getClassDetail(conflict.elementAt(index)),
                      classTableState
                          .timeArrangement[conflict.elementAt(index)],
                    ),
                  ),
                  currentWeek: classTableState.currentWeek,
                ),
                context: context,
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(2),
              child: Center(
                child: Text(
                  "${classTableState.getClassDetail(index).name}\n"
                  "${classTableState.timeArrangement[index].classroom ?? "未知教室"}",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: index != -1
                        ? colorList[
                                classTableState.timeArrangement[index].index %
                                    colorList.length]
                            .shade900
                        : Colors.white,
                  ),
                ),
              ),
            ),
          );

    /// This is the result of the class info card.
    return SizedBox(
      height: height,
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: ClipRRect(
          // Out
          borderRadius: BorderRadius.circular(10),
          child: Container(
            // Border
            color: index == -1
                ? const Color(0x00000000)
                : colorList[classTableState.timeArrangement[index].index %
                        colorList.length]
                    .shade300
                    .withOpacity(0.8),
            padding: conflict.length == 1
                ? const EdgeInsets.all(2)
                : const EdgeInsets.fromLTRB(2, 2, 2, 8),
            child: ClipRRect(
              // Inner
              borderRadius: BorderRadius.circular(8),
              child: Container(
                color: index == -1
                    ? const Color(0x00000000)
                    : colorList[classTableState.timeArrangement[index].index %
                            colorList.length]
                        .shade100
                        .withOpacity(0.7),
                child: inside,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
