// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'package:watermeter/model/xidian_ids/classtable.dart';
import 'package:watermeter/model/xidian_ids/exam.dart';
import 'package:watermeter/model/xidian_ids/experiment.dart';

typedef WeekIndexResolver = int Function(DateTime date);

class ScheduleSnapshot {
  final ClassTableData classTableData;
  final List<Subject> subjects;
  final List<ExperimentData> experiments;
  final WeekIndexResolver getCurrentWeek;

  const ScheduleSnapshot({
    required this.classTableData,
    required this.subjects,
    required this.experiments,
    required this.getCurrentWeek,
  });

  bool get hasValidClassInfo => classTableData.termStartDay.isNotEmpty;

  bool get hasSchedulableReminderSourceData =>
      hasValidClassInfo ||
      experiments.isNotEmpty ||
      subjects.any((subject) => subject.startTime != null);
}
