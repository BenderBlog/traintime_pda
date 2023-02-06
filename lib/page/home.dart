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
import 'package:watermeter/model/xidian_ids/classtable.dart';

import 'package:watermeter/page/score/score.dart';
import 'package:watermeter/page/sport/sport_window.dart';
import 'package:watermeter/page/xidian_directory/xidian_directory.dart';
import 'package:watermeter/page/setting/setting.dart';
import 'package:watermeter/page/classtable/classtable.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  static const _pageItems = [
    BottomNavigationBarItem(
      icon: Icon(Icons.home),
      label: '主页',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.settings),
      label: '设置',
    ),
  ];

  static final _page = [
    MainPage(),
    const SettingWindow(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //extendBodyBehindAppBar: true,
      body: _page[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: _pageItems,
        currentIndex: _selectedIndex,
        onTap: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}

//
class MainPage extends StatelessWidget {
  final classTableController = Get.put(ClassTableController());
  final scoreController = Get.put(ScoreController());
  final punchController = Get.put(PunchController());

  MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints.expand(),
      child: Stack(
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.35,
            decoration: BoxDecoration(
              image: DecorationImage(
                // Bing Pic https://api.cyrilstudio.top/bing/image.php
                // Another ACG https://px.s.rainchan.win/random
                // Random ACG https://acgapi.shifeiti.com/api/
                // Touhou https://img.paulzzh.tech/touhou/random
                image: Image.network("https://img.paulzzh.tech/touhou/random")
                    .image,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.25,
            left: 0.0,
            right: 0.0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ListView(
                shrinkWrap: true,
                children: [
                  GetBuilder<ClassTableController>(
                    builder: (c) => GestureDetector(
                      onTap: () {
                        try {
                          if (c.isGet == true) {
                            Get.to(
                              () => LayoutBuilder(
                                builder: (p0, p1) =>
                                    ClassTableWindow(constraints: p1),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(c.error ?? "正在获取课表")));
                          }
                        } on String catch (e) {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(SnackBar(content: Text("遇到错误$e")));
                        }
                      },
                      child: Card(
                        elevation: 0,
                        color: Theme.of(context).colorScheme.secondaryContainer,
                        child: Padding(
                          padding: const EdgeInsets.all(15),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(children: [
                                Icon(
                                  Icons.calendar_month_outlined,
                                  color: Theme.of(context).colorScheme.primary,
                                  size: 14,
                                ),
                                const SizedBox(width: 7.5),
                                Text(
                                  c.isNext == null
                                      ? "课程表"
                                      : c.isNext == true
                                          ? "课程表 下一节课是："
                                          : "课程表 正在上：",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                              ]),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 2),
                                child: Text(
                                  c.classToShow == null
                                      ? "目前没课"
                                      : c.classToShow!.name,
                                  style: TextStyle(
                                    fontSize: 22,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                              ),
                              c.classToShow == null
                                  ? Text(
                                      "寻找什么呢，我也不知道",
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                      ),
                                    )
                                  : Row(
                                      //mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.room,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                              size: 18,
                                            ),
                                            const SizedBox(width: 2),
                                            Text(
                                              c.classToShow!.place ?? "地点未定",
                                              style: TextStyle(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primary,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(width: 10),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.access_time_filled_outlined,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                              size: 18,
                                            ),
                                            const SizedBox(width: 2),
                                            Text(
                                              "${time[(c.timeArrangementToShow!.start - 1) * 2]}-"
                                              "${time[(c.timeArrangementToShow!.stop - 1) * 2 + 1]}",
                                              style: TextStyle(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primary,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    childAspectRatio: 1.75,
                    children: [
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
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(children: [
                                      Icon(
                                        Icons.run_circle,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        size: 14,
                                      ),
                                      const SizedBox(width: 7.5),
                                      Text(
                                        "体育信息",
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                        ),
                                      ),
                                    ]),
                                    const SizedBox(width: 15),
                                    Expanded(
                                      child: Center(
                                        child: c.error != null
                                            ? Text(
                                                "目前无法使用",
                                                textScaleFactor: 1.5,
                                                style: TextStyle(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .primary,
                                                ),
                                              )
                                            : Text(
                                                "有效次数 ${c.punch.valid}\n"
                                                "所有次数 ${c.punch.allTime}",
                                                textScaleFactor: 1.15,
                                                style: TextStyle(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .primary,
                                                ),
                                              ),
                                      ),
                                    ),
                                  ]),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    childAspectRatio: 2.25,
                    children: [
                      GetBuilder<ScoreController>(
                        builder: (c) => GestureDetector(
                          onTap: () async {
                            if (c.isGet == true) {
                              Get.to(() => ScoreWindow(scores: c.scores));
                            } else if (c.error == null) {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(const SnackBar(
                                behavior: SnackBarBehavior.floating,
                                content: Text(
                                  "请稍候 正在获取成绩信息",
                                ),
                              ));
                            } else {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(
                                behavior: SnackBarBehavior.floating,
                                content: Text("遇到错误，信息如下：\n${c.error!}"),
                              ));
                            }
                          },
                          child: Card(
                            elevation: 0,
                            color: Theme.of(context).colorScheme.surfaceVariant,
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Center(
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    const Icon(
                                      Icons.score,
                                      size: 48,
                                    ),
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: const [
                                        Text(
                                          "成绩查询",
                                          style: TextStyle(fontSize: 18),
                                        ),
                                        Text(
                                          "可计算平均分",
                                          style: TextStyle(fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Get.to(() => const XidianDirWindow()),
                        child: Card(
                          elevation: 0,
                          color: Theme.of(context).colorScheme.surfaceVariant,
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Center(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  const Icon(
                                    Icons.nightlife_rounded,
                                    size: 48,
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      Text(
                                        "生活信息",
                                        style: TextStyle(fontSize: 18),
                                      ),
                                      Text(
                                        "查询学校服务",
                                        style: TextStyle(fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
