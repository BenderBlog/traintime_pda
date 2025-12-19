// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:watermeter/page/homepage/info_widget/schoolnet_card.dart';
import 'package:watermeter/page/homepage/notice_card/club_card.dart';
import 'package:watermeter/page/homepage/toolbox/class_attendance_card.dart';
import 'package:watermeter/page/public_widget/toast.dart';
import 'package:get/get.dart';
import 'package:watermeter/controller/classtable_controller.dart';
import 'package:watermeter/controller/exam_controller.dart';
import 'package:watermeter/controller/experiment_controller.dart';
import 'package:watermeter/page/homepage/info_widget/classtable_card.dart';
import 'package:watermeter/page/homepage/info_widget/electricity_card.dart';
import 'package:watermeter/page/homepage/info_widget/library_card.dart';
import 'package:watermeter/page/homepage/info_widget/school_card_info_card.dart';
import 'package:watermeter/page/homepage/refresh.dart';
import 'package:watermeter/page/homepage/toolbox/empty_classroom_card.dart';
import 'package:watermeter/page/homepage/toolbox/exam_card.dart';
import 'package:watermeter/page/homepage/toolbox/experiment_card.dart';
import 'package:watermeter/page/homepage/toolbox/score_card.dart';
import 'package:watermeter/page/homepage/toolbox/sport_card.dart';
import 'package:watermeter/repository/notification/course_reminder_service.dart';
import 'package:watermeter/repository/logger.dart';
import 'package:watermeter/page/homepage/toolbox/toolbox_card.dart';
import 'package:watermeter/page/login/jc_captcha.dart';
import 'package:watermeter/repository/preference.dart' as prefs;

class MainPage extends StatefulWidget {
  final Function()? changePage;

  const MainPage({super.key, this.changePage});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  void initState() {
    super.initState();
    Get.put(ClassTableController());
    Get.put(ExamController());
    Get.put(ExperimentController());

    // Validate and update notifications after controllers are initialized
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await CourseReminderService().initialize();
        await CourseReminderService().validateAndUpdateNotifications();
        log.info(
          "Notifications validated and updated after homepage initialization.",
        );
      } catch (e, stackTrace) {
        log.error(
          "Failed to validate notifications after homepage initialization",
          e,
          stackTrace,
        );
      }
    });
  }

  final List<Widget> smallFunction = [
    const ScoreCard(),
    const ExamCard(),
    const EmptyClassroomCard(),
    const ClassAttendanceCard(),
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

  TextStyle textStyle(BuildContext context) => TextStyle(
    fontSize: 16,
    color: Theme.of(context).colorScheme.primary,
    fontWeight: FontWeight.w700,
  );

  @override
  Widget build(BuildContext context) {
    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxScrolled) => [
        SliverAppBar(
          centerTitle: false,
          expandedHeight: 160,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            centerTitle: false,
            titlePadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 12,
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
                      color: Theme.of(context).brightness == Brightness.dark
                          ? null
                          : Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  Text(
                    c.state == ClassTableState.fetched
                        ? c.getCurrentWeek(updateTime) >= 0 &&
                                  c.getCurrentWeek(updateTime) <
                                      c.classTableData.semesterLength
                              ? FlutterI18n.translate(
                                  context,
                                  "homepage.on_weekday",
                                  translationParams: {
                                    "current":
                                        "${c.getCurrentWeek(updateTime) + 1}",
                                  },
                                )
                              : FlutterI18n.translate(
                                  context,
                                  "homepage.on_holiday",
                                )
                        : c.state == ClassTableState.error
                        ? FlutterI18n.translate(context, "homepage.load_error")
                        : FlutterI18n.translate(context, "homepage.loading"),
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? null
                          : Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
      body: RefreshIndicator(
        onRefresh: () async {
          showToast(
            context: context,
            msg: FlutterI18n.translate(context, "homepage.loading_message"),
          );
          await update(
            context: context,
            sliderCaptcha: (String cookieStr) {
              return SliderCaptchaClientProvider(
                cookie: cookieStr,
              ).solve(context);
            },
          );
          if (context.mounted) {
            showToast(
              context: context,
              msg: FlutterI18n.translate(context, "homepage.loaded"),
            );
          }
        },
        child: ListView(
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          children: [
            ClubPromotionCard(onTap: widget.changePage),
            const ClassTableCard(),
            ElectricityCard(),
            SchoolnetCard(),
            LibraryCard(),
            //LibraryCapacityCard(),
            SchoolCardInfoCard(),
            MediaQuery.removePadding(
              context: context,
              removeTop: true,
              child: GridView.extent(
                maxCrossAxisExtent: 96,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: smallFunction,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
