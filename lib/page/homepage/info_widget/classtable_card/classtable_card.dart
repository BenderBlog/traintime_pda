// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:timelines/timelines.dart';
import 'package:watermeter/controller/classtable_controller.dart';
import 'package:watermeter/page/classtable/classtable.dart';
import 'package:watermeter/page/homepage/info_widget/classtable_card/classtable_arrangement.dart';
import 'package:watermeter/page/homepage/info_widget/classtable_card/classtable_current.dart';
import 'package:watermeter/page/public_widget/public_widget.dart';
import 'package:styled_widget/styled_widget.dart';

class ClassTableCard extends StatelessWidget {
  const ClassTableCard({super.key});

  @override
  Widget build(BuildContext context) {
    Widget withCardStyle(Widget w) {
      w = w.paddingDirectional(
        horizontal: 16,
        vertical: 14,
      );

      if (isPhone(context)) {
        w = w
            .backgroundColor(
              Theme.of(context).colorScheme.secondary,
            )
            .clipRRect(all: 12);
      } else {
        w = w.decorated(
          border: Border.all(
            width: 3,
            color: Theme.of(context).colorScheme.primary,
          ),
          borderRadius: BorderRadius.circular(26),
        );
      }

      return w.paddingAll(4);
    }

    return GetBuilder<ClassTableController>(
      builder: (c) => GestureDetector(
        onTap: () {
          try {
            if (c.isGet == true) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const ClassTableWindow(),
                ),
              );
            } else {
              Fluttertoast.showToast(msg: "正在获取课表");
            }
          } on String catch (e) {
            Fluttertoast.showToast(msg: "遇到错误：${e.substring(0, 150)}");
          }
        },
        child: withCardStyle(Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Row(
            //   crossAxisAlignment: CrossAxisAlignment.center,
            //   children: [
            //     Icon(
            //       Icons.access_time_filled,
            //       color: Theme.of(context).colorScheme.primary,
            //       size: 16,
            //     ),
            //     const SizedBox(width: 8),
            //     Text(
            //       c.isGet == true
            //           ? c.currentData.$3 == null
            //               ? "课程表"
            //               : c.currentData.$3 == true
            //                   ? "课程表 下一节课是"
            //                   : "课程表 正在进行"
            //           : "课程表",
            //       style: TextStyle(
            //         fontSize: 16,
            //         textBaseline: TextBaseline.alphabetic,
            //         color: Theme.of(context).colorScheme.primary,
            //       ),
            //     ),
            //   ],
            // ),
            const SizedBox(height: 4),
            if (isPhone(context))
              FixedTimeline.tileBuilder(
                theme: TimelineThemeData(
                  nodePosition: 0,
                ),
                builder: TimelineTileBuilder(
                  itemCount: 3,
                  contentsAlign: ContentsAlign.basic,
                  contentsBuilder: (context, index) => switch (index) {
                    0 => const Padding(
                        padding: EdgeInsets.fromLTRB(5, 0, 0, 8.0),
                        child: ClasstableCurrentColumn()),
                    1 => const Padding(
                        padding: EdgeInsets.fromLTRB(5, 0, 0, 8.0),
                        child:
                            ClasstableCurrentColumn(isArrangementMode: true)),
                    _ => Padding(
                        padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                        child: Text(
                          "之后还有 ${max(c.nextClassArrangements.$1.length - 1, 0)} 节课",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                  },
                  indicatorBuilder: (context, index) => Indicator.widget(
                    position: switch (index) {
                      0 => 0.05, // Current Class
                      1 => 0.05, // Next Class
                      _ => 0.50, // More Class
                    },
                    child: Icon(switch (index) {
                      0 => Icons.timelapse_outlined, // Current Class
                      1 => Icons.schedule_outlined, // Next Class
                      _ => Icons.more_time_outlined, // More Class
                    }),
                  ),
                  startConnectorBuilder: (context, index) {
                    if (index == 0) {
                      return null;
                    }

                    if (index == 1 && c.nextClassArrangements.$2) {
                      // Use dashedLine between today and tomorrow
                      return Connector.dashedLine(
                        color: Theme.of(context).colorScheme.primary,
                        gap: 4,
                        thickness: 3,
                      );
                    }

                    return Connector.solidLine(
                      color: Theme.of(context).colorScheme.primary,
                      thickness: 3,
                    );
                  },
                  endConnectorBuilder: (context, index) {
                    if (index >= 2) {
                      return null;
                    }

                    if (index == 0 && c.nextClassArrangements.$2) {
                      // Use dashedLine between today and tomorrow
                      return Connector.dashedLine(
                        color: Theme.of(context).colorScheme.primary,
                        gap: 4,
                        thickness: 3,
                      );
                    }

                    return Connector.solidLine(
                      color: Theme.of(context).colorScheme.primary,
                      thickness: 3,
                    );
                  },
                ),
              )
            else
              const Expanded(
                child: Row(
                  children: [
                    Flexible(
                      flex: 5,
                      child: ClasstableCurrentColumn(),
                    ),
                    VerticalDivider(),
                    Flexible(
                      flex: 6,
                      child: ClasstableArrangementColumn(),
                    ),
                  ],
                ),
              ),
          ],
        )),
      ),
    );
  }
}
