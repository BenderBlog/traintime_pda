/*
Interface of the sport score window of the sport data.
Copyright 2022 SuperBart

This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.

Please refer to ADDITIONAL TERMS APPLIED TO WATERMETER SOURCE CODE
if you want to use.
*/

import 'package:flutter/material.dart';
import 'package:watermeter/repository/xidian_sport/xidian_sport_session.dart';
import 'package:watermeter/dataStruct/sport/score.dart';
import 'package:watermeter/ui/weight.dart';

TagsBoxes situation(String rank) => TagsBoxes(
      text: rank,
      backgroundColor: rank.contains("不") ? Colors.red : Colors.green,
    );

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
              return ListView(
                children: [
                  ShadowBox(
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
                  )),
                  for (int i = snapshot.data.list.length - 1; i >= 0; --i)
                    ScoreCard(toUse: snapshot.data.list[i]),
                ],
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

  String unitToShow(String eval) {
    if (eval.contains(".")) {
      return eval.substring(0, eval.indexOf("."));
    } else {
      return eval;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ShadowBox(
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
                      situation(
                        toUse.rank,
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
                          : Colors.orange,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 15),
            DecoratedBox(
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 237, 242, 247),
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              child: Container(
                padding: const EdgeInsets.all(10),
                child: Table(
                  children: [
                    for (var i in toUse.details)
                      TableRow(
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 2, 0, 2),
                            child: Text(
                              i.examName,
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 2, 0, 2),
                            child: Text(
                              "${i.actualScore} ${unitToShow(i.examunit)}",
                              textAlign: TextAlign.end,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 2, 0, 2),
                            child: Text(
                              "${i.score} 分",
                              textAlign: TextAlign.end,
                            ),
                          ),
                          Padding(
                              padding: const EdgeInsets.fromLTRB(0, 2, 0, 2),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const SizedBox(width: 12),
                                  situation(i.rank),
                                ],
                              )),
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
