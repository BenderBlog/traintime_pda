// Copyright 2025 Traintime PDA Authours, originally by BenderBlog Rodriguez.
// SPDX-License-Identifier: MPL-2.0
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:watermeter/model/xidian_ids/class_attendance.dart';
import 'package:watermeter/page/class_attendance/class_attendance_detail.dart';
import 'package:watermeter/page/public_widget/both_side_sheet.dart';
import 'package:watermeter/page/public_widget/re_x_card.dart';

class CourseCard extends StatelessWidget {
  final ClassAttendance course;
  final int totalTimes;
  late final int timeToHaveError;
  late final int remainAbsenceNum;
  late final int absenceNum;
  late final String attendanceStatus;

  CourseCard({super.key, required this.course, required this.totalTimes}) {
    timeToHaveError = (totalTimes / 4).floor();
    absenceNum = int.tryParse(course.absenceCount) ?? 0;
    remainAbsenceNum = timeToHaveError - absenceNum;
    attendanceStatus = course.getAttendanceStatus(totalTimes);
  }

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
        ReXCardRemaining(FlutterI18n.translate(context, attendanceStatus)),
      ],
      bottomRow: Column(
        children: [
          _buildInfoRow(
            FlutterI18n.translate(context, "class_attendance.card.time"),
            FlutterI18n.translate(
              context,
              "class_attendance.card.time_info",
              translationParams: {
                "checkInCount": course.checkInCount,
                "absenceCount": course.absenceCount,
                "requiredCheckIn": course.requiredCheckIn,
              },
            ),
          ),
          _buildInfoRow(
            FlutterI18n.translate(context, "class_attendance.card.not_attend"),
            FlutterI18n.translate(
              context,
              "class_attendance.card.not_attend_info",
              translationParams: {
                "timeToHaveError": remainAbsenceNum.toString(),
                "totalTimes": totalTimes.toString(),
              },
            ),
          ),
          _buildInfoRow(
            FlutterI18n.translate(context, "class_attendance.card.leave"),
            FlutterI18n.translate(
              context,
              "class_attendance.card.leave_info",
              translationParams: {
                "personalLeave": course.personalLeave,
                "sickLeave": course.sickLeave,
                "officialLeave": course.officialLeave,
              },
            ),
          ),
          _buildInfoRow(
            FlutterI18n.translate(context, "class_attendance.card.study"),
            FlutterI18n.translate(
              context,
              "class_attendance.card.study_info",
              translationParams: {
                "taskProgress": course.taskProgress,
                "homeworkProgress": course.homeworkProgress,
                "examProgress": course.examProgress,
              },
            ),
          ),
        ],
      ),
    ).gestures(
      onTap: () async {
        if (!attendanceStatus.contains("unknown")) {
          await BothSideSheet.show(
            context: context,
            title: FlutterI18n.translate(
              context,
              "class_attendance.detail_title",
              translationParams: {
                "courseName": course.courseName,
              },
            ),
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
