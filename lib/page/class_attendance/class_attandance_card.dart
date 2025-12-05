// Copyright 2025 Traintime PDA Authours, originally by BenderBlog Rodriguez.
// SPDX-License-Identifier: MPL-2.0
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:watermeter/model/xidian_ids/class_attendance.dart';
import 'package:watermeter/page/class_attendance/class_attendance_detail.dart';
import 'package:watermeter/page/public_widget/context_extension.dart';
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

    double? attandanceRatio = double.tryParse(
      course.attendanceRate.replaceAll(" %", ""),
    );

    if (attandanceRatio == null) {
      attendanceStatus = "class_attendance.course_state.unknown";
    } else if (timeToHaveError < absenceNum) {
      attendanceStatus = "class_attendance.course_state.ineligible";
    } else if (attandanceRatio >= 90.0 || timeToHaveError >= absenceNum) {
      attendanceStatus = "class_attendance.course_state.eligible";
    } else {
      attendanceStatus = "class_attendance.course_state.warning";
    }
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 70,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(value, style: const TextStyle(color: Colors.black87)),
          ),
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
      onTap: () {
        if (course.cpi != null &&
            course.clazzId != null &&
            course.courseId != null) {
          context.push(ClassAttendanceDetailView(classAttendance: course));
        }
      },
    );
  }
}
