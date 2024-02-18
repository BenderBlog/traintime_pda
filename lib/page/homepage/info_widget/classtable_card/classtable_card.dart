// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:watermeter/controller/classtable_controller.dart';
import 'package:watermeter/page/classtable/classtable.dart';
import 'package:watermeter/page/homepage/info_widget/classtable_card/classtable_arrangement.dart';
import 'package:watermeter/page/homepage/info_widget/classtable_card/classtable_current.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:watermeter/page/homepage/refresh.dart';
import 'package:watermeter/page/public_widget/public_widget.dart';

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

    return GestureDetector(
      onTap: () {
        final c = Get.find<ClassTableController>();
        switch (c.state) {
          case ClassTableState.fetched:
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => ClassTableWindow(
                  currentWeek: c.getCurrentWeek(updateTime),
                ),
              ),
            );
          case ClassTableState.error:
            Fluttertoast.showToast(msg: "遇到错误：${c.error?.substring(0, 150)}");
          case ClassTableState.fetching:
          case ClassTableState.none:
            Fluttertoast.showToast(msg: "正在获取课表");
        }
      },
      child: withCardStyle(Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(height: 4),
          if (isPhone(context))
            const ClasstableCurrentTimeline()
          else
            const Expanded(
              child: Row(
                children: [
                  Flexible(
                    flex: 5,
                    child: ClasstableCurrentTimeline(),
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
    );
  }
}
