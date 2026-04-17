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

  final MaterialColor color;

  /// Following is the begin/end for each blocks...
  static const _timeInBlock = [
    "08:30",
    "09:20",
    "10:25",
    "11:15",
    "12:00",
    "14:00",
    "14:50",
    "15:55",
    "16:45",
    "17:30",
    "19:00",
    "19:55",
    "20:35",
    "21:25",
  ];

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
  );

  ClassOrgainzedData({
    required this.data,
    required this.start,
    required this.stop,
    required this.name,
    required this.color,
    this.place,
  });

  static double transferIndex(DateTime time) {
    int timeInMin = time.hour * 60 + time.minute;
    int previous = 0;
    // Start from the second element.
    for (var i in _timeInBlock) {
      int timeChosen =
          int.parse(i.split(":")[0]) * 60 + int.parse(i.split(":")[1]);
      if (previous == 0) {
        // Some exam is started before 8:30
        if (timeInMin < timeChosen) {
          return 0;
        }
        previous = timeChosen;
        continue;
      }
      if (timeInMin >= previous && timeInMin < timeChosen) {
        double basic = 0;
        double blocks = 5;
        double ratio = (timeInMin - previous) / (timeChosen - previous);
        if (previous < 12 * 60) {
          basic = (_timeInBlock.indexOf(i) - 1) * 5;
        } else if (previous < 14 * 60) {
          basic = 20;
          blocks = 3;
        } else if (previous < 17.5 * 60) {
          basic = 23 + (_timeInBlock.indexOf(i) - 6) * 5;
        } else if (previous < 19 * 60) {
          basic = 43;
          blocks = 3;
        } else {
          basic = 46 + (_timeInBlock.indexOf(i) - 11) * 5;
        }
        return basic + blocks * ratio;
      } else {
        previous = timeChosen;
      }
    }

    return 61;
  }

  static double transferIndexForIndicator(DateTime time) {
    int minutesOfDay(String value) {
      final timeParts = value.split(":");
      return int.parse(timeParts[0]) * 60 + int.parse(timeParts[1]);
    }

    double indexOfMinute(int value) {
      return transferIndex(
        DateTime(time.year, time.month, time.day, value ~/ 60, value % 60),
      );
    }

    final timeInMin = time.hour * 60 + time.minute;

    for (int i = 0; i < timeList.length; i += 2) {
      final start = minutesOfDay(timeList[i]);
      final stop = minutesOfDay(timeList[i + 1]);
      final nextStart = i + 2 < timeList.length
          ? minutesOfDay(timeList[i + 2])
          : null;
      final isSmallBreak = nextStart != null && nextStart - stop <= 20;
      final visualStop = isSmallBreak ? nextStart : stop;

      // During class, map the elapsed class time across the visual block including the following small break.
      if (timeInMin >= start && timeInMin < stop) {
        final startIndex = indexOfMinute(start);
        final stopIndex = indexOfMinute(visualStop);
        return startIndex +
            (stopIndex - startIndex) * (timeInMin - start) / (stop - start);
      }

      // During a small break, show the indicator at the end of the class.
      if (isSmallBreak && timeInMin >= stop && timeInMin < visualStop) {
        return indexOfMinute(visualStop);
      }
    }

    return transferIndex(time);
  }

  ClassOrgainzedData._({
    required this.data,
    required DateTime start,
    required DateTime stop,
    required this.color,
    required this.name,
    this.place,
  }) {
    this.start = transferIndex(start);
    this.stop = transferIndex(stop);
  }
}
