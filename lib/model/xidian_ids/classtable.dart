/*
The class table model.
Copyright 2022 SuperBart

This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at https://mozilla.org/MPL/2.0/.

Please refer to ADDITIONAL TERMS APPLIED TO WATERMETER SOURCE CODE
if you want to use.
*/

import 'package:json_annotation/json_annotation.dart';

part 'classtable.g.dart';

/// This is for the main page applet.
@JsonSerializable(explicitToJson: true)
class ClassToShow {
  String name;
  String teacher;
  String place;
  @JsonKey(name: 'start_time')
  int startTime;
  @JsonKey(name: 'end_time')
  int endTime;

  @override
  int get hashCode => "$name $teacher $place $startTime $endTime".hashCode;

  @override
  bool operator ==(Object other) =>
      other is ClassToShow &&
      other.name == name &&
      other.teacher == teacher &&
      other.place == place &&
      other.startTime == startTime &&
      other.endTime == endTime;

  ClassToShow({
    required this.name,
    String? teacher,
    String? place,
    required this.startTime,
    required this.endTime,
  })  : teacher = teacher ?? "未安排老师",
        place = place ?? "未找到地点";

  factory ClassToShow.fromJson(Map<String, dynamic> json) =>
      _$ClassToShowFromJson(json);

  Map<String, dynamic> toJson() => _$ClassToShowToJson(this);
}

@JsonSerializable()
class ClassToShowList {
  Set<ClassToShow> list = {};

  ClassToShowList();

  factory ClassToShowList.fromJson(Map<String, dynamic> json) =>
      _$ClassToShowListFromJson(json);

  Map<String, dynamic> toJson() => _$ClassToShowListToJson(this);
}

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

  ClassTableData({
    this.semesterLength = 1,
    this.semesterCode = "",
    this.termStartDay = "",
    List<ClassDetail>? classDetail,
    List<ClassDetail>? notArranged,
    List<TimeArrangement>? timeArrangement,
  })  : classDetail = classDetail ?? [],
        notArranged = notArranged ?? [],
        timeArrangement = timeArrangement ?? [];

  factory ClassTableData.fromJson(Map<String, dynamic> json) =>
      _$ClassTableDataFromJson(json);

  Map<String, dynamic> toJson() => _$ClassTableDataToJson(this);
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
  "20:30",
];
