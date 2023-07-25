import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:watermeter/controller/score_controller.dart';
import 'package:watermeter/page/score/score_info_card.dart';
import 'package:watermeter/page/widget.dart';

class ScoreChoiceWindow extends StatelessWidget {
  const ScoreChoiceWindow({super.key});

  PreferredSizeWidget dropDownButton(context) => PreferredSize(
        preferredSize: const Size.fromHeight(40),
        child: GetBuilder<ScoreController>(
          builder: (c) => SizedBox(
            height: 40,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                DropdownButton(
                  focusColor: Theme.of(context).appBarTheme.backgroundColor,
                  borderRadius: const BorderRadius.all(Radius.circular(30)),
                  value: c.chosenSemesterInScoreChoice,
                  style: const TextStyle(color: Colors.black),
                  underline: Container(color: Colors.transparent),
                  onChanged: (String? value) {
                    c.chosenSemesterInScoreChoice = value!;
                    c.update();
                  },
                  items: [
                    const DropdownMenuItem(
                      value: "",
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Text("所有学期"),
                      ),
                    ),
                    for (var i in c.semester)
                      DropdownMenuItem(
                        value: i,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Text(i),
                        ),
                      ),
                  ],
                ),
                DropdownButton(
                  focusColor: Theme.of(context).appBarTheme.backgroundColor,
                  borderRadius: const BorderRadius.all(Radius.circular(30)),
                  value: c.chosenStatusInScoreChoice,
                  style: const TextStyle(color: Colors.black),
                  underline: Container(color: Colors.transparent),
                  items: [
                    const DropdownMenuItem(
                      value: "",
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Text("所有类型"),
                      ),
                    ),
                    for (var i in c.statuses)
                      DropdownMenuItem(
                        value: i,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Text(i),
                        ),
                      ),
                  ],
                  onChanged: (String? value) {
                    c.chosenStatusInScoreChoice = value!;
                    c.update();
                  },
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
