// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'package:json_annotation/json_annotation.dart';

part 'home_arrangement.g.dart';

/// This is for the main page applet.
/// [startTime] and [endTime] must be stored with the following format
// 'yyyy-MM-dd HH:mm:ss'
@JsonSerializable(explicitToJson: true)
class HomeArrangement {
  static const format = 'yyyy-MM-dd HH:mm:ss';

  String name;
  String? teacher;
  String? place;
  String? seat;

  @JsonKey(name: 'start_time')
  String startTimeStr;
  @JsonKey(name: 'end_time')
  String endTimeStr;

  @override
  int get hashCode =>
      "$name $teacher $place $seat $startTimeStr $endTimeStr".hashCode;

  DateTime get startTime => DateTime.parse(startTimeStr);
  DateTime get endTime => DateTime.parse(endTimeStr);

  @override
  bool operator ==(Object other) =>
      other is HomeArrangement &&
      other.name == name &&
      other.teacher == teacher &&
      other.place == place &&
      other.seat == seat &&
      other.startTime == startTime &&
      other.endTime == endTime;

  HomeArrangement({
    required this.name,
    required this.startTimeStr,
    required this.endTimeStr,
    this.teacher,
    this.place,
    this.seat,
  });

  factory HomeArrangement.fromJson(Map<String, dynamic> json) =>
      _$HomeArrangementFromJson(json);

  Map<String, dynamic> toJson() => _$HomeArrangementToJson(this);
}
