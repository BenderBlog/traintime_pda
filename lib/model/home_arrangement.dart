// Copyright 2024 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'package:json_annotation/json_annotation.dart';

part 'home_arrangement.g.dart';

/// This is for the main page applet.
@JsonSerializable(explicitToJson: true)
class HomeArrangement {
  String name;
  String teacher;
  String place;
  @JsonKey(name: 'start_time')
  String startTime;
  @JsonKey(name: 'end_time')
  String endTime;

  @override
  int get hashCode => "$name $teacher $place $startTime $endTime".hashCode;

  int get startTimeByMinutesOfDay {
    var data = RegExp(
      r'^(?<hour>\d+):(?<minute>\d+)',
    ).allMatches(startTime).toList();
    return int.parse(data[0].namedGroup('hour')!) * 60 +
        int.parse(data[0].namedGroup('minute')!);
  }

  @override
  bool operator ==(Object other) =>
      other is HomeArrangement &&
      other.name == name &&
      other.teacher == teacher &&
      other.place == place &&
      other.startTime == startTime &&
      other.endTime == endTime;

  HomeArrangement({
    required this.name,
    String? teacher,
    String? place,
    required this.startTime,
    required this.endTime,
  })  : teacher = teacher ?? "未安排老师",
        place = place ?? "未找到地点";

  factory HomeArrangement.fromJson(Map<String, dynamic> json) =>
      _$HomeArrangementFromJson(json);

  Map<String, dynamic> toJson() => _$HomeArrangementToJson(this);
}
