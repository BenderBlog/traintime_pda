import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:watermeter/controller/classtable_controller.dart';
import 'package:watermeter/page/clipper.dart';
import 'package:watermeter/page/homepage/info_widget/main_page_card/classtable_card.dart';
import 'package:watermeter/page/homepage/info_widget/main_page_card/electricity_card.dart';
import 'package:watermeter/page/homepage/info_widget/main_page_card/library_card.dart';
import 'package:watermeter/page/homepage/info_widget/small_function_card/empty_classroom_card.dart';
import 'package:watermeter/page/homepage/info_widget/small_function_card/exam_card.dart';
import 'package:watermeter/page/homepage/info_widget/small_function_card/school_card_info_card.dart';
import 'package:watermeter/page/homepage/info_widget/small_function_card/score_card.dart';
import 'package:watermeter/page/homepage/info_widget/main_page_card/sport_card.dart';
import 'package:watermeter/repository/xidian_sport_session.dart';
import 'package:watermeter/page/homepage/refresh.dart';

class PadMainPage extends StatelessWidget {
  const PadMainPage({super.key});

  final inBetweenCardHeight = 136.0;

  double width(context) => MediaQuery.sizeOf(context).width;
  double height(context) => MediaQuery.sizeOf(context).height;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: GetBuilder<ClassTableController>(
          builder: (c) => Text(
            c.isGet
                ? c.isNotVacation
                    ? "第 ${c.currentWeek + 1} 周"
                    : "假期中"
                : c.error != null
                    ? "加载错误"
                    : "正在加载",
          ),
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
      body: ListView(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.025,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 140),
              child: const ClassTableCard(),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.025),
            child: GridView.count(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 4,
              childAspectRatio:
                  width(context) > height(context) ? 7 / 4 : 3 / 2,
              children: const [
                SportCard(),
                ElectricityCard(),
                LibraryCard(),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.025),
            child: GridView.count(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 4,
              childAspectRatio: width(context) > height(context) ? 5 / 2 : 2,
              children: const [
                SchoolCardInfoCard(),
                ScoreCard(),
                ExamCard(),
                EmptyClassroomCard(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
