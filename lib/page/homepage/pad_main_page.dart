import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:watermeter/controller/classtable_controller.dart';
import 'package:watermeter/controller/exam_controller.dart';
import 'package:watermeter/controller/score_controller.dart';
import 'package:watermeter/page/homepage/info_widget/classtable_card.dart';
import 'package:watermeter/page/homepage/info_widget/electricity_card.dart';
import 'package:watermeter/page/homepage/info_widget/exam_card.dart';
import 'package:watermeter/page/homepage/info_widget/score_card.dart';
import 'package:watermeter/page/homepage/info_widget/sport_card.dart';
import 'package:watermeter/page/homepage/refresh.dart';

class PadMainPage extends StatelessWidget {
  final classTableController = Get.put(ClassTableController());
  final examController = Get.put(ExamController());
  final scoreController = Get.put(ScoreController());

  PadMainPage({super.key});

  final inBetweenCardHeight = 135.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: GetBuilder<ClassTableController>(
          builder: (c) => Text("第 ${c.currentWeek + 1} 周"),
        ),
        actions: [
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                behavior: SnackBarBehavior.floating,
                content: Text("请稍候，正在刷新信息"),
              ));
              update();
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Row(
        children: [
          Expanded(
            child: ListView(
              shrinkWrap: true,
              children: [
                SizedBox(
                  height: inBetweenCardHeight,
                  child: const ClassTableCard(),
                ),
                const SizedBox(
                  height: 260,
                  child: SportCard(),
                ),
              ],
            ),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.20 < 200
                ? 200
                : MediaQuery.of(context).size.width * 0.20,
            child: Column(
              children: [
                const SizedBox(
                  height: 100,
                  child: ElectricityCard(),
                ),
                ScoreCard(),
                const ExamCard(),
              ],
            ),
          )
        ],
      ),
    );
  }
}
