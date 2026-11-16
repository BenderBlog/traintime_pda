// Copyright 2026 Traintime PDA Authours, originally by BenderBlog Rodriguez.
// SPDX-License-Identifier: MPL-2.0

import 'package:watermeter/model/fetch_result.dart';
import 'package:watermeter/model/pda_service/custom_class.dart';
import 'package:watermeter/model/xidian_ids/classtable.dart';
import 'package:watermeter/model/xidian_ids/exam.dart';
import 'package:watermeter/model/xidian_ids/experiment.dart';
import 'package:watermeter/page/classtable/model/classtable_status_source.dart';

/// What one of the four sources behind the class table currently is.
class ClassSourceStatus {
  const ClassSourceStatus({
    this.isLoading = false,
    this.hasError = false,
    this.isFromCache = false,
    this.hasArrangement = true,
    this.cacheHint,
  });

  final bool isLoading;
  final bool hasError;
  final bool isFromCache;

  /// Whether this source carries anything the table shows; a user without experiments has none.
  final bool hasArrangement;

  final CacheHint? cacheHint;
}

/// The class table as one value.
///
/// The view listens to one `ValueListenable` of this instead of to a dozen signals, and the status
/// lists are derived here, once. Treated as read-only: [classTableData] is the controller's own
/// object rather than a copy, because copying a whole semester on every refresh would cost more
/// than it buys, so nothing on the page side may mutate it.
class ClasstableSnapshot {
  const ClasstableSnapshot({
    required this.classTableData,
    required this.classTable,
    required this.exam,
    required this.physicsExperiment,
    required this.otherExperiment,
    required this.subjects,
    required this.experiments,
    required this.customClasses,
    required this.weekOffset,
    required this.hasExamArrangement,
    required this.havePhysicsExperiment,
    required this.haveOtherExperiment,
  });

  final ClassTableData classTableData;
  final ClassSourceStatus classTable;
  final ClassSourceStatus exam;
  final ClassSourceStatus physicsExperiment;
  final ClassSourceStatus otherExperiment;
  final List<Subject> subjects;
  final List<ExperimentData> experiments;
  final List<CustomClass> customClasses;

  /// Weeks the user has scrolled forward on their own timetable.
  final int weekOffset;

  final bool hasExamArrangement;

  /// Whether the course table itself mentions a physics experiment course, and whether the user is
  /// allowed other experiments at all. These gate the error banner, not the table's contents.
  final bool havePhysicsExperiment;
  final bool haveOtherExperiment;

  bool get hasData =>
      classTableData.timeArrangement.isNotEmpty &&
      classTableData.classDetail.isNotEmpty;

  int get semesterLength => classTableData.semesterLength;
  String get semesterCode => classTableData.semesterCode;

  /// The first day of the semester as the timetable was fetched, before [weekOffset].
  ///
  /// This is the origin the grid's week index counts from.
  DateTime? get gridStartDay {
    return classTableData.termStartDay.isEmpty
        ? null
        : DateTime.tryParse(classTableData.termStartDay);
  }

  /// The first day of the week the table currently calls week 0.
  DateTime? get semesterStartDay =>
      gridStartDay?.add(Duration(days: 7 * weekOffset));

  /// The week [time] falls in, or -1 while the semester start is unknown.
  int weekOf(DateTime time) {
    final start = semesterStartDay;
    if (start == null) return -1;
    final delta = time.difference(start).inDays;
    return (delta < 0 ? -7 : delta) ~/ 7;
  }

  bool get hasExperimentArrangement =>
      physicsExperiment.hasArrangement || otherExperiment.hasArrangement;

  List<ClasstableStatusSource> get loadingSources => [
    if (classTable.isLoading) ClasstableStatusSource.classTable,
    if (exam.isLoading) ClasstableStatusSource.exam,
    if (physicsExperiment.isLoading) ClasstableStatusSource.physicsExperiment,
    if (otherExperiment.isLoading) ClasstableStatusSource.otherExperiment,
  ];

  List<ClasstableStatusSource> get errorWithoutCacheSources => [
    if (classTable.hasError) ClasstableStatusSource.classTable,
    if (exam.hasError) ClasstableStatusSource.exam,
    if (physicsExperiment.hasError && havePhysicsExperiment)
      ClasstableStatusSource.physicsExperiment,
    if (otherExperiment.hasError && haveOtherExperiment)
      ClasstableStatusSource.otherExperiment,
  ];

  List<ClasstableStatusSource> get errorWithCacheSources => [
    if (!classTable.hasError &&
        classTable.isFromCache &&
        classTable.cacheHint != null)
      ClasstableStatusSource.classTable,
    if (!exam.hasError && exam.isFromCache && exam.cacheHint != null)
      ClasstableStatusSource.exam,
    if (!physicsExperiment.hasError &&
        physicsExperiment.isFromCache &&
        physicsExperiment.cacheHint != null)
      ClasstableStatusSource.physicsExperiment,
    if (!otherExperiment.hasError &&
        otherExperiment.isFromCache &&
        otherExperiment.cacheHint != null)
      ClasstableStatusSource.otherExperiment,
  ];
}
