// Copyright 2025 BenderBlog Rodriguez and contributors.
// Copyright 2025 Traintime PDA Authors
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:watermeter/controller/classtable_controller.dart';
import 'package:watermeter/model/xidian_ids/class_attendance.dart';
import 'package:watermeter/page/class_attendance/class_attandance_card.dart';
import 'package:watermeter/page/class_attendance/class_attendance_table.dart';
import 'package:watermeter/page/public_widget/empty_list_view.dart';
import 'package:watermeter/page/public_widget/public_widget.dart';
import 'package:watermeter/page/public_widget/timeline_widget/timeline_title.dart';
import 'package:watermeter/page/public_widget/timeline_widget/timeline_widget.dart';
import 'package:watermeter/repository/xidian_ids/learning_session.dart';
import 'package:get/get.dart';

class ClassAttendanceView extends StatefulWidget {
  const ClassAttendanceView({super.key});

  @override
  State<ClassAttendanceView> createState() => _ClassAttendanceViewState();
}

class _ClassAttendanceViewState extends State<ClassAttendanceView> {
  late Future<List<ClassAttendance>> coursesFuture;
  late ClassTableController controller;
  late Map<String, int> classTimes;

  Future<List<ClassAttendance>> loadDataFunction() async =>
      LearningSession().getAttandanceRecord();

  @override
  void initState() {
    super.initState();
    coursesFuture = loadDataFunction();
    controller = Get.put(ClassTableController());
    classTimes = controller.numberOfClass;
  }

  Future<void> _refreshData() async {
    setState(() {
      coursesFuture = loadDataFunction();
      classTimes = controller.numberOfClass;
    });
  }

  @override
  Widget build(BuildContext context) {
    // 判断是否使用表格视图：宽度大于 800 时使用表格（考虑表格需要更多空间）
    final bool useTableView = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      appBar: AppBar(
        title: Text(FlutterI18n.translate(context, "class_attendance.title")),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: FutureBuilder<List<ClassAttendance>>(
          future: coursesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return ReloadWidget(
                function: () => _refreshData(),
                errorStatus: snapshot.error,
                stackTrace: snapshot.stackTrace,
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return EmptyListView(
                text: FlutterI18n.translate(
                  context,
                  "class_attendance.no_data",
                ),
                type: EmptyListViewType.rolling,
              );
            }

            final courses = snapshot.data!;

            // 使用表格视图（平板/电脑端）
            if (useTableView) {
              return ClassAttendanceTable(
                courses: courses,
                classTimes: classTimes,
              );
            }

            // 使用卡片视图（移动端）
            final courseCards = courses.map((classAttendance) {
              int times = classTimes[classAttendance.courseName] ?? 0;
              return CourseCard(course: classAttendance, totalTimes: times);
            }).toList();

            final warningCourses = courseCards.toList()
              ..retainWhere((e) => e.attendanceStatus.contains("warning"));
            final ineligibleCourses = courseCards.toList()
              ..retainWhere((e) => e.attendanceStatus.contains("ineligible"));
            final eligibleCourses = courseCards.toList()
              ..retainWhere((e) => e.attendanceStatus.contains("eligible"));
            final unknownCourses = courseCards.toList()
              ..retainWhere((e) => e.attendanceStatus.contains("unknown"));

            return TimelineWidget(
              isTitle: [
                if (ineligibleCourses.isNotEmpty) ...[true, false],
                if (warningCourses.isNotEmpty) ...[true, false],
                if (eligibleCourses.isNotEmpty) ...[true, false],
                if (unknownCourses.isNotEmpty) ...[true, false],
              ],
              children: [
                if (ineligibleCourses.isNotEmpty) ...[
                  TimelineTitle(
                    title: FlutterI18n.translate(
                      context,
                      "class_attendance.course_state.ineligible",
                    ),
                  ),
                  ineligibleCourses.toColumn(),
                ],
                if (warningCourses.isNotEmpty) ...[
                  TimelineTitle(
                    title: FlutterI18n.translate(
                      context,
                      "class_attendance.course_state.warning",
                    ),
                  ),
                  warningCourses.toColumn(),
                ],
                if (eligibleCourses.isNotEmpty) ...[
                  TimelineTitle(
                    title: FlutterI18n.translate(
                      context,
                      "class_attendance.course_state.eligible",
                    ),
                  ),
                  eligibleCourses.toColumn(),
                ],
                if (unknownCourses.isNotEmpty) ...[
                  TimelineTitle(
                    title: FlutterI18n.translate(
                      context,
                      "class_attendance.course_state.unknown",
                    ),
                  ),
                  unknownCourses.toColumn(),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}
