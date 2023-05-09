import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:watermeter/controller/classtable_controller.dart';
import 'package:watermeter/controller/exam_controller.dart';
import 'package:watermeter/page/homepage/clipper.dart';
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
    return EasyRefresh(
      onRefresh: () async {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text("请稍候，正在刷新信息"),
        ));
        await _update();
      },
      header: BuilderHeader(
        clamping: false,
        position: IndicatorPosition.locator,
        triggerOffset: MediaQuery.of(context).size.height * 0.025,
        notifyWhenInvisible: true,
        builder: (context, state) {
          final height = state.offset + inBetweenCardHeight;
          return Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              ClipPath(
                clipper: RoundClipper(
                  height: height,
                ),
                child: Container(
                  height: height,
                  color: Theme.of(context).colorScheme.surfaceVariant,
                ),
              ),
              Positioned(
                top: -1,
                left: 0,
                right: 0,
                child: ClipPath(
                  clipper: FillLineClipper(inBetweenCardHeight),
                  child: Container(
                    height: 2,
                    width: double.infinity,
                    color: Theme.of(context).colorScheme.surfaceVariant,
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                child: SizedBox(
                  height: inBetweenCardHeight,
                  width: MediaQuery.of(context).size.width * 0.9,
                  child: AspectRatio(
                    aspectRatio:
                        MediaQuery.of(context).size.width / inBetweenCardHeight,
                    child: const ClassTableCard(),
                  ),
                ),
              ),
            ],
          );
        },
      ),
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
            foregroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
            expandedHeight: MediaQuery.of(context).size.width * 0.3,
            pinned: true,
            elevation: 0,
            title: GetBuilder<ClassTableController>(
              builder: (c) => Text("第 ${c.currentWeek + 1} 周"),
            ),
          ),
          HeaderLocator.sliver(paintExtent: inBetweenCardHeight),
          SliverToBoxAdapter(
            child: Column(
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.9,
                  child: AspectRatio(
                    aspectRatio: MediaQuery.of(context).size.width / 260,
                    child: const SportCard(),
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.9,
                  child: AspectRatio(
                    aspectRatio: MediaQuery.of(context).size.width / 100,
                    child: const ElectricityCard(),
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.9,
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
        ],
      ),
    );
  }
}
