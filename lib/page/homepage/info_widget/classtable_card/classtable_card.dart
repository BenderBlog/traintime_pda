// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:watermeter/controller/classtable_controller.dart';
import 'package:watermeter/page/classtable/classtable.dart';
import 'package:watermeter/page/homepage/info_widget/classtable_card/classtable_arrangement.dart';
import 'package:watermeter/page/homepage/info_widget/classtable_card/classtable_current.dart';
import 'package:watermeter/page/widget.dart';
import 'package:watermeter/repository/preference.dart' as preference;
import 'package:styled_widget/styled_widget.dart';

class ClassTableCard extends StatelessWidget {
  const ClassTableCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ClassTableController>(
      builder: (c) => GestureDetector(
        onTap: () {
          try {
            if (c.isGet == true) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ClassTableWindow(
                    offset: preference.getInt(preference.Preference.swift),
                    classTableData: c.classTableData,
                    currentWeek: c.currentWeek,
                    pretendLayout: c.pretendLayout,
                  ),
                ),
              );
            } else {
              Fluttertoast.showToast(msg: "正在获取课表");
            }
          } on String catch (e) {
            Fluttertoast.showToast(msg: "遇到错误：${e.substring(0, 150)}");
          }
        },
        child: Column(
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
            if (isPhone(context)) ...const [
              Flexible(child: ClasstableCurrentColumn()),
              Divider(color: Colors.transparent),
              ClasstableArrangementColumn(),
            ] else
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
        )
            .paddingDirectional(
              horizontal: 16,
              vertical: 14,
            )
            .decorated(
              border: Border.all(
                width: 3,
                color: Theme.of(context).colorScheme.primary,
              ),
              borderRadius: BorderRadius.circular(26),
            )
            .paddingAll(4),
      ),
    );
  }
}
