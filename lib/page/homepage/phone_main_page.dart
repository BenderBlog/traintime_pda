import 'package:flutter/material.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';
import 'package:get/get.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:watermeter/controller/classtable_controller.dart';
import 'package:watermeter/page/clipper.dart';
import 'package:watermeter/page/homepage/info_widget/main_page_card/classtable_card.dart';
import 'package:watermeter/page/homepage/info_widget/main_page_card/electricity_card.dart';
import 'package:watermeter/page/homepage/info_widget/main_page_card/library_card.dart';
import 'package:watermeter/page/homepage/info_widget/small_function_card/empty_classroom_card.dart';
import 'package:watermeter/page/homepage/info_widget/small_function_card/exam_card.dart';
import 'package:watermeter/page/homepage/info_widget/main_page_card/school_card_info_card.dart';
import 'package:watermeter/page/homepage/info_widget/small_function_card/score_card.dart';
import 'package:watermeter/page/homepage/info_widget/main_page_card/sport_card.dart';
import 'package:watermeter/page/homepage/refresh.dart';

class PhoneMainPage extends StatelessWidget {
  const PhoneMainPage({super.key});

  final classCardHeight = 140.0;

  final List<Widget> children = const [
    SportCard(),
    ElectricityCard(),
    LibraryCard(),
    SchoolCardInfoCard(),
    ScoreCard(),
    ExamCard(),
    EmptyClassroomCard(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: GetBuilder<ClassTableController>(
          builder: (c) => Text(
            c.isGet
                ? c.isNotVacation
                    ? "第 ${c.currentWeek + 1} 周"
                    : "假期中"
                : c.error != null
                    ? "加载错误"
                    : "正在加载",
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
      body: EasyRefresh(
        onRefresh: () {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text("请稍候，正在刷新信息"),
          ));
          update();
        },
        header: PhoenixHeader(
          skyColor: Theme.of(context).colorScheme.primary,
          position: IndicatorPosition.locator,
          safeArea: false,
        ),
        child: ListView(
          children: [
            const HeaderLocator(),
            Stack(
              alignment: Alignment.center,
              children: [
                ClipPath(
                  clipper: RoundClipper(
                    height: classCardHeight,
                  ),
                  child: Container(
                    height: classCardHeight,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width * 0.025,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: classCardHeight),
                    child: const ClassTableCard(),
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.025),
              child: LayoutGrid(
                columnSizes: [1.fr, 1.fr],
                rowSizes: const [auto, auto, auto, auto],
                children: children,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
