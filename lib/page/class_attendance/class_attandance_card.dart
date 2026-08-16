// Copyright 2025 Traintime PDA Authours, originally by BenderBlog Rodriguez.
// SPDX-License-Identifier: MPL-2.0
import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:watermeter/model/xidian_ids/class_attendance.dart';
import 'package:watermeter/page/class_attendance/class_attendance_detail.dart';
import 'package:watermeter/page/public_widget/both_side_sheet.dart';
import 'package:watermeter/page/public_widget/re_x_card.dart';
import 'package:watermeter/generated/translations.g.dart';
import './class_attendance_table.dart' show attendanceStatusName;

class CourseCard extends StatelessWidget {
  final ClassAttendance course;
  final int? totalTimes;

  const CourseCard({super.key, required this.course, required this.totalTimes});

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 16),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ReXCard(
      title: Text(course.courseName),
      remaining: [
        ReXCardRemaining(
          attendanceStatusName(context, course.attendanceStatus),
        ),
      ],
      bottomRow: Column(
        children: [
          _buildInfoRow(
            context.t.classAttendance.card.time,
            context.t.classAttendance.card.timeInfo(
              check_in_count: course.checkInCount,
              absence_count: course.absenceCount,
              required_check_in: course.requiredCheckIn,
            ),
          ),
          _buildInfoRow(
            context.t.classAttendance.card.notAttend,
            (totalTimes == null)
                ? context.t.classAttendance.card.notAttendInfoError
                : context.t.classAttendance.card.notAttendInfo(
                    time_to_have_error:
                        ((totalTimes! / 4).floor() -
                                (int.tryParse(course.absenceCount) ?? 0))
                            .toString(),
                    total_times: totalTimes.toString(),
                  ),
          ),
          _buildInfoRow(
            context.t.classAttendance.card.leave,
            context.t.classAttendance.card.leaveInfo(
              personal_leave: course.personalLeave,
              sick_leave: course.sickLeave,
              official_leave: course.officialLeave,
            ),
          ),
          _buildInfoRow(
            context.t.classAttendance.card.study,
            context.t.classAttendance.card.studyInfo(
              task_progress: course.taskProgress,
              homework_progress: course.homeworkProgress,
              exam_progress: course.examProgress,
            ),
          ),
        ],
      ),
    ).gestures(
      onTap: () async {
        if (course.attendanceStatus != AttendanceStatus.unknown) {
          await BothSideSheet.show(
            context: context,
            title: context.t.classAttendance.detailTitle(course_name: course.courseName),
            child: ClassAttendanceDetailView(
              classAttendance: course,
              showAppBar: false,
            ),
          );
        }
      },
    );
  }
}
