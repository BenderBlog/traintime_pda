import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:watermeter/controller/score_controller.dart';
import 'package:watermeter/page/score/score_info_card.dart';

class ScoreChoiceWindow extends StatelessWidget {
  const ScoreChoiceWindow({super.key});

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
        ),
        body: ListView(
          children: [
            for (var i = 0; i < c.isSelected.length; ++i)
              if (c.isSelected[i] == true)
                Dismissible(
                  key: ValueKey<int>(i),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Theme.of(context).colorScheme.background,
                    alignment: const Alignment(0.95, 0),
                    child: const Icon(
                      Icons.cancel,
                      color: Colors.red,
                      size: 48,
                    ),
                  ),
                  child: ScoreInfoCard(
                    mark: i,
                    functionActivated: false,
                  ),
                  onDismissed: (DismissDirection direction) {
                    c.isSelected[i] = !c.isSelected[i];
                    c.update();
                  },
                ),
          ],
        ),
        bottomNavigationBar: BottomAppBar(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "目前选中科目的学分 ${c.evalCredit(false).toStringAsFixed(2)}\n"
                "均分 ${c.evalAvg(false).toStringAsFixed(2)} GPA ${c.evalAvg(false, isGPA: true).toStringAsFixed(2)}",
                textScaleFactor: 1.2,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
