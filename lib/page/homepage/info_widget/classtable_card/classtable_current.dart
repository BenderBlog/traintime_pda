// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:watermeter/controller/classtable_controller.dart';
import 'package:watermeter/model/xidian_ids/classtable.dart';

class ClasstableCurrentColumn extends StatelessWidget {
  const ClasstableCurrentColumn({super.key});

  @override
  Widget build(BuildContext context) {
    ClassTableController c = Get.find();
    print(c.currentData);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              c.isGet == true
                  ? c.currentData.$1.isEmpty
                      ? "目前没课"
                      : c.currentData.$1.first.$1.name //"毛泽东思想和中国特色社会主义理论体系概论"
                  : c.error == null
                      ? "正在加载"
                      : "遇到错误",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8.0),
        c.isGet == true
            ? c.currentData.$1.isEmpty
                ? Text(
                    "请享受空闲时光",
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  )
                : Column(
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
                            c.currentData.$1.first.$2.teacher ?? "老师未知",
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
                            c.currentData.$1.first.$2.classroom ?? "地点未定",
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
                            "${time[(c.currentData.$1.first.$2.start - 1) * 2]}-"
                            "${time[(c.currentData.$1.first.$2.stop - 1) * 2 + 1]}",
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  )
            : Text(
                c.error == null ? "请耐心等待片刻" : "课表获取失败",
                style: TextStyle(
                  fontSize: 15,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
      ],
    );
  }
}
