/*
Home window.
Copyright 2022 SuperBart

This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.

Please refer to ADDITIONAL TERMS APPLIED TO WATERMETER SOURCE CODE
if you want to use.
*/

import 'package:get/get.dart';
import 'package:flutter/material.dart';

import 'package:watermeter/controller/classtable_controller.dart';
import 'package:watermeter/controller/score_controller.dart';

import 'package:watermeter/page/score/score.dart';
import 'package:watermeter/page/xidian_directory/xidian_directory.dart';
import 'package:watermeter/page/setting/setting.dart';
import 'package:watermeter/page/classtable/classtable.dart';

class HomePage extends StatelessWidget {
  final classTableController = Get.put(ClassTableController());
  final scoreController = Get.put(ScoreController());

  HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Traintime PDA"),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) {
                  return const SettingWindow();
                }),
              );
            },
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            GetBuilder<ClassTableController>(
              builder: (c) => GestureDetector(
                onTap: () {
                  try {
                    if (c.isGet == true) {
                      Get.to(
                        () => LayoutBuilder(
                          builder: (p0, p1) => ClassTableWindow(
                            constraints: p1,
                            classData: c.classTable,
                          ),
                        ),
                      );
                    } else {
                      Get.snackbar("无法打开", c.error ?? "正在获取课表");
                    }
                  } on String catch (e) {
                    Get.snackbar("遇到错误", e);
                  }
                },
                child: Card(
                  elevation: 0,
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_month_sharp,
                        size: 96.0,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "课程表 ${c.classTable.semesterCode}",
                        textScaleFactor: 1.5,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            GetBuilder<ScoreController>(
              builder: (c) => GestureDetector(
                onTap: () {
                  try {
                    if (c.isGet == true) {
                      Get.to(() => ScoreWindow(scores: c.scores));
                    } else {
                      Get.snackbar("无法打开", c.error ?? "正在获取成绩信息");
                    }
                  } on String catch (e) {
                    Get.snackbar("遇到错误", e);
                  }
                },
                child: Card(
                  elevation: 0,
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  child: Row(
                    children: const [
                      Icon(
                        Icons.score,
                        size: 96.0,
                      ),
                      SizedBox(height: 10),
                      Text(
                        "成绩查询",
                        textScaleFactor: 1.5,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () => Get.to(const XidianDirWindow()),
              child: Card(
                elevation: 0,
                color: Theme.of(context).colorScheme.surfaceVariant,
                child: Row(
                  children: const [
                    Icon(
                      Icons.nightlife,
                      size: 96.0,
                    ),
                    SizedBox(height: 10),
                    Text(
                      "生活信息",
                      textScaleFactor: 1.5,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
