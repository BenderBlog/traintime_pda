import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:watermeter/controller/classtable_controller.dart';
import 'package:watermeter/controller/exam_controller.dart';
import 'package:watermeter/page/homepage/phone/clipper.dart';
import 'package:watermeter/page/homepage/phone/info_widget/classtable_card.dart';
import 'package:watermeter/page/homepage/phone/info_widget/electricity_card.dart';
import 'package:watermeter/page/homepage/phone/info_widget/exam_card.dart';
import 'package:watermeter/page/homepage/phone/info_widget/score_card.dart';
import 'package:watermeter/page/homepage/phone/info_widget/sport_card.dart';

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

  @override
  Widget build(BuildContext context) {
    const double classCardHeight = 120.0;
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
          final height = state.offset + classCardHeight;
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
                  clipper: FillLineClipper(classCardHeight),
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
                  height: classCardHeight,
                  width: MediaQuery.of(context).size.width * 0.9,
                  child: const ClassTableCard(),
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
            expandedHeight: MediaQuery.of(context).size.width * 0.125,
            pinned: true,
            elevation: 0,
            title: GetBuilder<ClassTableController>(
              builder: (c) => Text("第 ${c.currentWeek} 周"),
            ),
          ),
          const HeaderLocator.sliver(paintExtent: classCardHeight),
          SliverToBoxAdapter(
            child: Card(
              elevation: 0,
              margin: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.05,
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  MediaQuery.removePadding(
                    context: context,
                    removeTop: true,
                    child: GridView.count(
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      childAspectRatio: 1.75,
                      children: const [
                        SportCard(),
                        ElectricityCard(),
                      ],
                    ),
                  ),
                  MediaQuery.removePadding(
                    context: context,
                    removeTop: true,
                    child: GridView.count(
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      childAspectRatio: 2.25,
                      children: const [
                        ScoreCard(),
                        ExamCard(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
