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
import 'package:easy_refresh/easy_refresh.dart';
import 'package:watermeter/controller/exam_controller.dart';
import 'package:watermeter/model/user.dart';
import 'package:watermeter/page/exam/exam.dart';

import 'package:watermeter/page/homepage/clipper.dart';

import 'package:watermeter/controller/classtable_controller.dart';
import 'package:watermeter/controller/punch_controller.dart';
import 'package:watermeter/controller/score_controller.dart';
import 'package:watermeter/model/xidian_ids/classtable.dart';
import 'package:watermeter/page/homepage/info_widget/electricity_card.dart';

import 'package:watermeter/page/score/score.dart';
import 'package:watermeter/page/setting/subwindow/sport_password_dialog.dart';
import 'package:watermeter/page/sport/sport_window.dart';
import 'package:watermeter/page/classtable/classtable.dart';

class MainPage extends StatelessWidget {
  final classTableController = Get.put(ClassTableController());
  final scoreController = Get.put(ScoreController());
  final punchController = Get.put(PunchController());
  final examController = Get.put(ExamController());

  late BuildContext _context;
  late ThemeData _themeData;
  late NavigatorState _navigator;
  late ScaffoldMessengerState _scaffoldMessenger;
  late MediaQueryData _mediaQuery;

  Future<void> _update() async {
    await classTableController.updateClassTable(isForce: true);
    classTableController.update();
    await scoreController.get();
    scoreController.update();
    await punchController.updatePunch();
    punchController.update();
    await examController.get();
    examController.update();
  }

