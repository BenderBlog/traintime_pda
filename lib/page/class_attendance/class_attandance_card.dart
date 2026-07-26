// Copyright 2025 Traintime PDA Authours, originally by BenderBlog Rodriguez.
// SPDX-License-Identifier: MPL-2.0
import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:watermeter/model/xidian_ids/class_attendance.dart';
import 'package:watermeter/page/class_attendance/class_attendance_detail.dart';
import 'package:watermeter/page/public_widget/both_side_sheet.dart';
import 'package:watermeter/page/public_widget/re_x_card.dart';
import 'package:watermeter/generated/l10n.dart';
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
      remaining: [ReXCardRemaining(attendanceStatusName(context, course.attendanceStatus))],
      bottomRow: Column(
        children: [
          _buildInfoRow(
            I18n.of(context)!.classAttendanceCardTime,
            I18n.of(context)!.classAttendanceCardTimeInfo(
              course.checkInCount,
              course.absenceCount,
              course.requiredCheckIn,
            ),
          ),
          _buildInfoRow(
            I18n.of(context)!.classAttendanceCardNotAttend,
            (totalTimes == null)
                ? I18n.of(context)!.classAttendanceCardNotAttendInfoError
                : I18n.of(context)!.classAttendanceCardNotAttendInfo(
                    ((totalTimes! / 4).floor() -
                            (int.tryParse(course.absenceCount) ?? 0))
                        .toString(),
                    totalTimes.toString(),
                  ),
          ),
          _buildInfoRow(
            I18n.of(context)!.classAttendanceCardLeave,
            I18n.of(context)!.classAttendanceCardLeaveInfo(
              course.personalLeave,
              course.sickLeave,
              course.officialLeave,
            ),
          ),
          _buildInfoRow(
            I18n.of(context)!.classAttendanceCardStudy,
            I18n.of(context)!.classAttendanceCardStudyInfo(
              course.taskProgress,
              course.homeworkProgress,
              course.examProgress,
            ),
          ),
        ],
      ),
    ).gestures(
      onTap: () async {
        if (course.attendanceStatus != AttendanceStatus.unknown) {
          await BothSideSheet.show(
            context: context,
            title: I18n.of(
              context,
            )!.classAttendanceDetailTitle(course.courseName),
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
