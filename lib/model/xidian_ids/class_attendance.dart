// Copyright 2025 BenderBlog Rodriguez and contributors.
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'package:json_annotation/json_annotation.dart';
part 'class_attendance.g.dart';

class ClassAttendance {
  // 课程信息
  final String courseName; // 课程名称 (课程 名称)
  final String className; // 教学班名称 (教学班 名称)

  // 考勤数据
  final String checkInCount; // 签到 次数
  final String personalLeave; // 事假 次数
  final String sickLeave; // 病假 次数
  final String officialLeave; // 公假 次数
  final String absenceCount; // 旷课 次数
  final String requiredCheckIn; // 应签 次数
  final String attendanceRate; // 到课 率

  // 学习进度/活动
  final String readCount; // 已读 次数
  final String unreadCount; // 未读 次数
  final String accessCount; // 访问 次数
  final String taskProgress; // 任务点 进度 (e.g., "0/4")
  final String homeworkProgress; // 作业 进度 (e.g., "0/0")
  final String examProgress; // 考试 进度 (e.g., "0/1")
  final String discussionCount; // 讨论
  final String materialCount; // 资料

  // 采自课程信息网页
  final String? courseId;
  final String? clazzId;
  final String? cpi;

  const ClassAttendance({
    required this.courseName,
    required this.className,
    required this.checkInCount,
    required this.personalLeave,
    required this.sickLeave,
    required this.officialLeave,
    required this.absenceCount,
    required this.requiredCheckIn,
    required this.attendanceRate,
    required this.readCount,
    required this.unreadCount,
    required this.accessCount,
    required this.taskProgress,
    required this.homeworkProgress,
    required this.examProgress,
    required this.discussionCount,
    required this.materialCount,
    this.courseId,
    this.clazzId,
    this.cpi,
  });

  String get isOkToFinalExam {
    double? attandanceRatio = double.tryParse(
      attendanceRate.replaceAll(" %", ""),
    );

    if (attandanceRatio == null) {
      return "信息不够";
    } else if (attandanceRatio < 75.0) {
      return "取消期末考试资格";
    } else if (attandanceRatio < 90.0) {
      return "有取消危险";
    } else {
      return "暂时安全";
    }
  }
}

@JsonSerializable(explicitToJson: true)
class ClassAttendanceDetail {
  final String? submittime;
  final String createxxuid;
  final int? userStatus;
  final String creatorName;
  final int activeid;
  final String starttime;
  final int? attendid;
  final int activeType;
  final String name;
  @JsonKey(name: "other_id")
  final int otherId;
  final int updatetime;
  final String createUid;
  final int status;

  ClassAttendanceDetail({
    required this.submittime,
    required this.createxxuid,
    required this.userStatus,
    required this.creatorName,
    required this.activeid,
    required this.starttime,
    required this.attendid,
    required this.activeType,
    required this.name,
    required this.otherId,
    required this.updatetime,
    required this.createUid,
    required this.status,
  });

  factory ClassAttendanceDetail.fromJson(Map<String, dynamic> json) =>
      _$ClassAttendanceDetailFromJson(json);

  Map<String, dynamic> toJson() => _$ClassAttendanceDetailToJson(this);
}
