import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:watermeter/controller/classtable_controller.dart';
import 'package:watermeter/controller/exam_controller.dart';
import 'package:watermeter/page/homepage/info_widget/classtable_card.dart';
import 'package:watermeter/page/homepage/info_widget/electricity_card.dart';
import 'package:watermeter/page/homepage/info_widget/exam_card.dart';
import 'package:watermeter/page/homepage/info_widget/score_card.dart';
import 'package:watermeter/page/homepage/info_widget/sport_card.dart';

class PhoneMainPage extends StatelessWidget {
  final classTableController = Get.put(ClassTableController());
  final examController = Get.put(ExamController());

  PhoneMainPage({super.key});

  Future<void> _update() async {
    await classTableController.updateClassTable(isForce: true);
    classTableController.update();
    await examController.get();
    examController.update();
  }

  final inBetweenCardHeight = 135.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: GetBuilder<ClassTableController>(
          builder: (c) => Text("第 ${c.currentWeek + 1} 周"),
        ),
      ),
      body: EasyRefresh(
        onRefresh: () async {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text("请稍候，正在刷新信息"),
          ));
          await _update();
        },
        header: PhoenixHeader(
          skyColor: Theme.of(context).colorScheme.primary,
          position: IndicatorPosition.locator,
          safeArea: false,
        ),
        child: ListView(
          children: [
            const HeaderLocator(
              paintExtent: 1.0,
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.025),
              child: const ClassTableCard(),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.025),
              child: AspectRatio(
                aspectRatio: MediaQuery.of(context).size.width / 260,
                child: const SportCard(),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.025),
              child: AspectRatio(
                aspectRatio: MediaQuery.of(context).size.width / 100,
                child: const ElectricityCard(),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.025),
              child: GridView.count(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                childAspectRatio: MediaQuery.of(context).size.width / 160,
                children: const [
                  ScoreCard(),
                  ExamCard(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
