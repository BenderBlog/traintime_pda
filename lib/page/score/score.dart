/*
Score window.
Copyright 2023 SuperBart

This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:watermeter/page/score/score_choice.dart';
import 'package:watermeter/page/score/score_info_card.dart';
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
              height: 134,
              elevation: 5.0,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FilledButton(
                        onPressed: () {
                          for (var i in c.toShow) {
                            c.isSelected[i.mark] = true;
                          }
                          c.update();
                        },
                        child: const Text("全选"),
                      ),
                      const SizedBox(width: 12),
                      FilledButton(
                        onPressed: () {
                          for (var i in c.toShow) {
                            c.isSelected[i.mark] = false;
                          }
                          c.update();
                        },
                        child: const Text("全不选"),
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
                            createRoute(ScoreChoiceWindow()),
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
              if (Get.put(ScoreController()).presscount >= 4) {
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
            (index) => ScoreInfoCard(
              mark: c.toShow[index].mark,
              functionActivated: true,
            ),
          ),
          (toUse) => toUse,
        ),
      ),
      bottomNavigationBar: bottomInfo,
    );
  }
}
