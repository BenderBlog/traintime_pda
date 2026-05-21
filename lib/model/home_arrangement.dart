// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

/// This is for the classtable applet.
/// [startTime] and [endTime] must be stored with the following format
// 'yyyy-MM-dd HH:mm:ss'
class HomeArrangement implements Comparable<HomeArrangement> {
  static const format = 'yyyy-MM-dd HH:mm:ss';

  String name;
  String? teacher;
  String? place;
  String? seat;

  int? colorIndex;

  String startTimeStr;
  String endTimeStr;

  DateTime get startTime => DateTime.parse(startTimeStr);
  DateTime get endTime => DateTime.parse(endTimeStr);

  HomeArrangement({
    required this.name,
    required this.startTimeStr,
    required this.endTimeStr,
    this.teacher,
    this.place,
    this.seat,
    this.colorIndex,
  });

  @override
  int get hashCode =>
      "$name $teacher $place $seat $startTimeStr $endTimeStr".hashCode;

  @override
  bool operator ==(Object other) =>
      other is HomeArrangement &&
      other.name == name &&
      other.teacher == teacher &&
      other.place == place &&
      other.seat == seat &&
      other.startTime == startTime &&
      other.endTime == endTime;

  @override
  int compareTo(HomeArrangement other) {
    return startTime.compareTo(other.startTime);
  }
}
