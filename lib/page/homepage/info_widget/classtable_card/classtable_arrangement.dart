// Copyright 2023 BenderBlog Rodriguez.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:watermeter/controller/classtable_controller.dart';
import 'package:watermeter/model/xidian_ids/classtable.dart';
import 'package:watermeter/page/homepage/info_widget/classtable_card/class_detail_tile.dart';

class ClasstableArrangementColumn extends StatelessWidget {
  const ClasstableArrangementColumn({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ClassTableController>(
      builder: (c) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (c.isGet)
            if (c.classSet.$1.isNotEmpty)
              ...List<Widget>.generate(
                c.classSet.$1.length > 2 ? 2 : c.classSet.$1.length,
                (index) => ClassDetailTile(
                  isTomorrow: c.classSet.$2,
                  name: c.classTableData.classDetail[c.classSet.$1[index].index]
                      .name,
                  time: '${time[(c.classSet.$1[index].start - 1) * 2]}'
                      '-${time[(c.classSet.$1[index].stop - 1) * 2 + 1]}',
                  place: c.classSet.$1[index].classroom ?? "未定教室",
                ),
              )..add(
                  Text("${c.classSet.$2 ? "明天一共" : "今天还剩"}${c.classSet.$1.length}节课")
                      .padding(
                        left: 16,
                        right: 8,
                        vertical: 6,
                      )
                      .border(
                        left: 8.0,
                        color: Colors.grey.shade600,
                      )
                      .backgroundColor(
                        Colors.grey.shade200,
                      )
                      .clipRRect(all: 12),
                )
            else
              Text(c.classSet.$2 ? "明天没有课" : "今天课程上完了")
                  .padding(
                    left: 16,
                    right: 8,
                    vertical: 6,
                  )
                  .border(
                    left: 8.0,
                    color: Colors.grey.shade600,
                  )
                  .backgroundColor(
                    Colors.grey.shade200,
                  )
                  .clipRRect(all: 12)
          else
            Text(c.error == null ? "正在加载" : "遇到错误")
                .padding(
                  left: 16,
                  right: 8,
                  vertical: 6,
                )
                .border(
                  left: 8.0,
                  color: Theme.of(context).colorScheme.primary,
                )
                .backgroundColor(
                  Theme.of(context)
                      .colorScheme
                      .primaryContainer
                      .withOpacity(0.4),
                )
                .clipRRect(all: 12),
        ],
      ),
    );
  }
}
