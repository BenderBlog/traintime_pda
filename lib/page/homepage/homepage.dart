// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:watermeter/page/homepage/notice_card/update_card.dart';
import 'package:watermeter/page/homepage/toolbox/class_attendance_card.dart';
import 'package:watermeter/page/homepage/toolbox/schoolnet_card.dart';
import 'package:watermeter/page/public_widget/toast.dart';
import 'package:watermeter/page/homepage/info_widget/classtable_card.dart';
import 'package:watermeter/page/homepage/info_widget/energy_card.dart';
import 'package:watermeter/page/homepage/info_widget/library_card.dart';
import 'package:watermeter/page/homepage/info_widget/school_card_info_card.dart';
import 'package:watermeter/page/homepage/refresh.dart';
import 'package:watermeter/page/homepage/toolbox/empty_classroom_card.dart';
import 'package:watermeter/page/homepage/toolbox/exam_card.dart';
import 'package:watermeter/page/homepage/toolbox/experiment_card.dart';
import 'package:watermeter/page/homepage/toolbox/score_card.dart';
import 'package:watermeter/page/homepage/toolbox/sport_card.dart';
import 'package:watermeter/page/homepage/toolbox/dorm_water_card.dart';
import 'package:watermeter/repository/notification/course_reminder_service.dart';
import 'package:watermeter/repository/logger.dart';
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
    const SchoolnetCard(),
    const DormWaterCard(),
    if (prefs.getBool(prefs.Preference.role) == false) ...[
      const ExperimentCard(),
      const SportCard(),
    ],
  ];

  TextStyle textStyle(BuildContext context) => TextStyle(
    fontSize: 16,
    color: Theme.of(context).colorScheme.primary,
    fontWeight: FontWeight.w700,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(FlutterI18n.translate(context, "homepage.title")),
      ),

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
            UpdateCard().padding(bottom: 8),
            const ClassTableCard().padding(bottom: 8),
            EnergyCard().padding(bottom: 8),
            // SchoolnetCard().padding(bottom: 8),
            LibraryCard().padding(bottom: 8),
            SchoolCardInfoCard().padding(bottom: 8),
            MediaQuery.removePadding(
              context: context,
              removeTop: true,
              child: GridView.extent(
                maxCrossAxisExtent: 96,
                shrinkWrap: true,
                mainAxisSpacing: 8.0,
                crossAxisSpacing: 8.0,
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
