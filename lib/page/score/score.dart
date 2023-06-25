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
import 'package:watermeter/page/score/score_info.dart';
import 'package:watermeter/page/widget.dart';
import 'package:watermeter/controller/score_controller.dart';

class ScoreWindow extends StatelessWidget {
  ScoreWindow({super.key});

  late final BuildContext context;

  Future<void> easterEgg() => showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("和人家比不如和自己比"),
          content: Image.asset("assets/Humpy-Score.jpg"),
          actions: [
            TextButton(
              child: const Text("确定"),
              onPressed: () {
                Get.put(ScoreController()).addCount();
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
              if (Get.put(ScoreController()).presscount >= 5) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text("行吧，不过别自找麻烦，我可不管"),
                ));
              }
              easterEgg();
            },
          ),
        ],
        bottom: dropDownButton,
      ),
      body: GetBuilder<ScoreController>(
        builder: (c) => dataList<ScoreInfoCard, ScoreInfoCard>(
          List.generate(
            c.toShow.length,
            (index) => ScoreInfoCard(index: index),
          ),
          (toUse) => toUse,
        ),
      ),
      bottomNavigationBar: bottomInfo,
    );
  }
}

class ScoreInfoCard extends StatelessWidget {
  final int index;
  const ScoreInfoCard({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ScoreController>(
      builder: (c) => GestureDetector(
        onTap: () {
          if (c.isSelectMod) {
            c.isSelected[c.toShow[index].mark] =
                !c.isSelected[c.toShow[index].mark];
            c.update();
          } else {
            showModalBottomSheet(
              builder: (((context) {
                return ScoreComposeCard(
                  score: c.toShow[index],
                );
              })),
              context: context,
            );
          }
        },
        child: Card(
          margin: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 5,
          ),
          elevation: 0,
          color: c.isSelectMod && c.isSelected[c.toShow[index].mark]
              ? Theme.of(context).colorScheme.tertiary.withOpacity(0.2)
              : Theme.of(context).colorScheme.primary.withOpacity(0.1),
          child: Container(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  children: [
                    Text(
                      c.toShow[index].name,
                      textScaleFactor: 1.1,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const Divider(
                      color: Colors.transparent,
                      height: 5,
                    ),
                    Row(
                      children: [
                        TagsBoxes(
                          text: c.toShow[index].year,
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 5),
                        TagsBoxes(
                          text: c.toShow[index].status,
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                        ),
                      ],
                    ),
                    const Divider(
                      color: Colors.transparent,
                      height: 5,
                    ),
                    Text(
                      "学分: ${c.toShow[index].credit}",
                    ),
                    Text(
                      "GPA: ${c.toShow[index].gpa}",
                    ),
                    Text(
                      "成绩：${c.toShow[index].how == 1 || c.toShow[index].how == 2 ? c.toShow[index].level : c.toShow[index].score}",
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
