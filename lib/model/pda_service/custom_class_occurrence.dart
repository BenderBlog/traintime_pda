// Copyright 2026 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

// Where the custom classes fall on the class table's grid.
//
// Kept as a pure query over a list instead of a controller method: the class table state answers it
// from its own snapshot, and the custom class controller answers it from its live list, without
// either of them owning the other.

import 'package:watermeter/model/pda_service/custom_class.dart';

/// A custom class together with the one time range that lands on the day asked for.
class CustomClassOccurrence {
  final CustomClass customClass;
  final CustomClassTimeRange timeRange;

  const CustomClassOccurrence({
    required this.customClass,
    required this.timeRange,
  });
}

DateTime _dateOnly(DateTime value) =>
    DateTime(value.year, value.month, value.day);

/// The occurrences of [classes] on [weekIndex]/[dayIndex], counted from [semesterStartDay].
///
/// [weekIndex] starts from 0 and [dayIndex] starts from 1, matching the class table grid.
List<CustomClassOccurrence> customClassOccurrencesForDay({
  required List<CustomClass> classes,
  required int weekIndex,
  required int dayIndex,
  required DateTime semesterStartDay,
}) {
  final List<CustomClassOccurrence> occurrences = [];
  final DateTime semesterStart = _dateOnly(semesterStartDay);

  for (final customClass in classes) {
    for (final timeRange in customClass.timeRanges) {
      final int diffDays = _dateOnly(
        timeRange.startTime,
      ).difference(semesterStart).inDays;
      if (diffDays < 0) continue;

      final int targetWeek = diffDays ~/ 7;
      final int targetDay = diffDays % 7 + 1;

      if (targetWeek == weekIndex && targetDay == dayIndex) {
        occurrences.add(
          CustomClassOccurrence(customClass: customClass, timeRange: timeRange),
        );
      }
    }
  }

  return occurrences;
}
