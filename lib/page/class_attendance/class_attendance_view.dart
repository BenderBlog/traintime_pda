// Copyright 2025 BenderBlog Rodriguez and contributors.
// Copyright 2025 Traintime PDA Authors
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:provider/provider.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:watermeter/page/class_attendance/class_attandance_card.dart';
import 'package:watermeter/page/class_attendance/class_attendance_state.dart';
import 'package:watermeter/page/class_attendance/class_attendance_table.dart';
import 'package:watermeter/page/public_widget/empty_list_view.dart';
import 'package:watermeter/page/public_widget/public_widget.dart';
import 'package:watermeter/page/public_widget/timeline_widget/timeline_title.dart';
import 'package:watermeter/page/public_widget/timeline_widget/timeline_widget.dart';

class ClassAttendanceView extends StatelessWidget {
  const ClassAttendanceView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ClassAttendanceState(),
      child: Consumer<ClassAttendanceState>(
        builder: (context, state, _) {
          final bool useTableView = MediaQuery.of(context).size.width > 800;

          return Scaffold(
            appBar: AppBar(
              title: Text(
                FlutterI18n.translate(context, "class_attendance.title"),
              ),
              actions: [
                if (state.state == ClassAttendanceFetchState.ok ||
                    state.state == ClassAttendanceFetchState.empty)
                  IconButton(
                    icon: const Icon(Icons.replay_outlined),
                    onPressed: () => state.refreshData(),
                  ),
              ],
            ),
            body: Builder(
              builder: (context) {
                switch (state.state) {
                  case ClassAttendanceFetchState.fetching:
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CircularProgressIndicator(),
                          const SizedBox(height: 16),
                          Text(
                            FlutterI18n.translate(
                              context,
                              "class_attendance.long_load",
                            ),
                          ),
                        ],
                      ),
                    );
                  case ClassAttendanceFetchState.error:
                    return ReloadWidget(
                      function: () => state.refreshData(),
                      errorStatus: state.error,
                      stackTrace: state.stackTrace,
                    );
                  case ClassAttendanceFetchState.empty:
                    return EmptyListView(
                      text: FlutterI18n.translate(
                        context,
                        "class_attendance.no_data",
                      ),
                      type: EmptyListViewType.rolling,
                    );
                  case ClassAttendanceFetchState.ok:
                    if (useTableView) {
                      return ClassAttendanceTable(
                        courses: state.courses,
                        classTimes: state.classTimes,
                        onRefresh: state.refreshData,
                      );
                    }
                    return _buildCardView(context, state);
                }
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildCardView(BuildContext context, ClassAttendanceState state) {
    final courseCards = state.courses.map((classAttendance) {
      int times = state.classTimes[classAttendance.courseName] ?? 0;
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

    return RefreshIndicator(
      onRefresh: state.refreshData,
      child: TimelineWidget(
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
      ),
    );
  }
}
