// Copyright 2025 BenderBlog Rodriguez and contributors.
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

// ignore_for_file: constant_identifier_names

import 'package:json_annotation/json_annotation.dart';
part 'class_attendance.g.dart';

enum AttendanceStatus { unknown, eligible, warning, ineligible }

class ClassAttendance {
  // 有无预警
  final bool isWarning;

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
    this.isWarning = false,
  });

  /// Calculate the attendance status based on total class times
  /// Returns a translation key for the status
  AttendanceStatus get attendanceStatus {
    if (isWarning) return AttendanceStatus.ineligible;

    final attendanceRatio = double.tryParse(
      attendanceRate.replaceAll(" %", ""),
    );
    if (attendanceRatio == null) {
      return AttendanceStatus.unknown;
    } else if (attendanceRatio < 80.0) {
      return AttendanceStatus.warning;
    } else {
      return AttendanceStatus.eligible;
    }
  }
}

enum SignInType { qrCode, gesture, position, unknown, customName }

enum SignStatus {
  absenceNotParticipating,
  signed,
  signedByTeacher,
  personalLeave2,
  absence,
  sickLeave,
  personalLeave,
  later,
  leaveEarly,
  signExpiredy,
  publicLeave,
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
  final String? name;
  @JsonKey(name: "other_id")
  final int otherId;
  final int? updatetime;
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

  SignInType get signType {
    if (name != null) return SignInType.customName;
    return switch (otherId) {
      2 => SignInType.qrCode,
      3 => SignInType.gesture,
      4 => SignInType.position,
      _ => SignInType.unknown,
    };
  }

  SignStatus get signStatusType {
    return switch (userStatus) {
      0 => SignStatus.absenceNotParticipating,
      1 => SignStatus.signed,
      2 => SignStatus.signedByTeacher,
      4 => SignStatus.personalLeave2,
      5 => SignStatus.absence,
      7 => SignStatus.sickLeave,
      8 => SignStatus.personalLeave,
      9 => SignStatus.later,
      10 => SignStatus.leaveEarly,
      11 => SignStatus.signExpiredy,
      12 => SignStatus.publicLeave,
      _ => SignStatus.absenceNotParticipating,
    };
  }

  factory ClassAttendanceDetail.fromJson(Map<String, dynamic> json) =>
      _$ClassAttendanceDetailFromJson(json);

  Map<String, dynamic> toJson() => _$ClassAttendanceDetailToJson(this);
}
