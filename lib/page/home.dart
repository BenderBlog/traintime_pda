/*
Home window.
Copyright 2022 SuperBart

This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.

Please refer to ADDITIONAL TERMS APPLIED TO WATERMETER SOURCE CODE
if you want to use.
*/

import 'dart:math' as math;
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:easy_refresh/easy_refresh.dart';

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

  static final _page = [
    MainPage(),
    const XidianDirWindow(),
    const Placeholder(),
    const SettingWindow(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //extendBodyBehindAppBar: true,
      body: _page[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        destinations: [
          NavigationDestination(
            icon: _selectedIndex == 0
                ? const Icon(Icons.home)
                : const Icon(Icons.home_outlined),
            label: '主页',
          ),
          NavigationDestination(
            icon: _selectedIndex == 1
                ? const Icon(Icons.store)
                : const Icon(Icons.store_outlined),
            label: '西电目录',
          ),
          NavigationDestination(
            icon: _selectedIndex == 2
                ? const Icon(Icons.feed)
                : const Icon(Icons.feed_outlined),
            label: 'XDU Planet',
          ),
          NavigationDestination(
            icon: _selectedIndex == 3
                ? const Icon(Icons.settings)
                : const Icon(Icons.settings_outlined),
            label: '设置',
          ),
        ],
        selectedIndex: _selectedIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}

class _RoundClipper extends CustomClipper<Path> {
  final double height;

  _RoundClipper({
    required this.height,
  });

  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(-1, height / 2);

    var firstStart = Offset(size.width / 2, height);
    //fist point of quadratic bezier curve
    var firstEnd = Offset(size.width, height / 2);
    //second point of quadratic bezier curve
    path.quadraticBezierTo(
        firstStart.dx, firstStart.dy, firstEnd.dx, firstEnd.dy);
    //end with this path if you are making wave at bottom

    path.lineTo(size.width, -1);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false; //if new instance have different instance than old instance
    //then you must return true;
  }
}

class MainPage extends StatelessWidget {
  final classTableController = Get.put(ClassTableController());
  final scoreController = Get.put(ScoreController());
  final punchController = Get.put(PunchController());

  Widget classTableCard(BuildContext context) =>
      GetBuilder<ClassTableController>(
        builder: (c) => GestureDetector(
          onTap: () {
            try {
              if (c.isGet == true) {
                Get.to(
                  () => LayoutBuilder(
                    builder: (p0, p1) => ClassTableWindow(constraints: p1),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text(c.error ?? "正在获取课表")));
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
                      c.isGet == true
                          ? c.isNext == null
                              ? "课程表"
                              : c.isNext == true
                                  ? "课程表 下一节课是："
                                  : "课程表 正在上："
                          : "课程表",
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ]),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Text(
                      c.isGet == true
                          ? c.classToShow == null
                              ? "目前没课"
                              : c.classToShow!.name
                          : c.error == null
                              ? "正在加载"
                              : "遇到错误",
                      style: TextStyle(
                        fontSize: 22,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  c.classToShow == null
                      ? Text(
                          c.isGet == true
                              ? "寻找什么呢，我也不知道"
                              : c.error == null
                                  ? "请耐心等待片刻"
                                  : "课表获取失败",
                          style: TextStyle(
                            fontSize: 15,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        )
                      : Row(
                          //mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.room,
                                  color: Theme.of(context).colorScheme.primary,
                                  size: 18,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  c.classToShow!.place ?? "地点未定",
                                  style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.primary,
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
                                  color: Theme.of(context).colorScheme.primary,
                                  size: 18,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  "${time[(c.timeArrangementToShow!.start - 1) * 2]}-"
                                  "${time[(c.timeArrangementToShow!.stop - 1) * 2 + 1]}",
                                  style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.primary,
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
      );

  Widget dymaticTools(BuildContext context) => MediaQuery.removePadding(
        context: context,
        removeTop: true,
        child: GridView.count(
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          shrinkWrap: true,
          childAspectRatio: 1.75,
          children: [
            GetBuilder<PunchController>(
              builder: (c) => GestureDetector(
                onTap: () async {
                  if (c.isGet == true) {
                    Get.to(() => const SportWindow());
                  } else if (c.error != null) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      behavior: SnackBarBehavior.floating,
                      content: Text("遇到错误"),
                    ));
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      behavior: SnackBarBehavior.floating,
                      content: Text("请稍候，正在刷新信息"),
                    ));
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
                              color: Theme.of(context).colorScheme.primary,
                              size: 14,
                            ),
                            const SizedBox(width: 7.5),
                            Text(
                              "体育信息",
                              style: TextStyle(
                                fontSize: 14,
                                color: Theme.of(context).colorScheme.primary,
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
                                  : c.isGet == false
                                      ? Text(
                                          "正在加载",
                                          textScaleFactor: 1.15,
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
      );

  Widget staticTools(BuildContext context) => MediaQuery.removePadding(
        context: context,
        removeTop: true,
        child: GridView.count(
          physics: const NeverScrollableScrollPhysics(),
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
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      behavior: SnackBarBehavior.floating,
                      content: Text(
                        "请稍候 正在获取成绩信息",
                      ),
                    ));
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
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
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          const Icon(
                            Icons.score,
                            size: 48,
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
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
          ],
        ),
      );

  MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    var themeData = Theme.of(context);
    return EasyRefresh(
      onRefresh: () {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text("请稍候，正在刷新信息"),
        ));
        classTableController.updateClassTable(isForce: true);
        classTableController.update();
        scoreController.get();
        scoreController.update();
        punchController.updatePunch();
        punchController.update();
      },
      header: BuilderHeader(
        clamping: true,
        position: IndicatorPosition.locator,
        triggerOffset: context.height * 0.025,
        notifyWhenInvisible: true,
        builder: (context, state) {
          final height = state.offset + context.height * 0.15;
          return Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              ClipPath(
                clipper: _RoundClipper(
                  height: height,
                ),
                child: Container(
                  height: height,
                  width: double.infinity,
                  color: themeData.colorScheme.primary,
                ),
              ),
              Positioned(
                top: -1,
                left: 0,
                right: 0,
                child: ClipPath(
                  clipper: _RoundClipper(
                    height: context.height * 0.15,
                  ),
                  child: Container(
                    height: 2,
                    width: double.infinity,
                    color: Colors.transparent,
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                child: SizedBox(
                  height: context.height * 0.15,
                  width: context.width * 0.9,
                  child: classTableCard(context),
                ),
              ),
            ],
          );
        },
      ),
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: themeData.colorScheme.primary,
            foregroundColor: themeData.colorScheme.onPrimary,
            expandedHeight: MediaQuery.of(context).size.width * 0.05,
            pinned: false,
          ),
          const HeaderLocator.sliver(paintExtent: 400),
          SliverToBoxAdapter(
            child: Card(
              elevation: 0,
              margin: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.05,
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  dymaticTools(context),
                  staticTools(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
