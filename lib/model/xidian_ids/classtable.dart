// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0 OR Apache-2.0

import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'classtable.g.dart';

enum Source {
  empty,
  school,
  user,
}

@JsonSerializable(explicitToJson: true)
class NotArrangementClassDetail {
  String name; // 名称
  String? code; // 课程序号
  String? number; // 班级序号
  String? teacher; // 老师

  NotArrangementClassDetail({
    required this.name,
    this.code,
    this.number,
    this.teacher,
  });

  factory NotArrangementClassDetail.from(NotArrangementClassDetail e) =>
      NotArrangementClassDetail(
        name: e.name,
        code: e.code,
        number: e.number,
        teacher: e.teacher,
      );

  factory NotArrangementClassDetail.fromJson(Map<String, dynamic> json) =>
      _$NotArrangementClassDetailFromJson(json);

  Map<String, dynamic> toJson() => _$NotArrangementClassDetailToJson(this);

  @override
  int get hashCode => name.hashCode;

  @override
  bool operator ==(Object other) =>
      other is ClassDetail &&
      other.runtimeType == runtimeType &&
      name == other.name;
}

@JsonSerializable(explicitToJson: true)
class ClassDetail {
  String name; // 名称
  String? code; // 课程序号
  String? number; // 班级序号

  ClassDetail({
    required this.name,
    this.code,
    this.number,
  });

  factory ClassDetail.from(ClassDetail e) => ClassDetail(
        name: e.name,
        code: e.code,
        number: e.number,
      );

  factory ClassDetail.fromJson(Map<String, dynamic> json) =>
      _$ClassDetailFromJson(json);

  Map<String, dynamic> toJson() => _$ClassDetailToJson(this);

  @override
  int get hashCode => name.hashCode;

  @override
  bool operator ==(Object other) =>
      other is ClassDetail &&
      other.runtimeType == runtimeType &&
      name == other.name;

  @override
  String toString() {
    return "$name $code $number";
  }
}

@JsonSerializable(explicitToJson: true)
class TimeArrangement {
  /// 课程索引（注：是 `ClassDetail` 的索引，不是 `TimeArrangement` 的索引）
  int index;

  /// 返回的是布尔类型列表，true 表示该周有课，false 表示该周无课
  /// 绕过 Swift 字符串不好处理的代价就是 json 要大很多了......
  @JsonKey(name: 'week_list')
  List<bool> weekList; // 上课周次
  String? teacher; // 老师
  int day; // 星期几上课
  int start; // 上课开始
  int stop; // 上课结束
  Source source; // 数据来源
  @JsonKey(includeIfNull: false)
  String? classroom; // 上课教室

  int get step => stop - start; // 上课长度

  factory TimeArrangement.fromJson(Map<String, dynamic> json) =>
      _$TimeArrangementFromJson(json);

  Map<String, dynamic> toJson() => _$TimeArrangementToJson(this);

  TimeArrangement({
    required this.source,
    required this.index,
    required this.weekList,
    this.classroom,
    this.teacher,
    required this.day,
    required this.start,
    required this.stop,
  });

  @override
  String toString() => "$source $index $classroom $teacher";
}

@JsonSerializable(explicitToJson: true)
class ClassTableData {
  int semesterLength;
  String semesterCode;
  String termStartDay;
  List<ClassDetail> classDetail;
  List<ClassDetail> userDefinedDetail;
  List<NotArrangementClassDetail> notArranged;
  List<TimeArrangement> timeArrangement;
  List<ClassChange> classChanges;

  /// Only allowed to be used with classDetail
  ClassDetail getClassDetail(TimeArrangement t) {
    switch (t.source) {
      case Source.school:
        return classDetail[t.index];
      case Source.user:
        return userDefinedDetail[t.index];
      case Source.empty:
        throw NotImplementedException();
    }
  }

  ClassTableData.from(ClassTableData c)
      : this(
          semesterLength: c.semesterLength,
          semesterCode: c.semesterCode,
          termStartDay: c.termStartDay,
          classDetail: c.classDetail,
          notArranged: c.notArranged,
          timeArrangement: c.timeArrangement,
          classChanges: c.classChanges,
        );

  ClassTableData({
    this.semesterLength = 1,
    this.semesterCode = "",
    this.termStartDay = "",
    List<ClassDetail>? classDetail,
    List<ClassDetail>? userDefinedDetail,
    List<NotArrangementClassDetail>? notArranged,
    List<TimeArrangement>? timeArrangement,
    List<ClassChange>? classChanges,
  })  : classDetail = classDetail ?? [],
        userDefinedDetail = userDefinedDetail ?? [],
        notArranged = notArranged ?? [],
        timeArrangement = timeArrangement ?? [],
        classChanges = classChanges ?? [];

  factory ClassTableData.fromJson(Map<String, dynamic> json) =>
      _$ClassTableDataFromJson(json);

