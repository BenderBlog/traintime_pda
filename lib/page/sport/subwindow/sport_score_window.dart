/*
Interface of the sport score window of the sport data.
Copyright 2022 SuperBart

This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.

Please refer to ADDITIONAL TERMS APPLIED TO WATERMETER SOURCE CODE
if you want to use.
*/

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:watermeter/repository/xidian_sport/xidian_sport_session.dart';
import 'package:watermeter/model/xidian_sport/score.dart';
import 'package:watermeter/page/widget.dart';

class SportScoreWindow extends StatefulWidget {
  const SportScoreWindow({Key? key}) : super(key: key);

  @override
  State<SportScoreWindow> createState() => _SportScoreWindowState();
}

class _SportScoreWindowState extends State<SportScoreWindow> {
  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => _get(),
      child: FutureBuilder<SportScore>(
        future: _get(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return Center(
                  child: Text("坏事: ${snapshot.error} / ${toUse.userId}"));
            } else {
              List things = [
                Card(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text("目前四年总分 ${snapshot.data.total}"),
                        Text(
                            "${snapshot.data.detail.substring(0, snapshot.data.detail.indexOf("\\"))}"),
                      ],
                    ),
                  ),
                ),
              ];
              things.addAll(List.generate(snapshot.data.list.length,
                      (index) => ScoreCard(toUse: snapshot.data.list[index]))
                  .reversed);
              return dataList<dynamic, Widget>(
                things,
                (toUse) => toUse,
              );
            }
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  Future<SportScore> _get() async => getSportScore();
}

class ScoreCard extends StatelessWidget {
  final SportScoreOfYear toUse;

  const ScoreCard({Key? key, required this.toUse}) : super(key: key);

  String unitToShow(String eval) =>
      eval.contains(".") ? eval.substring(0, eval.indexOf(".")) : eval;

  @override
  Widget build(BuildContext context) {
    return Card(
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
