// Copyright 2026 Hazuki Keatsu.
// SPDX-License-Identifier: MPL-2.0

import 'package:json_annotation/json_annotation.dart';

part 'custom_class.g.dart';

/// 自定义课程的数据类
@JsonSerializable(explicitToJson: true)
class CustomClassTimeRange {
  final String id;
  @JsonKey(name: 'start_time')
  final DateTime startTime;
  @JsonKey(name: 'end_time')
  final DateTime endTime;

  static const int _earliestInMinutes = 8 * 60 + 30;
  static const int _latestInMinutes = 21 * 60 + 25;

  CustomClassTimeRange({
    required this.id,
    required this.startTime,
    required this.endTime,
  }) {
    // 这里从数据模型层面封堵了非法时间的可能性，虽然说在UI层面也有封堵。。
    if (!isWithinAllowedTime(startTime) || !isWithinAllowedTime(endTime)) {
      throw ArgumentError('Class time must be in 08:30-21:25.');
    }
    if (!isSameDay(startTime, endTime)) {
      throw ArgumentError('Start and end time must be on the same day.');
    }
    if (!startTime.isBefore(endTime)) {
      throw ArgumentError('Start time must be earlier than end time.');
    }
  }

  static bool isWithinAllowedTime(DateTime dateTime) {
    final int minutes = dateTime.hour * 60 + dateTime.minute;
    return minutes >= _earliestInMinutes && minutes <= _latestInMinutes;
  }

  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  factory CustomClassTimeRange.fromJson(Map<String, dynamic> json) =>
      _$CustomClassTimeRangeFromJson(json);

  Map<String, dynamic> toJson() => _$CustomClassTimeRangeToJson(this);
}

@JsonSerializable(explicitToJson: true)
class CustomClass {
  final String id;
  final String name;
  final String? teacher;
  final String? classroom;
  @JsonKey(name: 'time_ranges')
  final List<CustomClassTimeRange> timeRanges;

  CustomClass({
    required this.id,
    required this.name,
    this.teacher,
    this.classroom,
    required List<CustomClassTimeRange> timeRanges,
  }) : timeRanges = List<CustomClassTimeRange>.from(timeRanges) {
    if (name.trim().isEmpty) {
      throw ArgumentError('Class name is required.');
    }
    if (this.timeRanges.isEmpty) {
      throw ArgumentError('At least one time range is required.');
    }
  }

  factory CustomClass.fromJson(Map<String, dynamic> json) =>
      _$CustomClassFromJson(json);

  Map<String, dynamic> toJson() => _$CustomClassToJson(this);
}
