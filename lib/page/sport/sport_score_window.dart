/*
Interface of the sport score window of the sport data.
Copyright 2022 SuperBart

This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.

*/

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:watermeter/page/widget.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:watermeter/model/xidian_sport/score.dart';
import 'package:watermeter/repository/xidian_sport_session.dart';

class SportScoreWindow extends StatefulWidget {
  const SportScoreWindow({Key? key}) : super(key: key);

  @override
  State<SportScoreWindow> createState() => _SportScoreWindowState();
}

class _SportScoreWindowState extends State<SportScoreWindow>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  late EasyRefreshController _controller;

  @override
  void initState() {
    super.initState();
    _controller = EasyRefreshController(
      controlFinishRefresh: true,
      controlFinishLoad: true,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (sportScore.value.situation == null && sportScore.value.detail.isEmpty) {
      SportSession().getScore();
    }
    super.build(context);
    return EasyRefresh.builder(
      controller: _controller,
      clipBehavior: Clip.none,
      header: const MaterialHeader(
        clamping: true,
        showBezierBackground: false,
        bezierBackgroundAnimation: false,
        bezierBackgroundBounce: false,
        springRebound: false,
      ),
      onRefresh: () async {
        await SportSession().getScore();
        _controller.finishRefresh();
      },
      refreshOnStart: true,
      childBuilder: (context, physics) => Obx(() {
        if (sportScore.value.situation == null &&
            sportScore.value.detail.isNotEmpty) {
          List things = [
            Card(
              elevation: 0,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              child: Container(
                padding: const EdgeInsets.all(15),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text("目前四年总分 ${sportScore.value.total}"),
                    Text(sportScore.value.detail
                        .substring(0, sportScore.value.detail.indexOf("\\"))),
                  ],
                ),
              ),
            ),
          ];
          things.addAll(List.generate(sportScore.value.list.length,
                  (index) => ScoreCard(toUse: sportScore.value.list[index]))
              .reversed);
          return dataList<dynamic, Widget>(
            things,
            (toUse) => toUse,
            physics: physics,
          );
        } else if (sportScore.value.situation == "正在获取") {
          return const Center(child: CircularProgressIndicator());
        } else {
          return Center(child: Text("坏事: ${sportScore.value.situation}"));
        }
      }),
    );
  }
}

class ScoreCard extends StatelessWidget {
  final SportScoreOfYear toUse;

  const ScoreCard({Key? key, required this.toUse}) : super(key: key);

  String unitToShow(String eval) =>
      eval.contains(".") ? eval.substring(0, eval.indexOf(".")) : eval;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 0, 20, 0),
              child: Row(
                children: [
                  Row(
                    children: [
                      Text(
                        "${toUse.year} ${toUse.gradeType}",
                        textScaleFactor: 1.2,
                      ),
                      const SizedBox(width: 10),
                      TagsBoxes(
                        text: toUse.rank,
                        backgroundColor: toUse.rank.contains("不")
                            ? Colors.red
                            : Colors.green,
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    toUse.totalScore,
                    textScaleFactor: 1.2,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: double.parse(toUse.totalScore) >= 50
                          ? Colors.green
                          : Colors.red,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 15),
            DecoratedBox(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              child: Container(
                padding: const EdgeInsets.all(10),
                child: Table(
                  columnWidths: const {
                    0: FlexColumnWidth(1.25),
                    1: FlexColumnWidth(0.75),
                    2: FlexColumnWidth(0.75),
                    3: FlexColumnWidth(1),
                  },
                  children: [
                    for (var i in toUse.details)
                      TableRow(
                        children: [
                          Text(
                            i.examName,
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            i.actualScore,
                            style: const TextStyle(fontFeatures: [
                              FontFeature.tabularFigures(),
                            ]),
                            textAlign: TextAlign.end,
                          ),
                          Text(
                            " ${unitToShow(i.examunit)}",
                            textAlign: TextAlign.start,
                          ),
                          Text(
                            "${i.score} 分",
                            style: const TextStyle(fontFeatures: [
                              FontFeature.tabularFigures(),
                            ]),
                            textAlign: TextAlign.end,
                          ),
                          Text(
                            i.rank,
                            style: TextStyle(
                              color: i.rank.contains("不")
                                  ? Colors.red
                                  : Colors.green,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
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
