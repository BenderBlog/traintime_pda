// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:watermeter/controller/classtable_controller.dart';
import 'package:watermeter/model/xidian_ids/classtable.dart';

class ClasstableCurrentColumn extends StatelessWidget {
  final bool isArrangementMode;

  const ClasstableCurrentColumn({super.key, this.isArrangementMode = false});

  ClassDetail? getClassDetail(ClassTableController c) {
    if (isArrangementMode) {
      if (c.classSet.$1.isEmpty) {
        return null;
      }
      return c.getClassDetail(c.classSet.$1.first);
    }
    return c.currentData.$1;
  }

  TimeArrangement? getTimeArrangement(ClassTableController c) {
    if (isArrangementMode) {
      if (c.classSet.$1.isEmpty) {
        return null;
      }
      return c.classTableData.timeArrangement[c.classSet.$1.first];
    }
    return c.currentData.$2;
  }

  bool isTomorrow(ClassTableController c) {
    return isArrangementMode && c.classSet.$2;
  }

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
            child: Text(
              c.isGet == true
                  ? (getClassDetail(c)?.name ??
                      (isArrangementMode ? "无课程安排" : "没有正在进行的课程")) // "毛泽东思想和中国特色社会主义理论体系概论"
                  : c.error == null
                      ? "正在加载"
                      : "遇到错误",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          )),
          const SizedBox(height: 8.0),
          c.isGet == true
              ? getClassDetail(c) != null
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
                              getTimeArrangement(c)!.teacher ?? "老师未知",
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
                              getTimeArrangement(c)!.classroom ?? "地点未定",
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
                              "${isTomorrow(c) ? "明天" : ""} ${time[(getTimeArrangement(c)!.start - 1) * 2]}-"
                              "${time[(getTimeArrangement(c)!.stop - 1) * 2 + 1]}",
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
              : Text(
                  c.error == null ? "请耐心等待片刻" : "课表获取失败",
                  style: TextStyle(
                    fontSize: 15,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
        ],
      ),
    );
  }
}
