import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:watermeter/controller/classtable_controller.dart';
import 'package:watermeter/page/homepage/info_widget/main_page_card/classtable_card.dart';
import 'package:watermeter/page/homepage/info_widget/main_page_card/electricity_card.dart';
import 'package:watermeter/page/homepage/info_widget/main_page_card/library_card.dart';
import 'package:watermeter/page/homepage/info_widget/small_function_card/empty_classroom_card.dart';
import 'package:watermeter/page/homepage/info_widget/small_function_card/exam_card.dart';
import 'package:watermeter/page/homepage/info_widget/small_function_card/repair_card.dart';
import 'package:watermeter/page/homepage/info_widget/small_function_card/school_card_info_card.dart';
import 'package:watermeter/page/homepage/info_widget/small_function_card/score_card.dart';
import 'package:watermeter/page/homepage/info_widget/main_page_card/sport_card.dart';
import 'package:watermeter/repository/xidian_sport_session.dart';
import 'package:watermeter/page/homepage/refresh.dart';

class PadMainPage extends StatelessWidget {
  const PadMainPage({super.key});

  final inBetweenCardHeight = 135.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: GetBuilder<ClassTableController>(
          builder: (c) =>
              Text(c.isNotVacation ? "第 ${c.currentWeek + 1} 周" : "假期中"),
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
              children: [
                SizedBox(
                  height: inBetweenCardHeight,
                  child: const ClassTableCard(),
                ),
                Obx(
                  () => SizedBox(
                    height: punchData.value.all.isNotEmpty ? 200 : 100,
                    child: const SportCard(),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.20 < 200
                ? 200
                : MediaQuery.of(context).size.width * 0.20,
            child: ListView(
              children: const [
                ElectricityCard(),
                LibraryCard(),
                ScoreCard(),
                ExamCard(),
                SchoolCardInfoCard(),
                EmptyClassroomCard(),
                ToolCard(),
              ],
            ),
          )
        ],
      ),
    );
  }
}
