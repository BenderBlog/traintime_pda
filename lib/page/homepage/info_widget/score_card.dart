import 'package:flutter/material.dart';
import 'package:watermeter/page/score/score.dart';
import 'package:watermeter/controller/score_controller.dart';

class ScoreCard extends StatelessWidget {
  ScoreCard({super.key});

  final ScoreController c = ScoreController();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (c.error == null) {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => ScoreWindow()));
        } else if (c.error == "正在加载") {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text(
              "请稍候 正在获取成绩信息",
            ),
          ));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text("遇到错误，${c.error}"),
          ));
        }
      },
      onLongPress: () {
        if (c.isGet) {
          c.get();
        }
      },
      child: Card(
        elevation: 0,
        color: Theme.of(context).colorScheme.primaryContainer,
        child: const Padding(
          padding: EdgeInsets.all(10),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Icon(
                  Icons.score,
                  size: 48,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "成绩查询",
                      style: TextStyle(fontSize: 18),
                    ),
                    Text(
                      "可计算平均分",
                      style: TextStyle(fontSize: 12),
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
