// Copyright 2026 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0 OR Apache-2.0

import 'package:material_ui/material_ui.dart';

enum ArrangementDetailType {
  course,
  exam,
  physicsExperiment,
  otherExperiment,
  customCourse,
}

enum CustomCourseActionType { edit, deleteOne, deleteAll }

class ArrangementDetailItem {
  final ArrangementDetailType type;
  final String name;
  final String? teacher;
  final String? classroom;
  final MaterialColor color;
  final List<bool>? weekList;
  final int? weekday;
  final int? startPeriod;
  final int? stopPeriod;
  final String? code;
  final String? number;
  final String? seat;
  final List<DateTimeRange> dateRanges;
  final DateTimeRange? selectedDateRange;
  final String? customClassId;
  final String? customTimeRangeId;

  const ArrangementDetailItem({
    required this.type,
    required this.name,
    required this.color,
    this.teacher,
    this.classroom,
    this.weekList,
    this.weekday,
    this.startPeriod,
    this.stopPeriod,
    this.code,
    this.number,
    this.seat,
    this.dateRanges = const [],
    this.selectedDateRange,
    this.customClassId,
    this.customTimeRangeId,
  });
}

class ArrangementDetailData {
  final List<ArrangementDetailItem> arrangements;
  final int semesterWeekCount;
  final List<DateTime> weekStartDates;
  final int currentWeek;

  const ArrangementDetailData({
    required this.arrangements,
    required this.semesterWeekCount,
    required this.weekStartDates,
    required this.currentWeek,
  });
}

class ArrangementDetailAction {
  final String customClassId;
  final String? customTimeRangeId;
  final CustomCourseActionType type;

  const ArrangementDetailAction({
    required this.customClassId,
    required this.type,
    this.customTimeRangeId,
  });
}
