// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:watermeter/page/homepage/home_card_padding.dart';
import 'package:watermeter/page/public_widget/toast.dart';
import 'package:get/get.dart';
import 'package:easy_refresh/easy_refresh.dart';
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
import 'package:watermeter/page/homepage/toolbox/empty_classroom_card.dart';
import 'package:watermeter/page/homepage/toolbox/exam_card.dart';
import 'package:watermeter/page/homepage/toolbox/experiment_card.dart';
import 'package:watermeter/page/homepage/toolbox/score_card.dart';
import 'package:watermeter/page/homepage/toolbox/sport_card.dart';
import 'package:watermeter/page/homepage/toolbox/toolbox_card.dart';
import 'package:watermeter/page/login/jc_captcha.dart';
import 'package:watermeter/repository/preference.dart' as prefs;

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

  final List<Widget> smallFunction = [
    const ScoreCard(),
    const ExamCard(),
    const EmptyClassroomCard(),
    if (prefs.getBool(prefs.Preference.role) == false) ...[
      const ExperimentCard(),
      const SportCard(),
    ],
    const ToolboxCard(),
  ];

  String get _now {
    DateTime now = DateTime.now();

    if (now.hour >= 5 && now.hour < 9) {
      return "homepage.time_string.morning";
    }
    if (now.hour >= 9 && now.hour < 11) {
      return "homepage.time_string.before_noon";
    }
    if (now.hour >= 11 && now.hour < 14) {
      return "homepage.time_string.at_noon";
    }
    if (now.hour >= 14 && now.hour < 18) {
      return "homepage.time_string.afternoon";
    }
    if (now.hour >= 18 || now.hour == 0) {
      return "homepage.time_string.night";
    }
    return "homepage.time_string.midnight";
  }

  TextStyle textStyle(context) => TextStyle(
        fontSize: 16,
        color: Theme.of(context).colorScheme.primary,
        fontWeight: FontWeight.w700,
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ExtendedNestedScrollView(
        onlyOneScrollInBody: true,
        pinnedHeaderSliverHeightBuilder: () {
          return MediaQuery.of(context).padding.top + kToolbarHeight;
        },
        headerSliverBuilder: (context, innerBoxIsScrolled) => <Widget>[
          SliverAppBar(
            centerTitle: false,
            backgroundColor: Theme.of(context).colorScheme.surface,
            expandedHeight: 160,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: false,
              titlePadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 10,
              ),
              title: GetBuilder<ClassTableController>(
                builder: (c) => Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      FlutterI18n.translate(context, _now),
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
                              ? FlutterI18n.translate(
                                  context,
                                  "homepage.on_weekday",
                                  translationParams: {
                                    "current":
                                        "${c.getCurrentWeek(updateTime) + 1}"
                                  },
                                )
                              : FlutterI18n.translate(
                                  context,
                                  "homepage.on_holiday",
                                )
                          : c.state == ClassTableState.error
                              ? FlutterI18n.translate(
                                  context,
                                  "homepage.load_error",
                                )
                              : FlutterI18n.translate(
                                  context,
                                  "homepage.loading",
                                ),
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
            showToast(
              context: context,
              msg: FlutterI18n.translate(
                context,
                "homepage.loading_message",
              ),
            );
            update(
                context: context,
                sliderCaptcha: (String cookieStr) {
                  return SliderCaptchaClientProvider(cookie: cookieStr)
                      .solve(context);
                });
          },
          header: PhoenixHeader(
            skyColor: Theme.of(context).colorScheme.surface,
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
                  if (prefs.getBool(prefs.Preference.role))
                    Text(
                      FlutterI18n.translate(
                        context,
                        "homepage.postgraduate_notice",
                      ),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    )
                        .center()
                        .constrained(height: 30)
                        .paddingDirectional(
                          horizontal: 16,
                          vertical: 14,
                        )
                        .withHomeCardStyle(
                          Theme.of(context).colorScheme.secondary,
                        ),
                  const ClassTableCard(),
                  ...children,
                  GridView.extent(
                    maxCrossAxisExtent: 96,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: smallFunction,
                  ),
                ].toColumn().padding(
                      vertical: 8,
                      horizontal: 16,
                    )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
