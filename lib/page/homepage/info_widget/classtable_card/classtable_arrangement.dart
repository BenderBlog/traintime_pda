// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jiffy/jiffy.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:watermeter/page/homepage/info_widget/classtable_card/class_detail_tile.dart';
import 'package:watermeter/page/homepage/refresh.dart';
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
    return Obx(
      () => Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            "接下来日程",
            style: TextStyle(
              fontSize: 14,
              textBaseline: TextBaseline.alphabetic,
              color: Theme.of(context).colorScheme.primary,
            ),
          ).padding(bottom: 8.0),
          if (arrangementState.value == ArrangementState.fetched)
            if (isTomorrow.isTrue && arrangement.isNotEmpty) ...[
              for (var i in arrangement)
                ClassDetailTile(
                  isTomorrow: isTomorrow.isTrue,
                  name: i.name,
                  time:
                      '${Jiffy.parseFromDateTime(i.startTime).format(pattern: "HH:mm")}'
                      '-${Jiffy.parseFromDateTime(i.endTime).format(pattern: "HH:mm")}',
                  place: arrangement.first.place,
                ),
              const Spacer(),
              NoticeBox(text: "明天一共${arrangement.length}个日程"),
            ] else if (arrangement.isNotEmpty) ...[
              for (var i in arrangement)
                ClassDetailTile(
                  isTomorrow: isTomorrow.isTrue,
                  name: i.name,
                  time:
                      '${Jiffy.parseFromDateTime(i.startTime).format(pattern: "HH:mm")}'
                      '-${Jiffy.parseFromDateTime(i.endTime).format(pattern: "HH:mm")}',
                  place: arrangement.first.place,
                ),
              const Spacer(),
              NoticeBox(text: "今天还剩${arrangement.length}个日程"),
            ] else
              NoticeBox(text: isTomorrow.isTrue ? "明天暂无日程" : "已完成所有日程")
          else if (arrangementState.value == ArrangementState.error)
            const NoticeBox(text: "遇到错误")
          else
            const NoticeBox(text: "正在加载"),
        ],
      ),
    );
  }
}
