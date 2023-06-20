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
import 'package:get/get.dart';
import 'package:watermeter/model/xidian_ids/score.dart';
import 'package:watermeter/page/widget.dart';
import 'package:watermeter/controller/score_controller.dart';

class ScoreWindow extends StatelessWidget {
  ScoreWindow({super.key});

  late final BuildContext context;

  Future<void> easterEgg() => showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("For VB, are you agree?"),
          content: Image.asset("assets/Humpy-Score.jpg"),
          actions: [
            TextButton(
              child: const Text("确定"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );

  Future<void> scoreInfoDialog() => showDialog(
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

  final Widget selectModeButton = GetBuilder<ScoreController>(
    builder: (c) => IconButton(
        icon: const Icon(Icons.calculate),
        onPressed: () {
          c.isSelectMod = !c.isSelectMod;
          c.update();
        }),
  );

  Widget get bottomInfo => GetBuilder<ScoreController>(
        builder: (c) => Visibility(
          visible: c.isSelectMod,
          child: BottomAppBar(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "目前选中科目的学分 ${c.evalCredit(false).toStringAsFixed(2)}\n"
                  "均分 ${c.evalAvg(false).toStringAsFixed(2)} GPA ${c.evalAvg(false, isGPA: true).toStringAsFixed(2)}",
                  textScaleFactor: 1.2,
                ),
                FloatingActionButton(
                  elevation: 0.0,
                  highlightElevation: 0.0,
                  focusElevation: 0.0,
                  disabledElevation: 0.0,
                  onPressed: () {
                    scoreInfoDialog();
                  },
                  child: const Icon(
                    Icons.panorama_fisheye,
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  final PreferredSizeWidget dropDownButton = PreferredSize(
    preferredSize: const Size.fromHeight(40),
    child: GetBuilder<ScoreController>(
      builder: (c) => SizedBox(
        height: 40,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            DropdownButton(
              value: c.chosenSemester,
              icon: const Icon(
                Icons.keyboard_arrow_down,
              ),
              underline: Container(
                height: 2,
              ),
              items: [
                const DropdownMenuItem(value: "", child: Text("所有学期")),
                for (var i in c.semester)
                  DropdownMenuItem(value: i, child: Text(i))
              ],
              onChanged: (String? value) {
                c.chosenSemester = value!;
                c.update();
              },
            ),
            DropdownButton(
              value: c.chosenStatus,
              icon: const Icon(
                Icons.keyboard_arrow_down,
              ),
              underline: Container(
                height: 2,
              ),
              items: [
                const DropdownMenuItem(value: "", child: Text("所有类型")),
                for (var i in c.statuses)
                  DropdownMenuItem(value: i, child: Text(i))
              ],
              onChanged: (String? value) {
                c.chosenStatus = value!;
                c.update();
              },
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          selectModeButton,
          IconButton(
            icon: const Icon(Icons.info),
            onPressed: () {
              easterEgg();
            },
          ),
        ],
        bottom: dropDownButton,
      ),
      body: GetBuilder<ScoreController>(
        builder: (c) => ListView.builder(
          itemBuilder: (builder, index) {
            return Column(
              children: [
                InkWell(
                  onTap: () {
                    if (c.isSelectMod) {
                      c.isSelected[c.toShow[index].mark] =
                          !c.isSelected[c.toShow[index].mark];
                      c.update();
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: c.isSelectMod && c.isSelected[c.toShow[index].mark]
                          ? Colors.yellow.shade100
                          : Colors.white,
                    ),
                    child: ScoreInfoCard(toUse: c.toShow[index]),
                  ),
                ),
              ],
            );
          },
          itemCount: c.toShow.length,
        ),
      ),
      bottomNavigationBar: bottomInfo,
    );
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
                    "GPA: ${toUse.gpa}",
                    textScaleFactor: 0.9,
                  ),
                  Text(
                    "成绩：${toUse.how == 1 || toUse.how == 2 ? toUse.level : toUse.score}",
                    textScaleFactor: 0.9,
                  )
                ],
              ),
            ],
          ),
        ));
  }
}
