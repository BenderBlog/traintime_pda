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
import 'package:watermeter/page/widget.dart';

class ScoreWindow extends StatefulWidget {
  final List<Score> scores;
  const ScoreWindow({Key? key, required this.scores}) : super(key: key);

  @override
  State<ScoreWindow> createState() => _ScoreWindowState();
}

class _ScoreWindowState extends State<ScoreWindow> {
  late List<Score> scoreTable;
  Set<String> semester = {};
  Set<String> statuses = {};
  Set<String> unPassedSet = {};
  double randomChoice = 0.0;

  bool isSelectMod = false;
  late List<bool> isSelected;

  /// Empty means all semester.
  String chosenSemester = "";

  /// Empty means all status.
  String chosenStatus = "";

  double _evalCredit(bool isAll) {
    double totalCredit = 0.0;
    for (var i = 0; i < isSelected.length; ++i) {
      if ((isSelected[i] == true && isAll == false) || isAll == true) {
        totalCredit += scoreTable[i].credit;
      }
    }
    return totalCredit;
  }

  double _evalAvgScore(bool isAll) {
    double totalScore = 0.0;
    double totalCredit = _evalCredit(isAll);
    for (var i = 0; i < isSelected.length; ++i) {
      if ((isSelected[i] == true && isAll == false) || isAll == true) {
        totalScore += scoreTable[i].score * scoreTable[i].credit;
      }
    }
    return totalCredit != 0 ? totalScore / totalCredit : 0.0;
  }

  List<Score> toShow() {
    /// If I write "whatever = scores.scoreTable", every change I made to "whatever"
    /// also applies to scores.scoreTable. Since reference whatsoever.
    List<Score> whatever = List.from(scoreTable);
    if (chosenSemester != "") {
      whatever.removeWhere((element) => element.year != chosenSemester);
    }
    if (chosenStatus != "") {
      whatever.removeWhere((element) => element.status != chosenStatus);
    }
    return whatever;
  }

  String unPassed() {
    if (unPassedSet.isEmpty) {
      return "没有";
    }
    return unPassedSet.join(",");
  }

  @override
  void initState() {
    scoreTable = widget.scores;
    semester = {for (var i in scoreTable) i.year};
    statuses = {for (var i in scoreTable) i.status};
    for (var i in scoreTable) {
      if (i.status == "公共任选") {
        randomChoice += i.credit;
      }
    }
    for (var i in scoreTable) {
      if (i.isPassed != '1' && i.isPassed != "-1") {
        unPassedSet.add(i.name);
      }
      if (unPassedSet.contains(i.name) && i.isPassed == "1") {
        unPassedSet.remove(i.name);

        /// Whatever score is, if not passed in the first time, count as 60.
        /// Please take a note of it.
        i.score = 60;
        i.name += "(非初修通过)";
        unPassedSet.remove(i.name);
      }
      if (i.isPassed == "-1") {
        i.name += "(成绩没登完)";
      }
    }
    isSelected = List<bool>.generate(scoreTable.length, (int index) => false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            icon: const Icon(Icons.calculate),
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
          ),
          IconButton(
            icon: const Icon(Icons.info),
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
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
                      ));
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(40),
          child: SizedBox(
            height: 40,
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
                    for (var i in semester)
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
                    for (var i in statuses)
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
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
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
                          child: ScoreInfoCard(toUse: toShow()[index]),
                        )),
                  ],
                );
              },
              itemCount: toShow().length,
            ),
          ),
        ],
      ),
      bottomNavigationBar: isSelectMod
          ? BottomAppBar(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "目前选中科目的学分 ${_evalCredit(false).toStringAsFixed(2)}\n"
                    "目前选中科目的均分 ${_evalAvgScore(false).toStringAsFixed(2)}",
                    textScaleFactor: 1.2,
                  ),
                  FloatingActionButton(
                    elevation: 0.0,
                    highlightElevation: 0.0,
                    focusElevation: 0.0,
                    disabledElevation: 0.0,
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('小总结'),
                          content: Text(
                              "所有科目的均分：${_evalAvgScore(true).toStringAsFixed(2)}\n"
                              "所有科目的学分：${_evalCredit(true).toStringAsFixed(2)}\n"
                              "未通过科目：${unPassed()}\n"
                              "公共选修课已经修得学分：$randomChoice / 8.0\n"
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
                  ),
                ],
              ),
            )
          : null,
    );
  }

  Color _getColor(Score data) {
    if (isSelectMod && isSelected[data.mark]) {
      return Colors.yellow.shade100;
    } else {
      return Colors.white;
    }
  }
}

class ScoreInfoCard extends StatelessWidget {
  final Score toUse;

  const ScoreInfoCard({Key? key, required this.toUse}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width < 700
              ? 10
              : MediaQuery.of(context).size.width * 0.15,
          vertical: 10,
        ),
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
                    "等级：${toUse.level}",
                    style: TextStyle(
                      color: toUse.how == 1 || toUse.how == 2
                          ? Colors.black
                          : Colors.transparent,
                    ),
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
