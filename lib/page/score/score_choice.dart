// Copyright 2023 BenderBlog Rodriguez.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:watermeter/controller/score_controller.dart';
import 'package:watermeter/page/column_choose_dialog.dart';
import 'package:watermeter/page/score/score_info_card.dart';
import 'package:watermeter/page/widget.dart';

class ScoreChoiceWindow extends StatelessWidget {
  const ScoreChoiceWindow({super.key});

  PreferredSizeWidget dropDownButton(context) => PreferredSize(
        preferredSize: const Size.fromHeight(48.0),
        child: GetBuilder<ScoreController>(
          builder: (c) => Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor:
                        Theme.of(context).colorScheme.secondaryContainer,
                  ),
                  onPressed: () async {
                    await showDialog<int>(
                      context: context,
                      builder: (context) => ColumnChooseDialog(
                        semesterList: ["所有学期", ...c.semester],
                      ),
                    ).then((value) {
                      c.chosenSemesterInScoreChoice =
                          ["", ...c.semester].toList()[value!];
                      c.update();
                    });
                  },
                  child: Text(
                    "学期 ${c.chosenSemesterInScoreChoice == "" ? "所有学期" : c.chosenSemesterInScoreChoice}",
                  ),
                ),
                const VerticalDivider(),
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor:
                        Theme.of(context).colorScheme.secondaryContainer,
                  ),
                  onPressed: () async {
                    await showDialog<int>(
                      context: context,
                      builder: (context) => ColumnChooseDialog(
                        semesterList: ["所有类型", ...c.statuses].toList(),
                      ),
                    ).then((value) {
                      c.chosenStatusInScoreChoice =
                          ["", ...c.statuses].toList()[value!];
                      c.update();
                    });
                  },
                  child: Text(
                    "类型 ${c.chosenStatusInScoreChoice == "" ? "所有类型" : c.chosenStatusInScoreChoice}",
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  Future<void> scoreInfoDialog(context) => showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('小总结'),
          content: GetBuilder<ScoreController>(
            builder: (c) => Text(
                "所有科目的GPA：${c.evalAvg(true, isGPA: true).toStringAsFixed(3)}\n"
                "所有科目的均分：${c.evalAvg(true).toStringAsFixed(2)}\n"
                "所有科目的学分：${c.evalCredit(true).toStringAsFixed(2)}\n"
                "未通过科目：${c.unPassed}\n"
                "公共选修课已经修得学分：${c.notCoreClass}\n"
                "本程序提供的数据仅供参考，开发者对其准确性不负责"),
          ),
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

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ScoreController>(
      builder: (c) => Scaffold(
        appBar: AppBar(
          title: const Text("成绩单"),
          actions: [
            IconButton(
              onPressed: () => scoreInfoDialog(context),
              icon: const Icon(Icons.info),
            ),
          ],
          bottom: dropDownButton(context),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: fixHeightGrid(
            height: 120,
            maxCrossAxisExtent: 360,
            children: List.generate(
              c.selectedScoreList.length,
              (index) => ScoreInfoCard(
                mark: c.selectedScoreList[index].mark,
                isScoreChoice: true,
              ),
            ),
          ),
        ),
        bottomNavigationBar: BottomAppBar(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                c.bottomInfo,
                textScaleFactor: 1.2,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
