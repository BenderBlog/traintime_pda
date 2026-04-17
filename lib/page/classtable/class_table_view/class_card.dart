// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0 OR Apache-2.0

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:watermeter/model/xidian_ids/classtable.dart';
import 'package:watermeter/model/xidian_ids/exam.dart';
import 'package:watermeter/model/xidian_ids/experiment.dart';
import 'package:watermeter/page/classtable/class_add/class_add_window.dart';
import 'package:watermeter/page/classtable/class_table_view/class_organized_data.dart';
import 'package:watermeter/page/classtable/class_table_view/completed_class_style.dart';
import 'package:watermeter/page/classtable/arrangement_detail/arrangement_detail.dart';
import 'package:watermeter/page/classtable/classtable_state.dart';
import 'package:watermeter/page/public_widget/both_side_sheet.dart';
import 'package:watermeter/page/public_widget/public_widget.dart';

/// The card in [classSubRow], metioned in [ClassTableView].
class ClassCard extends StatelessWidget {
  final ClassOrgainzedData detail;
  final double completedHeight;

  List<dynamic> get data => detail.data;
  MaterialColor get color => detail.color;
  String get name => detail.name;
  String? get place => detail.place;
  const ClassCard({
    super.key,
    required this.detail,
    required this.completedHeight,
  });

  @override
  Widget build(BuildContext context) {
    ClassTableWidgetState classTableState = ClassTableState.of(
      context,
    )!.controllers;
    final activeStyle = CompletedClassStyle.resolve(
      palette: color,
      isCompleted: false,
    );
    final completedStyle = CompletedClassStyle.resolve(
      palette: color,
      isCompleted: true,
    );

    /// This is the result of the class info card.
    const borderRadius = BorderRadius.all(Radius.circular(8));
    return Padding(
      padding: const EdgeInsets.all(1),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final splitHeight = completedHeight.clamp(0.0, constraints.maxHeight);
            final isCompleted = splitHeight >= constraints.maxHeight - 0.5;
            final textStyle = isCompleted ? completedStyle : activeStyle;
            final borderStyle = isCompleted ? completedStyle : activeStyle;

            return Stack(
              fit: StackFit.expand,
              children: [
                if (splitHeight > 0)
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: splitHeight,
                    child: Container(
                      color: completedStyle.innerColor.withValues(
                        alpha: completedStyle.innerAlpha,
                      ),
                    ),
                  ),
                if (splitHeight < constraints.maxHeight)
                  Positioned(
                    top: splitHeight,
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      color: activeStyle.innerColor.withValues(
                        alpha: activeStyle.innerAlpha,
                      ),
                    ),
                  ),
                TextButton(
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    overlayColor: Colors.transparent,
                  ),
                  onPressed: () async {
                    var controller = ClassTableState.of(context)!.controllers;

                      /// The way to show the class info of the period.
                      /// The last one indicate whether to delete this stuff.
                      (ClassDetail, TimeArrangement, bool)? toUse =
                          await BothSideSheet.show(
                            title: FlutterI18n.translate(
                              context,
                              "classtable.class_card.title",
                            ),
                            child: ArrangementDetail(
                              information: List.generate(data.length, (index) {
                                if (data.elementAt(index) is Subject ||
                                    data.elementAt(index) is ExperimentData) {
                                  return data.elementAt(index);
                                } else {
                                  return (
                                    classTableState.getClassDetail(
                                      classTableState.timeArrangement.indexOf(
                                        data.elementAt(index),
                                      ),
                                    ),
                                    data.elementAt(index),
                                  );
                                }
                              }),
                              currentWeek: classTableState.currentWeek,
                            ),
                            context: context,
                          );
                      if (context.mounted && toUse != null) {
                        if (toUse.$3) {
                          await ClassTableState.of(
                            context,
                          )!.controllers.deleteUserDefinedClass(toUse.$2);
                        } else {
                          await Navigator.of(context)
                              .push(
                                MaterialPageRoute(
                                  builder: (context) => ClassAddWindow(
                                    toChange: (toUse.$1, toUse.$2),
                                    semesterLength: controller.semesterLength,
                                  ),
                                ),
                              )
                              .then((value) {
                                if (value == null) return;
                                controller.editUserDefinedClass(
                                  value.$1,
                                  value.$2,
                                  value.$3,
                                );
                              });
                        }
                      }
                  },
                  child:
                      Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Flexible(
                                child: Text(
                                  name,
                                  style: TextStyle(
                                    color: textStyle.textColor,
                                    fontSize: isPhone(context) ? 12 : 14,
                                  ),
                                  maxLines: 3,
                                  overflow: TextOverflow.clip,
                                ),
                              ),
                              Text(
                                "@${place ?? FlutterI18n.translate(context, "classtable.class_card.unknown_classroom")}",
                                style: TextStyle(
                                  color: textStyle.textColor,
                                  fontSize: isPhone(context) ? 10 : 12,
                                ),
                              ),
                              if (data.length > 1)
                                Text(
                                  FlutterI18n.translate(
                                    context,
                                    "classtable.class_card.remains_hint",
                                    translationParams: {
                                      "remain_count":
                                          (data.length - 1).toString(),
                                    },
                                  ),
                                  style: TextStyle(
                                    color: textStyle.textColor,
                                    fontSize: isPhone(context) ? 10 : 12,
                                  ),
                                ),
                            ],
                          )
                          .alignment(Alignment.topLeft)
                          .padding(
                            horizontal: isPhone(context) ? 2 : 4,
                            vertical: 4,
                          ),
                ),
                if (data.length > 1)
                  ClipPath(
                    clipper: Triangle(),
                    child: Container(
                      color: textStyle.borderColor,
                    ).constrained(width: 8, height: 8),
                  ).alignment(Alignment.topRight),
                Positioned.fill(
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: borderRadius,
                        border: Border.all(
                          color: borderStyle.borderColor.withValues(
                            alpha: borderStyle.borderAlpha,
                          ),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
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