  Map<String, dynamic> toJson() => _$ClassTableDataToJson(this);
}

class NotImplementedException implements Exception {}

enum ChangeType {
  change, // 调课
  stop, // 停课
  patch, // 补课
}

@JsonSerializable(explicitToJson: true)
class ClassChange {
  final ChangeType type;

  /// KCH 课程号
  final String classCode;

  /// KXH 班级号
  final String classNumber;

  /// KCM 课程名
  final String className;

  /// 来自 SKZC 原周次信息，可能是空
  final List<bool>? originalAffectedWeeks;

  /// 来自 XSKZC 新周次信息，可能是空
  final List<bool>? newAffectedWeeks;

  /// YSKJS 原先的老师
  final String? originalTeacherData;

  /// XSKJS 新换的老师
  final String? newTeacherData;

  /// KSJS-JSJC 原先的课次信息
  final List<int> originalClassRange;

  /// XKSJS-XJSJC 新的课次信息
  final List<int> newClassRange;

  /// SKXQ 原先的星期
  final int? originalWeek;

  /// XSKXQ 现在的星期
  final int? newWeek;

  /// JASMC 旧教室
  final String? originalClassroom;

  /// XJASMC 新教室
  final String? newClassroom;

  ClassChange({
    required this.type,
    required this.classCode,
    required this.classNumber,
    required this.className,
    required this.originalAffectedWeeks,
    required this.newAffectedWeeks,
    required this.originalTeacherData,
    required this.newTeacherData,
    required this.originalClassRange,
    required this.newClassRange,
    required this.originalWeek,
    required this.newWeek,
    required this.originalClassroom,
    required this.newClassroom,
  });

  /// 必须假设后台有问题，返回长度不一样的数组
  /// 亏他们想得出来用 01 表示布尔信息，日子不是这么省的啊
  List<int> get originalAffectedWeeksList {
    if (originalAffectedWeeks == null) return [];
    List<int> toReturn = [];
    for (int i = 0; i < originalAffectedWeeks!.length; ++i) {
      if (originalAffectedWeeks![i]) toReturn.add(i);
    }
    return toReturn;
  }

  List<int> get newAffectedWeeksList {
    List<int> toReturn = [];
    for (int i = 0; i < (newAffectedWeeks?.length ?? 0); ++i) {
      if (newAffectedWeeks![i]) toReturn.add(i);
    }
    return toReturn;
  }

  String? get originalTeacher =>
      originalTeacherData?.replaceAll(RegExp(r'(/|[0-9a-zA-z])'), '');

  String? get newTeacher =>
      newTeacherData?.replaceAll(RegExp(r'(/|[0-9a-zA-z])'), '');

  String? get originalNewTeacher => newTeacherData;

  bool get isTeacherChanged {
    List<String> originalTeacherCode =
        originalTeacherData?.replaceAll(' ', '').split(RegExp(r',|/')) ?? [];

    originalTeacherCode
        .retainWhere((element) => element.contains(RegExp(r'([0-9])')));

    List<String> newTeacherCode =
        newTeacherData?.replaceAll(' ', '').split(RegExp(r',|/')) ?? [];

    newTeacherCode
        .retainWhere((element) => element.contains(RegExp(r'([0-9])')));

    return !listEquals(originalTeacherCode, newTeacherCode);
  }

  String get changeTypeString {
    switch (type) {
      case ChangeType.change:
        return "调课";
      case ChangeType.patch:
        return "补课";
      case ChangeType.stop:
        return "停课";
    }
  }

  factory ClassChange.fromJson(Map<String, dynamic> json) =>
      _$ClassChangeFromJson(json);

  Map<String, dynamic> toJson() => _$ClassChangeToJson(this);
}

@JsonSerializable(explicitToJson: true)
class UserDefinedClassData {
  List<ClassDetail> userDefinedDetail;
  List<TimeArrangement> timeArrangement;

  UserDefinedClassData({
    required this.userDefinedDetail,
    required this.timeArrangement,
  });

  factory UserDefinedClassData.fromJson(Map<String, dynamic> json) =>
      _$UserDefinedClassDataFromJson(json);

  factory UserDefinedClassData.empty() =>
      UserDefinedClassData(userDefinedDetail: [], timeArrangement: []);

  Map<String, dynamic> toJson() => _$UserDefinedClassDataToJson(this);
}

// Time arrangements.
// Even means start, odd means end.
List<String> time = [
  "08:30",
  "09:15",
  "09:20",
  "10:05",
  "10:25",
  "11:10",
  "11:15",
  "12:00",
  "14:00",
  "14:45",
  "14:50",
  "15:35",
  "15:55",
  "16:40",
  "16:45",
  "17:30",
  "19:00",
  "19:45",
  "19:55",
  "20:35",
  "20:40",
  "21:25",
];
