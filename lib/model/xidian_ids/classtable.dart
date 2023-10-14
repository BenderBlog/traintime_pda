// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'package:json_annotation/json_annotation.dart';

part 'classtable.g.dart';

@JsonSerializable(explicitToJson: true)
class ClassDetail {
  String name; // 名称
  String? teacher; // 老师
  String? code; // 课程序号
  String? number; // 班级序号

  ClassDetail({
    required this.name,
    this.teacher,
    this.code,
    this.number,
  });

  ClassDetail.from(ClassDetail e)
      : this(
          name: e.name,
          teacher: e.teacher,
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
}

@JsonSerializable(explicitToJson: true)
class TimeArrangement {
  int index; // 课程索引
  // 返回的是 0 和 1 组成的数组，0 代表这周没课程，1 代表这周有课
  @JsonKey(name: 'week_list')
  String weekList; // 上课周次
  int day; // 星期几上课
  int start; // 上课开始
  int stop; // 上课结束
  @JsonKey(includeIfNull: false)
  String? classroom; // 上课教室

  int get step => stop - start; // 上课长度

  factory TimeArrangement.fromJson(Map<String, dynamic> json) =>
      _$TimeArrangementFromJson(json);

  Map<String, dynamic> toJson() => _$TimeArrangementToJson(this);

  TimeArrangement({
    required this.index,
    required this.weekList,
    this.classroom,
    required this.day,
    required this.start,
    required this.stop,
  });
}

@JsonSerializable(explicitToJson: true)
class ClassTableData {
  int semesterLength;
  String semesterCode;
  String termStartDay;
  List<ClassDetail> classDetail;
  List<ClassDetail> notArranged;
  List<TimeArrangement> timeArrangement;
  List<ClassChange> classChanges;

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
    List<ClassDetail>? notArranged,
    List<TimeArrangement>? timeArrangement,
    List<ClassChange>? classChanges,
  })  : classDetail = classDetail ?? [],
        notArranged = notArranged ?? [],
        timeArrangement = timeArrangement ?? [],
        classChanges = classChanges ?? [];

  factory ClassTableData.fromJson(Map<String, dynamic> json) =>
      _$ClassTableDataFromJson(json);

  Map<String, dynamic> toJson() => _$ClassTableDataToJson(this);
}

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

  /// 来自 SKZC 原周次信息
  final String originalAffectedWeeks;

  /// 来自 XSKZC 新周次信息，可能是空
  final String? newAffectedWeeks;

  /// YSKJS 原先的老师
  final String? originalTeacher;

  /// XSKJS 新换的老师
  final String? newTeacher;

  /// KSJS-JSJC 原先的课次信息
  final List<int> originalClassRange;

  /// XKSJS-XJSJC 新的课次信息
  final List<int> newClassRange;

  /// SKXQ 原先的星期
  final int originalWeek;

  /// XSKXQ 现在的星期
  final int? newWeek;

  ClassChange({
    required this.type,
    required this.classCode,
    required this.classNumber,
    required this.className,
    required this.originalAffectedWeeks,
    required this.newAffectedWeeks,
    required this.originalTeacher,
    required this.newTeacher,
    required this.originalClassRange,
    required this.newClassRange,
    required this.originalWeek,
    required this.newWeek,
  });

  List<int> get originalAffectedWeeksList {
    List<int> toReturn = [];
    for (int i = 0; i < originalAffectedWeeks.length; ++i) {
      if (originalAffectedWeeks[i] == '1') toReturn.add(i);
    }
    return toReturn;
  }

  List<int> get newAffectedWeeksList {
    List<int> toReturn = [];
    for (int i = 0; i < (newAffectedWeeks?.length ?? 0); ++i) {
      if (newAffectedWeeks![i] == '1') toReturn.add(i);
    }
    return toReturn;
  }

  factory ClassChange.fromJson(Map<String, dynamic> json) =>
      _$ClassChangeFromJson(json);

  Map<String, dynamic> toJson() => _$ClassChangeToJson(this);
}

// Time arrangements.
// Even means start, odd means end.
List<String> time = [
  "8:30",
  "9:15",
  "9:20",
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
];
