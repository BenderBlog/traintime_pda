// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0 OR Apache-2.0

// Copied from https://github.com/SimformSolutionsPvtLtd/flutter_calendar_view/blob/master/lib/src/event_arrangers/event_arrangers.dart.
// Removed left/right, only use stack.

import 'package:flutter/material.dart';
import 'package:watermeter/model/time_list.dart';
import 'package:watermeter/model/xidian_ids/exam.dart';
import 'package:watermeter/model/xidian_ids/classtable.dart';
import 'package:watermeter/model/xidian_ids/experiment.dart';

class ClassOrgainzedData {
  final List<dynamic> data;

  /// The time range of each block is not even in exam
  /// or experiment, so use double...
  ///
  /// Classtable blanks below per blocks.
  ///  * Morning 1-4 each 5 blocks.
  ///  * Noon break 3 blocks
  ///  * Afternoon 5-8 each 5 blocks.
  ///  * Supper time 3 blocks.
  ///  * Evening time 9-11 each 5 blocks.
  /// Total 61 parts, 49 as phone divider.
  ///
  late final double start;
  late final double stop;

  final String name;
  final String? place;
  final DateTime? actualEndTime;

  final MaterialColor color;

  factory ClassOrgainzedData.fromTimeArrangement(
    TimeArrangement timeArrangement,
    MaterialColor color,
    String name,
  ) {
    double transferIndex(int index, {bool isStart = false}) {
      late double toReturn;
      if (index <= 4) {
        toReturn = index * 5;
        if (isStart && index == 4) {
          toReturn += 3;
        }
      } else if (index <= 8) {
        toReturn = index * 5 + 3;
        if (isStart && index == 8) {
          toReturn += 3;
        }
      } else {
        return index * 5 + 6;
      }
      return toReturn;
    }

    return ClassOrgainzedData(
      data: [timeArrangement],
      start: transferIndex(timeArrangement.start - 1, isStart: true),
      stop: transferIndex(timeArrangement.stop),
      color: color,
      name: name,
      place: timeArrangement.classroom,
      actualEndTime: null,
    );
  }

  /// Ensure the [Subject.startTime] and [Subject.stopTime] is not NULL!
  factory ClassOrgainzedData.fromSubject(
    MaterialColor color,
    Subject subject,
  ) => ClassOrgainzedData._(
    data: [(subject)],
    start: subject.startTime!,
    stop: subject.stopTime!,
    color: color,
    name: "${subject.subject}${subject.type}",
    place:
        "${subject.place} "
        "${subject.seat == null ? "" : "${subject.seat}"}",
    actualEndTime: subject.stopTime,
  );

  factory ClassOrgainzedData.fromExperiment(
    MaterialColor color,
    ExperimentData exp,
    DateTime start,
    DateTime stop,
  ) => ClassOrgainzedData._(
    data: [exp],
    start: start,
    stop: stop,
    color: color,
    name: exp.name,
    place: exp.classroom,
    actualEndTime: stop,
  );

  ClassOrgainzedData({
    required this.data,
    required this.start,
    required this.stop,
    required this.name,
    required this.color,
    this.place,
    this.actualEndTime,
  });

  static double _transferIndex(DateTime time) {
    final timeInMin = time.hour * 60 + time.minute;
    if (timeList.isEmpty) {
      return 0;
    }

    int parseMinute(String hhmm) {
      final parts = hhmm.split(':');
      return int.parse(parts[0]) * 60 + int.parse(parts[1]);
    }

    double classStartBlock(int classIndex) {
      if (classIndex < 4) {
        return classIndex * 5.0;
      }
      if (classIndex < 8) {
        return 23 + (classIndex - 4) * 5.0;
      }
      return 46 + (classIndex - 8) * 5.0;
    }

    final firstStart = parseMinute(timeList.first);
    if (timeInMin < firstStart) {
      return 0;
    }

    final classCount = timeList.length ~/ 2;
    for (var classIndex = 0; classIndex < classCount; classIndex++) {
      final startMinute = parseMinute(timeList[classIndex * 2]);
      final endMinute = parseMinute(timeList[classIndex * 2 + 1]);
      final startBlock = classStartBlock(classIndex);
      final endBlock = startBlock + 5;

      if (timeInMin >= startMinute && timeInMin < endMinute) {
        final ratio = (timeInMin - startMinute) / (endMinute - startMinute);
        return startBlock + 5 * ratio;
      }

      if (classIndex == classCount - 1) {
        if (timeInMin >= endMinute) {
          return 61;
        }
        continue;
      }

      final nextStartMinute = parseMinute(timeList[(classIndex + 1) * 2]);
      if (timeInMin >= endMinute && timeInMin < nextStartMinute) {
        final nextStartBlock = classStartBlock(classIndex + 1);
        final breakMinuteSpan = nextStartMinute - endMinute;
        final breakBlockSpan = nextStartBlock - endBlock;

        if (breakMinuteSpan > 0 && breakBlockSpan > 0) {
          final ratio = (timeInMin - endMinute) / breakMinuteSpan;
          return endBlock + breakBlockSpan * ratio;
        }
        return endBlock;
      }
    }

    return 61;
  }

  ClassOrgainzedData._({
    required this.data,
    required DateTime start,
    required DateTime stop,
    required this.color,
    required this.name,
    this.place,
    this.actualEndTime,
  }) {
    this.start = _transferIndex(start);
    this.stop = _transferIndex(stop);
  }
}
