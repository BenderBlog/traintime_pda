// Copyright 2025 BenderBlog Rodriguez and contributors.
// Copyright 2025 Traintime PDA Authors
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:watermeter/model/xidian_ids/class_attendance.dart';
import 'package:watermeter/page/class_attendance/class_attandance_card.dart';
import 'package:watermeter/page/class_attendance/class_attendance_state.dart';
import 'package:watermeter/page/class_attendance/class_attendance_table.dart';
import 'package:watermeter/page/public_widget/empty_list_view.dart';
import 'package:watermeter/page/public_widget/public_widget.dart';
import 'package:watermeter/page/public_widget/timeline_widget/timeline_title.dart';
import 'package:watermeter/page/public_widget/timeline_widget/timeline_widget.dart';
import 'package:watermeter/generated/l10n.dart';

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
                I18n.of(context)!.classAttendanceTitle,
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
                            I18n.of(context)!.classAttendanceLongLoad,
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
                      text: I18n.of(context)!.classAttendanceNoData,
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
      int? times = state.classTimes[classAttendance.courseName];
      if (times == null) {
        String suspeciousClassName = state.classTimes.keys.firstWhere(
          (str) =>
              str.contains(classAttendance.courseName) ||
              classAttendance.courseName.contains(str),
          orElse: () => "",
        );
        if (suspeciousClassName.isNotEmpty) {
          times = state.classTimes[suspeciousClassName];
        }
      }
      return CourseCard(course: classAttendance, totalTimes: times);
    }).toList();

    final warningCourses = courseCards.toList()
      ..retainWhere(
        (e) => e.course.attendanceStatus == AttendanceStatus.warning,
      );
    final ineligibleCourses = courseCards.toList()
      ..retainWhere(
        (e) => e.course.attendanceStatus == AttendanceStatus.ineligible,
      );
    final eligibleCourses = courseCards.toList()
      ..retainWhere(
        (e) => e.course.attendanceStatus == AttendanceStatus.eligible,
      );
    final unknownCourses = courseCards.toList()
      ..retainWhere(
        (e) => e.course.attendanceStatus == AttendanceStatus.unknown,
      );

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
              title: I18n.of(context)!.classAttendanceCourseStateIneligible,
            ),
            ineligibleCourses.toColumn(),
          ],
          if (warningCourses.isNotEmpty) ...[
            TimelineTitle(
              title: I18n.of(context)!.classAttendanceCourseStateWarning,
            ),
            warningCourses.toColumn(),
          ],
          if (eligibleCourses.isNotEmpty) ...[
            TimelineTitle(
              title: I18n.of(context)!.classAttendanceCourseStateEligible,
            ),
            eligibleCourses.toColumn(),
          ],
          if (unknownCourses.isNotEmpty) ...[
            TimelineTitle(
              title: I18n.of(context)!.classAttendanceCourseStateUnknown,
            ),
            unknownCourses.toColumn(),
          ],
        ],
      ),
    );
  }
}
