// Copyright 2026 Traintime PDA Authors.
// SPDX-License-Identifier: MPL-2.0

import 'dart:convert';

import 'package:watermeter/model/pda_service/custom_class.dart';
import 'package:watermeter/model/time_list.dart';
import 'package:watermeter/model/xidian_ids/classtable.dart';
import 'package:watermeter/model/xidian_ids/exam.dart';
import 'package:watermeter/model/xidian_ids/experiment.dart';

enum WatchScheduleEntryKind { course, exam, physicsExperiment, otherExperiment }

/// A concrete course occurrence that can be displayed directly on Apple Watch.
class WatchCourseOccurrence {
  const WatchCourseOccurrence({
    required this.id,
    required this.name,
    required this.startAt,
    required this.endAt,
    required this.startSection,
    required this.endSection,
    required this.colorARGB,
    required this.kind,
    this.teacher,
    this.classroom,
    this.note,
  });

  final String id;
  final String name;
  final DateTime startAt;
  final DateTime endAt;
  final int startSection;
  final int endSection;
  final int colorARGB;
  final WatchScheduleEntryKind kind;
  final String? teacher;
  final String? classroom;
  final String? note;

  Map<String, Object?> toJson() => {
    'id': id,
    'name': name,
    'teacher': teacher,
    'classroom': classroom,
    'startAtEpochMs': startAt.millisecondsSinceEpoch,
    'endAtEpochMs': endAt.millisecondsSinceEpoch,
    'startSection': startSection,
    'endSection': endSection,
    'colorARGB': colorARGB,
    'kind': kind.name,
    'note': note,
  };
}

/// Versioned, self-contained schedule sent from iPhone to Apple Watch.
class WatchScheduleSnapshot {
  const WatchScheduleSnapshot({
    required this.generatedAt,
    required this.semesterStart,
    required this.currentWeekIndex,
    required this.validThrough,
    required this.rangeStart,
    required this.rangeEnd,
    required this.reminderMinutes,
    required this.courses,
  });

  static const schemaVersion = 4;

  final DateTime generatedAt;
  final DateTime semesterStart;
  final int currentWeekIndex;
  final DateTime validThrough;
  final DateTime rangeStart;
  final DateTime rangeEnd;
  final int reminderMinutes;
  final List<WatchCourseOccurrence> courses;

  Map<String, Object?> toJson() => {
    'schemaVersion': schemaVersion,
    'generatedAtEpochMs': generatedAt.millisecondsSinceEpoch,
    'semesterStartEpochMs': semesterStart.millisecondsSinceEpoch,
    'currentWeekIndex': currentWeekIndex,
    'validThroughEpochMs': validThrough.millisecondsSinceEpoch,
    'rangeStartEpochMs': rangeStart.millisecondsSinceEpoch,
    'rangeEndEpochMs': rangeEnd.millisecondsSinceEpoch,
    'timeZoneOffsetMinutes': generatedAt.timeZoneOffset.inMinutes,
    'reminderMinutes': reminderMinutes,
    'courses': courses.map((course) => course.toJson()).toList(),
  };

  String encode() => jsonEncode(toJson());
}

class WatchScheduleSnapshotBuilder {
  const WatchScheduleSnapshotBuilder();

