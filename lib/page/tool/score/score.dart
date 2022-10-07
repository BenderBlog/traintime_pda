/*
Score window.
Copyright 2022 SuperBart

This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.

Please refer to ADDITIONAL TERMS APPLIED TO WATERMETER SOURCE CODE
if you want to use.
*/

import 'package:flutter/material.dart';
import 'package:watermeter/model/xidian_ids/score.dart';
import 'package:watermeter/page/weight.dart';

class ScoreWindow extends StatelessWidget {
  const ScoreWindow({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const TabForScore();
  }
}

class TabForScore extends StatelessWidget {
  const TabForScore({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("成绩查询"),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.info),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => aboutDialog(context),
                );
              },
            ),
          ],
        ),
        body: const ScoreTable(),
      ),
    );
  }

  Widget aboutDialog(context) => AlertDialog(
        title: const Text("For VB, are you agree?"),
        content: Image.asset("assets/Humpy-Score.jpg"),
        actions: <Widget>[
          TextButton(
            child: const Text("确定"),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
}

class ScoreTable extends StatefulWidget {
  const ScoreTable({Key? key}) : super(key: key);

  @override
  State<ScoreTable> createState() => _ScoreTableState();
}

class _ScoreTableState extends State<ScoreTable> {
  bool isSelectMod = false;

  List<bool> isSelected =
      List<bool>.generate(scores!.scoreTable.length, (int index) => false);

  /// Empty means all semester.
  String chosenSemester = "";

  /// Empty means all status.
  String chosenStatus = "";

  double _evalAvgScore(bool isAll) {
    double totalScore = 0.0;
    double totalCredit = 0.0;
    for (var i = 0; i < isSelected.length; ++i) {
      if ((isSelected[i] == true && isAll == false) || isAll == true) {
        totalScore +=
            scores!.scoreTable[i].score * scores!.scoreTable[i].credit;
        totalCredit += scores!.scoreTable[i].credit;
      }
    }
    return totalCredit != 0 ? totalScore / totalCredit : 0.0;
  }

  List<Score> toShow() {
    /// If I write "whatever = scores.scoreTable", every change I made to "whatever"
    /// also applies to scores.scoreTable. Since reference whatsoever.
    List<Score> whatever = List.from(scores!.scoreTable);
    if (chosenSemester != "") {
      whatever.removeWhere((element) => element.year != chosenSemester);
    }
    if (chosenStatus != "") {
      whatever.removeWhere((element) => element.status != chosenStatus);
    }
    return whatever;
  }

  String unPassed() {
    if (scores!.unPassed.isEmpty) {
      return "没有";
    }
    return scores!.unPassed.join(",");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          TitleLine(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                DropdownButton(
                  value: chosenSemester,
                  icon: const Icon(
                    Icons.keyboard_arrow_down,
                  ),
                  underline: Container(
                    height: 2,
                  ),
                  items: [
                    const DropdownMenuItem(value: "", child: Text("所有学期")),
                    for (var i in scores!.semester)
                      DropdownMenuItem(value: i, child: Text(i))
                  ],
                  onChanged: (String? value) {
                    setState(() {
                      chosenSemester = value!;
                    });
                  },
                ),
                DropdownButton(
                  value: chosenStatus,
                  icon: const Icon(
                    Icons.keyboard_arrow_down,
                  ),
                  underline: Container(
                    height: 2,
                  ),
                  items: [
                    const DropdownMenuItem(value: "", child: Text("所有类型")),
                    for (var i in scores!.statuses)
                      DropdownMenuItem(value: i, child: Text(i))
                  ],
                  onChanged: (String? value) {
                    setState(
                      () {
                        chosenStatus = value!;
                      },
                    );
                  },
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      isSelectMod = !isSelectMod;
                      /// Do not remember anything when quit calculating.
                      if (!isSelectMod) {
                        for (var i = isSelected.length - 1; i >= 0; --i) {
                          isSelected[i] = false;
                        }
                      }
                    });
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: const Text(
                    "计算均分",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemBuilder: (builder, index) {
                return Column(
                  children: [
                    InkWell(
                        onTap: () => setState(() {
                              if (isSelectMod) {
                                isSelected[toShow()[index].mark] =
                                    !isSelected[toShow()[index].mark];
                              }
                            }),
                        child: Container(
                          decoration:
                              BoxDecoration(color: _getColor(toShow()[index])),
                          child: ScoreCard(toUse: toShow()[index]),
                        )),

                  ],
                );
              },
              itemCount: toShow().length,
            ),
          ),
          if (isSelectMod)
            TitleLine(
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      "目前选中科目计算的均分 ${_evalAvgScore(false).toStringAsFixed(2)}",
                      textScaleFactor: 1.2,
                    ),
                  )
                ],
              ),
            ),
        ],
      ),
      floatingActionButton: _buildDetailsWindow(),
    );
  }

  Widget? _buildDetailsWindow() {
    if (isSelectMod) {
      return FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('小总结'),
              content:
                  Text("所有科目计算均分：${_evalAvgScore(true).toStringAsFixed(2)}\n"
                      "未通过科目：${unPassed()}\n"
                      "公共选修课已经修得学分：${scores!.randomChoice} / 8.0\n"
                      "本程序提供的数据仅供参考，开发者对其准确性不负责"),
              actions: <Widget>[
                TextButton(
                  child: const Text("确定"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          );
        },
        child: const Icon(
          Icons.panorama_fisheye,
        ),
      );
    } else {
      return null;
    }
  }

  Color _getColor(Score data) {
    if (isSelectMod && isSelected[data.mark]) {
      return Colors.yellow.shade100;
    } else {
      return Colors.white;
    }
  }
}

class ScoreCard extends StatelessWidget {
  final Score toUse;

  const ScoreCard({Key? key, required this.toUse}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(10),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    toUse.name,
                    textAlign: TextAlign.left,
                    //textScaleFactor: 0.9,
                  ),
                  Row(
                    children: [
                      TagsBoxes(
                        text: toUse.status,
                        backgroundColor: Colors.blue,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 6.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "学期：${toUse.year}",
                    textScaleFactor: 0.9,
                  ),
                  Text(
                    "学分: ${toUse.credit}",
                    textScaleFactor: 0.9,
                  ),
                  Text(
                    "成绩：${toUse.score}",
                    textScaleFactor: 0.9,
                  )
                ],
              ),
            ],
          ),
        ));
  }
}