  Widget _classTableCard() => GetBuilder<ClassTableController>(
        builder: (c) => GestureDetector(
          onTap: () {
            try {
              if (c.isGet == true) {
                _navigator.push(
                  MaterialPageRoute(
                    builder: (context) => LayoutBuilder(
                      builder: (p0, p1) => ClassTableWindow(constraints: p1),
                    ),
                  ),
                );
              } else {
                _scaffoldMessenger
                    .showSnackBar(SnackBar(content: Text(c.error ?? "正在获取课表")));
              }
            } on String catch (e) {
              _scaffoldMessenger.showSnackBar(
                  SnackBar(content: Text("遇到错误：${e.substring(0, 150)}")));
            }
          },
          child: Card(
            elevation: 0,
            color: _themeData.colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Icon(
                      Icons.calendar_month_outlined,
                      color: _themeData.colorScheme.onPrimaryContainer,
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
                        color: _themeData.colorScheme.onPrimaryContainer,
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
                        color: _themeData.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                  c.isGet == true
                      ? c.classToShow == null
                          ? Text(
                              "寻找什么呢，我也不知道",
                              style: TextStyle(
                                fontSize: 15,
                                color:
                                    _themeData.colorScheme.onPrimaryContainer,
                              ),
                            )
                          : Row(
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.person,
                                      color: _themeData
                                          .colorScheme.onPrimaryContainer,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      c.classToShow!.teacher == null
                                          ? "没有老师数据"
                                          : c.classToShow!.teacher!.length >= 7
                                              ? c.classToShow!.teacher!
                                                  .substring(0, 7)
                                              : c.classToShow!.teacher!,
                                      style: TextStyle(
                                        color: _themeData.colorScheme.primary,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 10),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.room,
                                      color: _themeData
                                          .colorScheme.onPrimaryContainer,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      c.classToShow!.place ?? "地点未定",
                                      style: TextStyle(
                                        color: _themeData
                                            .colorScheme.onPrimaryContainer,
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
                                      color: _themeData
                                          .colorScheme.onPrimaryContainer,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      "${time[(c.timeArrangementToShow!.start - 1) * 2]}-"
                                      "${time[(c.timeArrangementToShow!.stop - 1) * 2 + 1]}",
                                      style: TextStyle(
                                        color: _themeData
                                            .colorScheme.onPrimaryContainer,
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
                            color: _themeData.colorScheme.onPrimaryContainer,
                          ),
                        ),
                ],
              ),
            ),
          ),
        ),
      );

  Widget _sportInformationCard() => GetBuilder<PunchController>(
        builder: (c) => GestureDetector(
          onTap: () async {
            if (user["sportPassword"] == "" ||
                c.error.toString().contains("用户名或密码错误")) {
              showDialog(
                context: _context,
                builder: (context) => const SportPasswordDialog(),
              );
            } else {
              if (c.isGet == true) {
                _navigator.push(MaterialPageRoute(
                    builder: (context) => const SportWindow()));
              } else if (c.error != null) {
                _scaffoldMessenger.showSnackBar(SnackBar(
                  behavior: SnackBarBehavior.floating,
                  content: Text("遇到错误：${c.error}"),
                ));
              } else {
                _scaffoldMessenger.showSnackBar(const SnackBar(
                  behavior: SnackBarBehavior.floating,
                  content: Text("请稍候，正在刷新信息"),
                ));
              }
            }
          },
          child: Card(
            elevation: 0,
            color: _themeData.colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Icon(
                      Icons.run_circle,
                      color: _themeData.colorScheme.onPrimaryContainer,
                      size: 14,
                    ),
                    const SizedBox(width: 7.5),
                    Text(
                      "体育信息",
                      style: TextStyle(
                        fontSize: 14,
                        color: _themeData.colorScheme.onPrimaryContainer,
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
                                  color: _themeData
                                      .colorScheme.onPrimaryContainer),
                            )
                          : c.isGet == false
                              ? Text(
                                  "正在加载",
                                  textScaleFactor: 1.15,
                                  style: TextStyle(
                                    color: _themeData
                                        .colorScheme.onPrimaryContainer,
                                  ),
                                )
                              : Text(
                                  "有效次数 ${c.punch.valid}\n"
                                  "所有次数 ${c.punch.allTime}",
                                  textScaleFactor: 1.15,
                                  style: TextStyle(
                                    color: _themeData
                                        .colorScheme.onPrimaryContainer,
                                  ),
                                ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

  Widget _scoreCard() => GetBuilder<ScoreController>(
        builder: (c) => GestureDetector(
          onTap: () async {
            if (c.isGet == true) {
              _navigator.push(MaterialPageRoute(
                  builder: (context) => ScoreWindow(scores: c.scores)));
            } else if (c.error == null) {
              _scaffoldMessenger.showSnackBar(const SnackBar(
                behavior: SnackBarBehavior.floating,
                content: Text(
                  "请稍候 正在获取成绩信息",
                ),
              ));
            } else {
              _scaffoldMessenger.showSnackBar(SnackBar(
                behavior: SnackBarBehavior.floating,
                content: Text("遇到错误：${c.error!}"),
              ));
            }
          },
          child: Card(
            elevation: 0,
            color: _themeData.colorScheme.primaryContainer,
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
      );

  Widget _examCard() => GetBuilder<ExamController>(
        builder: (c) => GestureDetector(
          onTap: () async {
            if (c.isGet == true) {
              _navigator.push(MaterialPageRoute(
                  builder: (context) => const ExamInfoWindow()));
            } else if (c.error == null) {
              _scaffoldMessenger.showSnackBar(const SnackBar(
                behavior: SnackBarBehavior.floating,
                content: Text(
                  "请稍候 正在获取考试信息",
                ),
              ));
            } else {
              _scaffoldMessenger.showSnackBar(SnackBar(
                behavior: SnackBarBehavior.floating,
                content: Text("遇到错误：${c.error!}"),
              ));
            }
          },
          child: Card(
            elevation: 0,
            color: _themeData.colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    const Icon(
                      Icons.calendar_month,
                      size: 48,
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text(
                          "考试查询",
                          style: TextStyle(fontSize: 18),
                        ),
                        Text(
                          "上天保佑时间",
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
      );

  MainPage({super.key});
  /*
  Widget _padMainPage() {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Welcome to traintime pda."),
          actions: [
            IconButton(
              onPressed: () async => _update(),
              icon: const Icon(Icons.update),
            ),
          ],
        ),
        body: ListView(
          children: [
            Row(
              children: [
                Flexible(
                  flex: 1,
                  child: _classTableCard(),
                ),
                Flexible(
                  child: MediaQuery.removePadding(
                    context: _context,
                    removeTop: true,
                    child: GridView.count(
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      childAspectRatio: 1.75,
                      children: [
                        _sportInformationCard(),
                        _electricCard(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ));
  }
  */
  Widget _phoneMainPage() {
    const double classCardHeight = 120.0;
    return EasyRefresh(
      onRefresh: () async {
        _scaffoldMessenger.showSnackBar(const SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text("请稍候，正在刷新信息"),
        ));
        await _update();
      },
      header: BuilderHeader(
        clamping: false,
        position: IndicatorPosition.locator,
        triggerOffset: _context.height * 0.025,
        notifyWhenInvisible: true,
        builder: (context, state) {
          final height = state.offset + classCardHeight;
          return Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              ClipPath(
                clipper: RoundClipper(
                  height: height,
                ),
                child: Container(
                  height: height,
                  color: _themeData.colorScheme.surfaceVariant,
                ),
              ),
              Positioned(
                top: -1,
                left: 0,
                right: 0,
                child: ClipPath(
                  clipper: FillLineClipper(classCardHeight),
                  child: Container(
                    height: 2,
                    width: double.infinity,
                    color: _themeData.colorScheme.surfaceVariant,
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                child: SizedBox(
                  height: classCardHeight,
                  width: context.width * 0.9,
                  child: _classTableCard(),
                ),
              ),
            ],
          );
        },
      ),
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: _themeData.colorScheme.surfaceVariant,
            foregroundColor: _themeData.colorScheme.onSurfaceVariant,
            expandedHeight: _mediaQuery.size.width * 0.125,
            pinned: true,
            elevation: 0,
            title: const Text("Traintime PDA"),
          ),
          const HeaderLocator.sliver(paintExtent: classCardHeight),
          SliverToBoxAdapter(
            child: Card(
              elevation: 0,
              margin: EdgeInsets.symmetric(
                horizontal: _mediaQuery.size.width * 0.05,
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  MediaQuery.removePadding(
                    context: _context,
                    removeTop: true,
                    child: GridView.count(
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      childAspectRatio: 1.75,
                      children: [
                        _sportInformationCard(),
                        const ElectricityCard(),
                      ],
                    ),
                  ),
                  MediaQuery.removePadding(
                    context: _context,
                    removeTop: true,
                    child: GridView.count(
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      childAspectRatio: 2.25,
                      children: [
                        _scoreCard(),
                        _examCard(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _context = context;
    _themeData = Theme.of(context);
    _navigator = Navigator.of(context);
    _scaffoldMessenger = ScaffoldMessenger.of(context);
    _mediaQuery = MediaQuery.of(context);

    return _phoneMainPage();
  }
}
