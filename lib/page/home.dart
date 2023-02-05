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
import 'package:watermeter/controller/punch_controller.dart';
import 'package:watermeter/controller/score_controller.dart';

import 'package:watermeter/page/score/score.dart';
import 'package:watermeter/page/sport/sport_window.dart';
import 'package:watermeter/page/xidian_directory/xidian_directory.dart';
import 'package:watermeter/page/setting/setting.dart';
import 'package:watermeter/page/classtable/classtable.dart';

class HomePage extends StatelessWidget {
  final classTableController = Get.put(ClassTableController());
  final scoreController = Get.put(ScoreController());
  final punchController = Get.put(PunchController());

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
                  child: Padding(
                      padding: const EdgeInsets.all(15),
                      child: Row(children: [
                        const Icon(
                          Icons.calendar_month_outlined,
                          size: 56,
                        ),
                        const SizedBox(width: 15),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "课程表",
                              style: TextStyle(fontSize: 20),
                            ),
                            if (c.error != null)
                              const Text("目前无法使用")
                            else
                              const Text("等待实现课程预告功能"),
                          ],
                        ),
                      ])),
                ),
              ),
            ),
            GetBuilder<PunchController>(
              builder: (c) => GestureDetector(
                onTap: () async {
                  if (c.isGet == true) {
                    Get.to(() => const SportWindow());
                  } else {
                    Get.snackbar("遇到错误", c.error!);
                  }
                },
                child: Card(
                  elevation: 0,
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  child: Padding(
                      padding: const EdgeInsets.all(15),
                      child: Row(children: [
                        const Icon(
                          Icons.run_circle_outlined,
                          size: 52,
                        ),
                        const SizedBox(width: 15),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "体育信息",
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            if (c.error != null)
                              const Text("目前无法使用")
                            else
                              Text(
                                  "有效次数 ${c.punch.valid}    所有次数 ${c.punch.allTime}"),
                          ],
                        ),
                      ])),
                ),
              ),
            ),
            GetBuilder<ScoreController>(
              builder: (c) => GestureDetector(
                onTap: () async {
                  if (c.isGet == true) {
                    Get.to(() => ScoreWindow(scores: c.scores));
                  } else if (c.error == null) {
                    Get.snackbar("请稍候", "正在获取成绩信息");
                  } else {
                    Get.snackbar("遇到错误，目前该功能被限制，若想重新启用，请重新启动该程序", c.error!);
                  }
                },
                child: Card(
                  elevation: 0,
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  child: Padding(
                      padding: const EdgeInsets.all(15),
                      child: Row(children: [
                        const Icon(
                          Icons.score,
                          size: 52,
                        ),
                        const SizedBox(width: 15),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "成绩查询",
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const Text("可计算平均分"),
                          ],
                        ),
                      ])),
                ),
              ),
            ),
            GestureDetector(
              onTap: () => Get.to(() => const XidianDirWindow()),
              child: Card(
                elevation: 0,
                color: Theme.of(context).colorScheme.surfaceVariant,
                child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: Row(children: [
                      const Icon(
                        Icons.nightlife,
                        size: 52,
                      ),
                      const SizedBox(width: 15),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "生活信息",
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const Text("查询学校服务"),
                        ],
                      ),
                    ])),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
