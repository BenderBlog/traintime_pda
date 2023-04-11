import 'package:flutter/material.dart';
import 'package:watermeter/page/score/score.dart';
import 'package:watermeter/repository/xidian_ids/score_session.dart';

class ScoreCard extends StatelessWidget {
  const ScoreCard({super.key});

  @override
  Widget build(BuildContext context) {
    if (situation == "" && scoreList.isEmpty) {
      ScoreFile().getScore();
    }
    return GestureDetector(
      onTap: () {
        if (situation.isEmpty) {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => ScoreWindow(scores: scoreList)));
        } else if (situation == "正在加载") {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text(
              "请稍候 正在获取成绩信息",
            ),
          ));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text("遇到错误，$situation"),
          ));
        }
      },
      onLongPress: ScoreFile().getScore,
      child: Card(
        elevation: 0,
        color: Theme.of(context).colorScheme.primaryContainer,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const Icon(
                  Icons.score,
                  size: 48,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
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
