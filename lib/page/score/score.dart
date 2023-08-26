// Copyright 2023 BenderBlog Rodriguez.
// SPDX-License-Identifier: MPL-2.0

// Score Window

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:watermeter/page/column_choose_dialog.dart';
import 'package:watermeter/page/score/score_choice.dart';
import 'package:watermeter/page/score/score_info_card.dart';
import 'package:watermeter/page/widget.dart';
import 'package:watermeter/controller/score_controller.dart';

class ScoreWindow extends StatelessWidget {
  ScoreWindow({super.key});

  late final BuildContext context;

  final Widget selectModeButton = GetBuilder<ScoreController>(
    builder: (c) => IconButton(
      icon: const Icon(Icons.calculate),
      onPressed: () {
        c.isSelectMod = !c.isSelectMod;
        c.update();
      },
    ),
  );

  Widget get bottomInfo => GetBuilder<ScoreController>(
        builder: (c) => Visibility(
          visible: c.isSelectMod,
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
                        onPressed: () {
                          for (var i in c.toShow) {
                            c.isSelected[i.mark] = true;
                          }
                          c.update();
                        },
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
                        onPressed: () {
                          for (var i in c.toShow) {
                            c.isSelected[i.mark] = false;
                          }
                          c.update();
                        },
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
                        onPressed: () {
                          c.resetChoice();
                          c.update();
                        },
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
                            createRoute(const ScoreChoiceWindow()),
                          );
                        },
                        child: const Icon(
                          Icons.panorama_fisheye,
                        ),
                      ),
                    ],
                  ),
                ],
              )),
        ),
      );

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
                      c.chosenSemester = ["", ...c.semester].toList()[value!];
                      c.update();
                    });
                  },
                  child: Text(
                    "学期 ${c.chosenSemester == "" ? "所有学期" : c.chosenSemester}",
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
                      c.chosenStatus = ["", ...c.statuses].toList()[value!];
                      c.update();
                    });
                  },
                  child: Text(
                    "类型 ${c.chosenStatus == "" ? "所有类型" : c.chosenStatus}",
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    this.context = context;
    return Scaffold(
      appBar: AppBar(
        title: const Text("成绩查询"),
        actions: [
          selectModeButton,
        ],
        bottom: dropDownButton(context),
      ),
      body: GetBuilder<ScoreController>(
        builder: (c) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: fixHeightGrid(
            height: 120,
            maxCrossAxisExtent: 360,
            children: List.generate(
              c.toShow.length,
              (index) => ScoreInfoCard(
                mark: c.toShow[index].mark,
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: bottomInfo,
    );
  }
}
