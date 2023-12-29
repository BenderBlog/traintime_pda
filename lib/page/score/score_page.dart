// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

/// Main window for score.

import 'dart:io';
import 'dart:math';

import 'package:flutter_layout_grid/flutter_layout_grid.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:flutter/material.dart';
import 'package:watermeter/page/public_widget/column_choose_dialog.dart';
import 'package:watermeter/page/score/score_choice_page.dart';
import 'package:watermeter/page/score/score_info_card.dart';
import 'package:watermeter/page/public_widget/public_widget.dart';
import 'package:watermeter/page/score/score_state.dart';
import 'package:watermeter/page/score/score_statics.dart';
import 'package:watermeter/repository/preference.dart' as preference;

class ScorePage extends StatefulWidget {
  const ScorePage({super.key});

  @override
  State<ScorePage> createState() => _ScorePageState();
}

class _ScorePageState extends State<ScorePage> {
  late ScoreState c;

  @override
  void didChangeDependencies() {
    c = ScoreState.of(context)!;
    c.controllers.addListener(() => mounted ? setState(() {}) : null);
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    c.controllers.removeListener(() {});
    super.dispose();
  }

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
      c.toShow.length,
      (index) => SafeArea(
          child: ScoreInfoCard(
        mark: c.toShow[index].mark,
      )),
    );

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Platform.isIOS || Platform.isMacOS
                ? Icons.arrow_back_ios_new
                : Icons.arrow_back,
          ),
          onPressed: Navigator.of(c.context).pop,
        ),
        title: const Text("成绩查询"),
        actions: [
          IconButton(
            icon: const Icon(Icons.calculate),
            onPressed: () => c.setScoreChoiceMod(),
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
              mainAxisAlignment: preference.isPhone
                  ? MainAxisAlignment.start
                  : MainAxisAlignment.center,
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
                        chooseList: ["所有学期", ...c.semester].toList(),
                      ),
                    ).then((value) {
                      if (value != null) {
                        c.chosenSemester = ["", ...c.semester].toList()[value];
                      }
                    });
                  },
                  child: Text(
                    "学期 ${c.controllers.chosenSemester == "" ? "所有学期" : c.controllers.chosenSemester}",
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
                        chooseList: ["所有类型", ...c.statuses].toList(),
                      ),
                    ).then((value) {
                      if (value != null) {
                        c.chosenStatus = ["", ...c.statuses].toList()[value];
                      }
                    });
                  },
                  child: Text(
                    "类型 ${c.controllers.chosenStatus == "" ? "所有类型" : c.controllers.chosenStatus}",
                  ),
                ),
              ],
            ),
          ),
          Expanded(
              child: c.toShow.isNotEmpty
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
                              rowItem(c.toShow.length),
                              [auto],
                            ),
                            children: scoreList,
                          ),
                        )
                  : const Text("未筛查到合请求的记录").center()),
        ],
      ),
      bottomNavigationBar: Visibility(
        visible: c.controllers.isSelectMod,
        child: BottomAppBar(
          height: 136,
          elevation: 5.0,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(
                        Theme.of(context).primaryColor,
                      ),
                    ),
                    onPressed: () => c.setScoreChoiceState(ChoiceState.all),
                    child: const Text(
                      "全选",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 12),
                  TextButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(
                        Theme.of(context).primaryColor,
                      ),
                    ),
                    onPressed: () => c.setScoreChoiceState(ChoiceState.none),
                    child: const Text(
                      "全不选",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 12),
                  TextButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(
                        Theme.of(context).primaryColor,
                      ),
                    ),
                    onPressed: () =>
                        c.setScoreChoiceState(ChoiceState.original),
                    child: const Text(
                      "重置选择",
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    c.bottomInfo,
                    textScaleFactor: 1.2,
                  ),
                  FloatingActionButton(
                    elevation: 0.0,
                    highlightElevation: 0.0,
                    focusElevation: 0.0,
                    disabledElevation: 0.0,
                    onPressed: () {
                      Navigator.of(context).push(
                        createRoute(const ScoreChoicePage()),
                      );
                    },
                    child: const Icon(
                      Icons.panorama_fisheye,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
