// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:jiffy/jiffy.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:watermeter/controller/classtable_controller.dart';
import 'package:watermeter/controller/exam_controller.dart';
import 'package:watermeter/controller/experiment_controller.dart';
import 'package:watermeter/page/homepage/info_widget/classtable_card.dart';
import 'package:watermeter/page/homepage/info_widget/electricity_card.dart';
import 'package:watermeter/page/homepage/info_widget/library_card.dart';
import 'package:watermeter/page/homepage/info_widget/school_card_info_card.dart';
import 'package:watermeter/page/homepage/info_widget/notice_card/notice_card.dart';
import 'package:watermeter/page/homepage/refresh.dart';
import 'package:watermeter/page/homepage/toolbox/creative_card.dart';
import 'package:watermeter/page/homepage/toolbox/empty_classroom_card.dart';
import 'package:watermeter/page/homepage/toolbox/exam_card.dart';
import 'package:watermeter/page/homepage/toolbox/experiment_card.dart';
import 'package:watermeter/page/homepage/toolbox/score_card.dart';
import 'package:watermeter/page/homepage/toolbox/sport_card.dart';
import 'package:watermeter/page/homepage/toolbox/telebook_card.dart';
import 'package:watermeter/page/homepage/toolbox/toolbox_card.dart';
import 'package:watermeter/page/login/jc_captcha.dart';
import 'package:watermeter/page/public_widget/public_widget.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  void initState() {
    Get.put(ClassTableController());
    Get.put(ExamController());
    Get.put(ExperimentController());
    super.initState();
  }

  final List<Widget> children = const [
    ElectricityCard(),
    LibraryCard(),
    SchoolCardInfoCard(),
  ];

  final List<Widget> smallFunction = const [
    ScoreCard(),
    ExamCard(),
    EmptyClassroomCard(),
    ExperimentCard(),
    SportCard(),
    TeleBookCard(),
    CreativeCard(),
    ToolboxCard(),
  ];

  String get _now {
    DateTime now = DateTime.now();

    if (now.hour >= 5 && now.hour < 9) return "早上好 准备出发";

    if (now.hour >= 9 && now.hour < 11) return "上午好 祝万事如意";

    if (now.hour >= 11 && now.hour < 14) return "中午好 一切还好吧";

    if (now.hour >= 14 && now.hour < 17) return "下午好 今天如何";

    return "晚上好 祝你好梦";
  }

  TextStyle textStyle(context) => TextStyle(
        fontSize: 16,
        color: Theme.of(context).colorScheme.primary,
        fontWeight: FontWeight.w700,
      );

  @override
  Widget build(BuildContext context) {
    double sideBlankRatio = isPhone(context) ? 0.05 : 0.10;

    return Scaffold(
      body: ExtendedNestedScrollView(
        onlyOneScrollInBody: true,
        pinnedHeaderSliverHeightBuilder: () {
          return MediaQuery.of(context).padding.top + kToolbarHeight;
        },
        headerSliverBuilder: (context, innerBoxIsScrolled) => <Widget>[
          SliverAppBar(
            centerTitle: false,
            backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
            expandedHeight: 160,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: false,
              titlePadding: EdgeInsets.symmetric(
                horizontal:
                    MediaQuery.sizeOf(context).width * sideBlankRatio + 4,
                vertical: 10,
              ),
              title: GetBuilder<ClassTableController>(
                builder: (c) => Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _now,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    Text(
                      /// TODO: check it
                      c.state == ClassTableState.fetched
                          ? c.getCurrentWeek(updateTime) >= 0 &&
                                  c.getCurrentWeek(updateTime) <
                                      c.classTableData.semesterLength
                              ? "${Jiffy.parseFromDateTime(updateTime).format(pattern: "M月dd日")} 第 ${c.getCurrentWeek(updateTime) + 1} 周 "
                              : "${Jiffy.parseFromDateTime(updateTime).format(pattern: "M月dd日")} 假期中"
                          : c.state == ClassTableState.error
                              ? "加载错误"
                              : "正在加载",
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
        body: EasyRefresh(
          onRefresh: () {
            Fluttertoast.showToast(
              msg: "请稍候，正在刷新信息",
              timeInSecForIosWeb: 1,
            );
            update(sliderCaptcha: (String cookieStr) {
              return Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => CaptchaWidget(cookie: cookieStr),
                ),
              );
            });
          },
          header: PhoenixHeader(
            skyColor: Theme.of(context).colorScheme.secondaryContainer,
            position: IndicatorPosition.locator,
            safeArea: true,
          ),
          child: MediaQuery.removePadding(
            context: context,
            removeTop: true,
            child: ListView(
              children: [
                const HeaderLocator(),
                <Widget>[
                  const NoticeCard(),
                  if (isPhone(context)) ...[
                    const ClassTableCard(),
                    ...children,
                    GridView.count(
                      crossAxisCount: 4,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: smallFunction,
                    ),
                  ] else ...[
                    const ClassTableCard(),
                    children.map((e) => e.flexible(flex: 1)).toList().toRow(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                        ),
                    GridView.extent(
                      maxCrossAxisExtent: 96,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: smallFunction,
                    ),
                  ]
                ].toColumn().padding(
                      vertical: 8,
                      horizontal:
                          MediaQuery.of(context).size.width * sideBlankRatio,
                    )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
