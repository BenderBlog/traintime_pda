// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jiffy/jiffy.dart';
import 'package:watermeter/controller/classtable_controller.dart';
import 'package:watermeter/model/home_arrangement.dart';

class ClasstableCurrentColumn extends StatelessWidget {
  final bool isArrangementMode;

  HomeArrangement? getArrangement(ClassTableController c) {
    if (isArrangementMode) {
      return c.todayArrangement.isEmpty ? null : c.todayArrangement.first;
    }
    return c.currentData.$2;
  }

  const ClasstableCurrentColumn({
    super.key,
    this.isArrangementMode = false,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ClassTableController>(
      builder: (c) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
              child: Align(
            alignment: Alignment.centerLeft,
            child: Text.rich(
              TextSpan(
                children: [
                  if (c.state == ClassTableState.fetched)
                    TextSpan(
                      text: (c.currentData.$2?.name ??
                          (isArrangementMode ? "无课程安排" : "没有正在进行的课程")),
                    )
                  else if (c.state == ClassTableState.error)
                    const TextSpan(text: "遇到错误")
                  else
                    const TextSpan(text: "正在加载"),
                ],
              ),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          )),
          const SizedBox(height: 8.0),
          if (c.state == ClassTableState.fetched)
            getArrangement(c) != null
                ? Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.person,
                            color: Theme.of(context).colorScheme.primary,
                            size: 18,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            getArrangement(c)!.teacher,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.room,
                            color: Theme.of(context).colorScheme.primary,
                            size: 18,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            getArrangement(c)!.place,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time_filled_outlined,
                            color: Theme.of(context).colorScheme.primary,
                            size: 18,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            "${c.isTomorrow ? "明天 " : ""}"
                            "${Jiffy.parseFromDateTime(getArrangement(c)!.startTime).format(pattern: "HH:mm")}-"
                            "${Jiffy.parseFromDateTime(getArrangement(c)!.endTime).format(pattern: "HH:mm")}",
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  )
                : const SizedBox(height: 30.0)
          else
            Text(
              c.state == ClassTableState.error ? "请耐心等待片刻" : "课表获取失败",
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
        ],
      ),
    );
  }
}
