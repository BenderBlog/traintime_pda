// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jiffy/jiffy.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:watermeter/controller/classtable_controller.dart';
import 'package:watermeter/page/homepage/info_widget/classtable_card/class_detail_tile.dart';
import 'package:watermeter/page/public_widget/public_widget.dart';

class NoticeBox extends StatelessWidget {
  final String text;
  const NoticeBox({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    Widget textWidget = Text(
      text,
      style: TextStyle(
        color: Theme.of(context).colorScheme.primary,
      ),
    )
        .center()
        .padding(
          horizontal: 8,
          vertical: 6,
        )
        .backgroundColor(
          Theme.of(context).colorScheme.secondary,
        )
        .clipRRect(all: 12)
        .center();

    if (!isPhone(context)) {
      return textWidget.expanded();
    } else {
      return textWidget;
    }
  }
}

class ClasstableArrangementColumn extends StatelessWidget {
  const ClasstableArrangementColumn({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ClassTableController>(
      builder: (c) => Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            "接下来课程",
            style: TextStyle(
              fontSize: 14,
              textBaseline: TextBaseline.alphabetic,
              color: Theme.of(context).colorScheme.primary,
            ),
          ).padding(bottom: 8.0),
          if (c.state == ClassTableState.fetched)
            if (c.isTomorrow && c.tomorrowArrangement.isNotEmpty) ...[
              ClassDetailTile(
                isTomorrow: c.isTomorrow,
                name: c.tomorrowArrangement.first.name,
                time:
                    '${Jiffy.parseFromDateTime(c.tomorrowArrangement.first.startTime).format(pattern: "HH:mm")}'
                    '-${Jiffy.parseFromDateTime(c.tomorrowArrangement.first.endTime).format(pattern: "HH:mm")}',
                place: c.tomorrowArrangement.first.place,
              ),
              NoticeBox(text: "明天一共${c.tomorrowArrangement.length}节课"),
            ] else if (c.todayArrangement.isNotEmpty) ...[
              ClassDetailTile(
                isTomorrow: c.isTomorrow,
                name: c.todayArrangement.first.name,
                time:
                    '${Jiffy.parseFromDateTime(c.todayArrangement.first.startTime).format(pattern: "HH:mm")}'
                    '-${Jiffy.parseFromDateTime(c.todayArrangement.first.endTime).format(pattern: "HH:mm")}',
                place: c.todayArrangement.first.place,
              ),
              NoticeBox(text: "今天还剩${c.todayArrangement.length}节课"),
            ] else
              NoticeBox(text: c.isTomorrow ? "明天没有课" : "已无课程安排")
          else if (c.state == ClassTableState.error)
            const NoticeBox(text: "遇到错误")
          else
            const NoticeBox(text: "正在加载"),
        ],
      ),
    );
  }
}
