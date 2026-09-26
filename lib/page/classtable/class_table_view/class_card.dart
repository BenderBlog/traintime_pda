// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0 OR Apache-2.0

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:watermeter/model/pda_service/custom_class.dart';
import 'package:watermeter/model/xidian_ids/classtable.dart';
import 'package:watermeter/model/xidian_ids/exam.dart';
import 'package:watermeter/model/xidian_ids/experiment.dart';
import 'package:watermeter/page/classtable/class_add/class_add_window.dart';
import 'package:watermeter/page/classtable/class_table_view/class_organized_data.dart';
import 'package:watermeter/page/classtable/class_table_view/completed_class_style.dart';
import 'package:watermeter/page/classtable/class_table_view/glass_blur.dart';
import 'package:watermeter/page/classtable/class_table_view/glass_style.dart';
import 'package:watermeter/page/classtable/arrangement_detail/arrangement_detail.dart';
import 'package:watermeter/page/classtable/classtable_state.dart';
import 'package:watermeter/page/public_widget/both_side_sheet.dart';
import 'package:watermeter/page/public_widget/public_widget.dart';

/// The card in [classSubRow], mentioned in [ClassTableView].
class ClassCard extends StatelessWidget {
  final ClassOrgainzedData detail;
  final double completedHeight;

  /// The height inside the card's padding, which the completed split is measured against.
  ///
  /// Handed in rather than measured: a [LayoutBuilder] rebuilds its subtree during layout
  /// whenever its constraints change, which is every frame of a drag or a scroll, for every card
  /// on screen. [ClassTableView] already knows the height it positioned the card at.
  final double height;

  List<dynamic> get data => detail.data;
  MaterialColor get color => detail.color;
  String get name => detail.name;
  String? get place => detail.place;
  const ClassCard({
    super.key,
    required this.detail,
    required this.completedHeight,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    final classTableState = ClassTableState.of(context)!.controllers;
    final activeStyle = CompletedClassStyle.resolve(
      palette: color,
      isCompleted: false,
    );
    final completedStyle = CompletedClassStyle.resolve(
      palette: color,
      isCompleted: true,
    );
    final isInteractive = classTableState.isClassCardInteractive(detail);
    final bool isPhoneDevice = isPhone(context);

    const borderRadius = BorderRadius.all(Radius.circular(8));
    return Padding(
      padding: const EdgeInsets.all(1),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: Builder(
          builder: (context) {
            final splitHeight = completedHeight.clamp(0.0, height);
            final isCompleted = splitHeight >= height - 0.5;
            final textStyle = isCompleted ? completedStyle : activeStyle;
            final borderStyle = isCompleted ? completedStyle : activeStyle;

            return Stack(
              fit: StackFit.expand,
              children: [
                /// The frosted background: a real backdrop blur of the wallpaper behind the card.
                ///
                /// Grouped with the other cards, so a whole tableful shares one blur of the same
                /// backdrop.
                Positioned.fill(
                  child: GlassBlur(
                    grouped: true,
                    sigma: GlassStyleConfig.cardSigma,
                    child: const SizedBox.expand(),
                  ),
                ),
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
                if (splitHeight < height)
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
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: isInteractive
                      ? () async {
                          final controller = ClassTableState.of(
                            context,
                          )!.controllers;

                          /// The way to show the class info of the period.
                          /// The last one indicate whether to delete this stuff.
                          final action = await BothSideSheet.show(
                            title: FlutterI18n.translate(
                              context,
                              "classtable.class_card.title",
                            ),
                            child: ArrangementDetail(
                              information: List.generate(data.length, (index) {
                                if (data.elementAt(index) is Subject ||
                                    data.elementAt(index) is ExperimentData) {
                                  return data.elementAt(index);
                                } else if (data.elementAt(index)
                                    is (
                                      CustomClass,
                                      CustomClassTimeRange,
                                      MaterialColor,
                                    )) {
                                  return data.elementAt(index);
                                } else if (data.elementAt(index)
                                    is (CustomClass, CustomClassTimeRange)) {
                                  return data.elementAt(index);
                                } else if (data.elementAt(index)
                                    is TimeArrangement) {
                                  final TimeArrangement arrangement = data
                                      .elementAt(index);
                                  return (
                                    classTableState.getClassDetail(
                                      classTableState.timeArrangement.indexOf(
                                        arrangement,
                                      ),
                                    ),
                                    arrangement,
                                  );
                                } else {
                                  return data.elementAt(index);
                                }
                              }),
                              currentWeek: classTableState.currentWeek,
                            ),
                            context: context,
                          );
                          if (!context.mounted || action == null) return;

                          if (action is (String, String?, String)) {
                            final int customIndex = controller.customClasses
                                .indexWhere((custom) => custom.id == action.$1);
                            if (customIndex < 0) return;

                            if (action.$3 == 'delete_all') {
                              await controller.deleteCustomClassById(action.$1);
                            } else if (action.$3 == 'delete_one') {
                              final String? timeRangeId = action.$2;
                              if (timeRangeId == null) return;
                              await controller.deleteCustomClassTimeRange(
                                customClassId: action.$1,
                                timeRangeId: timeRangeId,
                              );
                            } else if (action.$3 == 'edit') {
                              final CustomClass customClass =
                                  controller.customClasses[customIndex];
                              await Navigator.of(context)
                                  .push(
                                    MaterialPageRoute(
                                      builder: (context) => ClassAddWindow(
                                        customToChange: customClass,
                                        semesterLength:
                                            controller.semesterLength,
                                      ),
                                    ),
                                  )
                                  .then((value) async {
                                    if (value is CustomClass) {
                                      await controller.editCustomClassById(
                                        action.$1,
                                        value,
                                      );
                                    }
                                  });
                            }
                          }
                        }
                      : null,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isPhoneDevice ? 2 : 4,
                      vertical: 4,
                    ),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Flexible(
                            child: Text(
                              name,
                              style: TextStyle(
                                color: textStyle.textColor,
                                fontSize: isPhoneDevice ? 12 : 14,
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.clip,
                            ),
                          ),
                          Text(
                            "@${place ?? FlutterI18n.translate(context, "classtable.class_card.unknown_classroom")}",
                            style: TextStyle(
                              color: textStyle.textColor,
                              fontSize: isPhoneDevice ? 10 : 12,
                            ),
                          ),
                          if (data.length > 1)
                            Text(
                              FlutterI18n.translate(
                                context,
                                "classtable.class_card.remains_hint",
                                translationParams: {
                                  "remain_count": (data.length - 1).toString(),
                                },
                              ),
                              style: TextStyle(
                                color: textStyle.textColor,
                                fontSize: isPhoneDevice ? 10 : 12,
                              ),
                            ),
                        ],
                      ),
                    ),
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
    final path = Path();
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
