// Copyright 2025 Traintime PDA Authours, originally by BenderBlog Rodriguez.
// SPDX-License-Identifier: MPL-2.0
import 'package:flutter/material.dart';
import 'package:watermeter/model/xidian_ids/class_attendance.dart';
import 'package:watermeter/page/public_widget/re_x_card.dart';

class CourseCard extends StatelessWidget {
  final ClassAttendance course;

  const CourseCard({super.key, required this.course});

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
      remaining: [ReXCardRemaining(course.isOkToFinalExam)],
      bottomRow: Column(
        children: [
          _buildInfoRow(
            '签到次数',
            "${course.checkInCount} 已签 / ${course.absenceCount} 旷课 / ${course.requiredCheckIn} 应签",
          ),
          _buildInfoRow(
            "请假次数",
            "事假 ${course.personalLeave}；病假 ${course.sickLeave}；公假 ${course.officialLeave}",
          ),
          _buildInfoRow(
            "学习进度",
            "任务点 ${course.taskProgress}；作业 ${course.homeworkProgress}；考试 ${course.examProgress}",
          ),
        ],
      ),
    );
  }
}