  WatchScheduleSnapshot build({
    required ClassTableData classTable,
    required DateTime effectiveTermStart,
    required int currentWeekIndex,
    required DateTime now,
    List<CustomClass> customClasses = const [],
    List<Subject> subjects = const [],
    List<ExperimentData> experiments = const [],
    DateTime? rangeStart,
    int days = 14,
    int reminderMinutes = 5,
  }) {
    if (days <= 0) {
      throw ArgumentError.value(days, 'days', 'Must be greater than zero.');
    }

    final requestedStart = rangeStart ?? now;
    final windowStart = DateTime(
      requestedStart.year,
      requestedStart.month,
      requestedStart.day,
    );
    final rangeEnd = windowStart.add(Duration(days: days));
    final validThrough = rangeEnd;
    final occurrences = <WatchCourseOccurrence>[];

    for (var dayOffset = 0; dayOffset < days; dayOffset++) {
      final date = windowStart.add(Duration(days: dayOffset));
      final delta = date.difference(effectiveTermStart).inDays;
      if (delta < 0) continue;

      final weekIndex = delta ~/ DateTime.daysPerWeek;
      if (weekIndex >= classTable.semesterLength) continue;

      for (final arrangement in classTable.timeArrangement) {
        if (arrangement.day != date.weekday ||
            weekIndex >= arrangement.weekList.length ||
            !arrangement.weekList[weekIndex]) {
          continue;
        }

        final startIndex = (arrangement.start - 1) * 2;
        final endIndex = (arrangement.stop - 1) * 2 + 1;
        if (startIndex < 0 ||
            endIndex >= timeList.length ||
            startIndex >= endIndex) {
          continue;
        }

        final startAt = _withTime(date, timeList[startIndex]);
        final endAt = _withTime(date, timeList[endIndex]);
        final detail = classTable.getClassDetail(arrangement);
        final source = arrangement.source.name;

        occurrences.add(
          WatchCourseOccurrence(
            id: '${classTable.semesterCode}-$source-${arrangement.index}-${startAt.millisecondsSinceEpoch}',
            name: detail.name,
            teacher: arrangement.teacher,
            classroom: arrangement.classroom,
            startAt: startAt,
            endAt: endAt,
            startSection: arrangement.start,
            endSection: arrangement.stop,
            colorARGB: _courseColors[arrangement.index % _courseColors.length],
            kind: WatchScheduleEntryKind.course,
          ),
        );
      }
    }

    for (var classIndex = 0; classIndex < customClasses.length; classIndex++) {
      final customClass = customClasses[classIndex];
      for (final timeRange in customClass.timeRanges) {
        final startAt = timeRange.startTime;
        final endAt = timeRange.endTime;
        if (startAt.isBefore(windowStart) || !startAt.isBefore(rangeEnd)) {
          continue;
        }

        occurrences.add(
          WatchCourseOccurrence(
            id: 'custom-${customClass.id}-${timeRange.id}',
            name: customClass.name,
            teacher: customClass.teacher,
            classroom: customClass.classroom,
            startAt: startAt,
            endAt: endAt,
            startSection: _nearestSection(startAt, isStart: true),
            endSection: _nearestSection(endAt, isStart: false),
            colorARGB:
                _courseColors[(classTable.classDetail.length + classIndex) %
                    _courseColors.length],
            kind: WatchScheduleEntryKind.course,
          ),
        );
      }
    }

    for (var index = 0; index < subjects.length; index++) {
      final subject = subjects[index];
      final startAt = subject.startTime;
      final endAt = subject.stopTime;
      if (startAt == null ||
          endAt == null ||
          startAt.isBefore(windowStart) ||
          !startAt.isBefore(rangeEnd)) {
        continue;
      }

      final seat = subject.seat?.trim();
      occurrences.add(
        WatchCourseOccurrence(
          id: 'exam-${subject.subject}-${startAt.millisecondsSinceEpoch}',
          name: '${subject.subject}${subject.type}',
          teacher: null,
          classroom: subject.place.trim().isEmpty ? null : subject.place.trim(),
          startAt: startAt,
          endAt: endAt,
          startSection: 0,
          endSection: 0,
          colorARGB: _courseColors[index % _courseColors.length],
          kind: WatchScheduleEntryKind.exam,
          note: seat == null || seat.isEmpty ? null : '座位 $seat',
        ),
      );
    }

    for (var index = 0; index < experiments.length; index++) {
      final experiment = experiments[index];
      for (final timeRange in experiment.timeRanges) {
        final startAt = timeRange.$1;
        final endAt = timeRange.$2;
        if (startAt.isBefore(windowStart) || !startAt.isBefore(rangeEnd)) {
          continue;
        }

        occurrences.add(
          WatchCourseOccurrence(
            id: 'experiment-${experiment.type.name}-$index-${startAt.millisecondsSinceEpoch}',
            name: experiment.name,
            teacher: experiment.teacher.trim().isEmpty
                ? null
                : experiment.teacher.trim(),
            classroom: experiment.classroom.trim().isEmpty
                ? null
                : experiment.classroom.trim(),
            startAt: startAt,
            endAt: endAt,
            startSection: 0,
            endSection: 0,
            colorARGB: _courseColors[index % _courseColors.length],
            kind: experiment.type == ExperimentType.physics
                ? WatchScheduleEntryKind.physicsExperiment
                : WatchScheduleEntryKind.otherExperiment,
            note: experiment.reference?.trim().isEmpty ?? true
                ? null
                : experiment.reference!.trim(),
          ),
        );
      }
    }

    occurrences.sort((left, right) => left.startAt.compareTo(right.startAt));
    return WatchScheduleSnapshot(
      generatedAt: now,
      semesterStart: effectiveTermStart,
      currentWeekIndex: currentWeekIndex,
      validThrough: validThrough,
      rangeStart: windowStart,
      rangeEnd: rangeEnd,
      reminderMinutes: reminderMinutes,
      courses: occurrences,
    );
  }

  // Exact ARGB values used by themes/color_seed.dart's Material color list.
  static const _courseColors = <int>[
    0xFFF44336,
    0xFFE91E63,
    0xFF9C27B0,
    0xFF673AB7,
    0xFF3F51B5,
    0xFF2196F3,
    0xFF03A9F4,
    0xFF00BCD4,
    0xFF009688,
    0xFF4CAF50,
    0xFF8BC34A,
    0xFFCDDC39,
    0xFFFFEB3B,
    0xFFFF9800,
    0xFFFF5722,
    0xFF795548,
  ];

  DateTime _withTime(DateTime date, String time) {
    final parts = time.split(':');
    return DateTime(
      date.year,
      date.month,
      date.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );
  }

  int _nearestSection(DateTime dateTime, {required bool isStart}) {
    final targetMinutes = dateTime.hour * 60 + dateTime.minute;
    var nearestSection = 1;
    var nearestDistance = 1 << 30;

    for (var section = 0; section < timeList.length ~/ 2; section++) {
      final index = section * 2 + (isStart ? 0 : 1);
      final parts = timeList[index].split(':');
      final minutes = int.parse(parts[0]) * 60 + int.parse(parts[1]);
      final distance = (minutes - targetMinutes).abs();
      if (distance < nearestDistance) {
        nearestDistance = distance;
        nearestSection = section + 1;
      }
    }
    return nearestSection;
  }
}
