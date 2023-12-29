// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';
import 'package:watermeter/page/public_widget/column_choose_dialog.dart';
import 'package:watermeter/page/score/score_info_card.dart';
import 'package:watermeter/page/score/score_state.dart';
import 'package:watermeter/repository/preference.dart' as preference;

class ScoreChoicePage extends StatefulWidget {
  const ScoreChoicePage({super.key});

  @override
  State<ScoreChoicePage> createState() => _ScoreChoicePageState();
}

class _ScoreChoicePageState extends State<ScoreChoicePage> {
  late ScoreState state;

  @override
  void didChangeDependencies() {
    state = ScoreState.of(context)!;
    state.controllers.addListener(() => mounted ? setState(() {}) : null);
    super.didChangeDependencies();
  }

  Future<void> scoreInfoDialog(context) => showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('小总结'),
          content: Text(
            "所有科目的GPA：${state.evalAvg(true, isGPA: true).toStringAsFixed(3)}\n"
            "所有科目的均分：${state.evalAvg(true).toStringAsFixed(2)}\n"
            "所有科目的学分：${state.evalCredit(true).toStringAsFixed(2)}\n"
            "未通过科目：${state.unPassed}\n"
            "公共选修课已经修得学分：${state.notCoreClass}\n"
            "本程序提供的数据仅供参考，开发者对其准确性不负责",
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("确定"),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    int crossItems = max(
      MediaQuery.sizeOf(context).width ~/ 360,
      1,
    );

    int rowItem(int length) {
      int rowItem = length ~/ crossItems;
      if (crossItems * rowItem < length) {
        rowItem += 1;
      }
      return rowItem;
    }

    List<Widget> scoreList = List<Widget>.generate(
      state.selectedScoreList.length,
      (index) => ScoreInfoCard(
        mark: state.selectedScoreList[index].mark,
        isScoreChoice: true,
      ),
    );

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Platform.isIOS || Platform.isMacOS
                ? Icons.arrow_back_ios_new
                : Icons.arrow_back,
          ),
          onPressed: Navigator.of(context).pop,
        ),
        title: const Text("成绩单"),
        actions: [
          IconButton(
            onPressed: () => scoreInfoDialog(context),
            icon: const Icon(Icons.info),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 6,
            ),
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
                        chooseList: ["所有学期", ...state.semester],
                      ),
                    ).then((value) {
                      if (value != null) {
                        state.controllers.chosenSemesterInScoreChoice =
                            ["", ...state.semester].toList()[value];
                      }
                    });
                  },
                  child: Text(
                    "学期 ${state.controllers.chosenSemesterInScoreChoice == "" ? "所有学期" : state.controllers.chosenSemesterInScoreChoice}",
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
                        chooseList: ["所有类型", ...state.statuses].toList(),
                      ),
                    ).then((value) {
                      if (value != null) {
                        state.controllers.chosenStatusInScoreChoice =
                            ["", ...state.statuses].toList()[value];
                      }
                    });
                  },
                  child: Text(
                    "类型 ${state.controllers.chosenStatusInScoreChoice == "" ? "所有类型" : state.controllers.chosenStatusInScoreChoice}",
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: state.selectedScoreList.isNotEmpty
                ? preference.isPhone
                    ? ListView(
                        children: scoreList,
                      )
                    : SingleChildScrollView(
                        child: LayoutGrid(
                          columnSizes: repeat(
                            crossItems,
                            [auto],
                          ),
                          rowSizes: repeat(
                            rowItem(state.selectedScoreList.length),
                            [auto],
                          ),
                          children: List<Widget>.generate(
                            state.selectedScoreList.length,
                            (index) => ScoreInfoCard(
                              mark: state.selectedScoreList[index].mark,
                              isScoreChoice: true,
                            ),
                          ),
                        ),
                      )
                : const Center(
                    child: Text("没有选择该学期的课程计入均分计算"),
                  ),
          )
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              state.bottomInfo,
              textScaleFactor: 1.2,
            ),
          ],
        ),
      ),
    );
  }
}
