// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0 OR Apache-2.0

import 'dart:async';
import 'dart:math' as math;

import 'package:device_calendar/device_calendar.dart';
import 'package:flutter/material.dart';
import 'package:signals/signals.dart';

import 'package:watermeter/controller/classtable_controller.dart';
import 'package:watermeter/controller/exam_controller.dart';
import 'package:watermeter/controller/other_experiment_controller.dart';
import 'package:watermeter/controller/physics_experiment_controller.dart';
import 'package:watermeter/controller/week_swift_controller.dart';
import 'package:watermeter/model/xidian_ids/classtable.dart';
import 'package:watermeter/model/xidian_ids/exam.dart';
import 'package:watermeter/model/xidian_ids/experiment.dart';
import 'package:watermeter/page/classtable/class_table_view/class_organized_data.dart';
import 'package:watermeter/repository/logger.dart';
import 'package:watermeter/repository/system_calendar_sync_service.dart';
import 'package:watermeter/themes/color_seed.dart';

/// Use a inheritedWidget to share the ClassTableWidgetState
class ClassTableState extends InheritedWidget {
  final ClassTableWidgetState controllers;
  final BuildContext parentContext;
  final BoxConstraints constraints;

  const ClassTableState({
    super.key,
    required super.child,
    required this.parentContext,
    required this.controllers,
    required this.constraints,
  });

  static ClassTableState? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ClassTableState>();
  }

  @override
  bool updateShouldNotify(covariant ClassTableState oldWidget) {
    controllers.chosenWeek = oldWidget.controllers.chosenWeek;
    return true;
  }
}

enum ClassTableStatusSource {
  classTable,
  exam,
  physicsExperiment,
  otherExperiment,
}

/// The controllers and shared datas of the class table.
class ClassTableWidgetState with ChangeNotifier {
  ///*******************************************************************///
  /// Hack on notifyListeners, do not fire when the widget is disposed. ///
  ///*******************************************************************///
  bool _disposed = false;
  final List<EffectCleanup> _effectCleanup = [];
  Timer? _clockTimer;
  DateTime _currentTime = DateTime.now();

  @override
  void dispose() {
    _disposed = true;
    _clockTimer?.cancel();
    for (final cleanup in _effectCleanup) {
      cleanup();
    }
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_disposed) {
      super.notifyListeners();
    }
  }

  ///****************************///
  /// Following are static data. ///
  /// ***************************///

  /// The controller...
  final ClassTableController classTableController = ClassTableController.i;
  final ExamController examController = ExamController.i;
  final PhysicsExperimentController physicsExperimentController =
      PhysicsExperimentController.i;
  final OtherExperimentController otherExperimentController =
      OtherExperimentController.i;
  final WeekSwiftController weekSwiftController = WeekSwiftController.i;

  void _initClockTimer() {
    _clockTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      _currentTime = DateTime.now();
      notifyListeners();
    });
  }

  void _initEffects() {
    _initClockTimer();
    _effectCleanup.add(
      effect(() {
        classTableController.schoolClassTableStateSignal.value;
        classTableController.classTableComputedSignal.value;
        classTableController.isClassTableFromCacheComputedSignal.value;
        classTableController.classTableCacheHintKeyComputedSignal.value;
        examController.examInfoStateSignal.value;
        examController.subjects.value;
        examController.isExamFromCache.value;
        examController.examCacheHintKey.value;
        physicsExperimentController.physicsExperimentStateSignal.value;
        physicsExperimentController.physicsExperiments.value;
        physicsExperimentController.isPhysicsExperimentFromCache.value;
        physicsExperimentController.physicsExperimentCacheHintKey.value;
        otherExperimentController.otherExperimentStateSignal.value;
        otherExperimentController.otherExperiments.value;
        otherExperimentController.isOtherExperimentFromCache.value;
        otherExperimentController.otherExperimentCacheHintKey.value;
        weekSwiftController.weekSwiftSignal.value;
        notifyListeners();
      }, debugLabel: "ClassTableWidgetStateSignalBridgeEffect"),
    );
    // Init current week info
    if (currentWeek < 0) {
      _chosenWeek = 0;
    } else if (currentWeek >= semesterLength) {
      _chosenWeek = semesterLength - 1;
    } else {
      _chosenWeek = currentWeek;
    }
  }

  /// The length of the semester, the amount of the class table.
  int get semesterLength =>
      classTableController.classTableComputedSignal.value.semesterLength;

  /// The offset append to start day of the week.
  int get offset => weekSwiftController.weekSwiftSignal.value;

  /// The semester code.
  String get semesterCode =>
      classTableController.classTableComputedSignal.value.semesterCode;

  String get decorationName => ClassTableController.decorationName;

  DateTime get currentTime => _currentTime;

  ///*****************************///
  /// Following are dynamic data. ///
  /// ****************************///

  /// If no class, a special page appears.
  bool get haveClass => timeArrangement.isNotEmpty && classDetail.isNotEmpty;

  bool get isClassTableLoading =>
      classTableController.schoolClassTableStateSignal.value.isLoading;

  bool get hasClassTableLoadError =>
      classTableController.schoolClassTableStateSignal.value is AsyncError;

  bool get isClassTableFromCache =>
      classTableController.isClassTableFromCacheComputedSignal.value;

  String? get classTableCacheHintKey =>
      classTableController.classTableCacheHintKeyComputedSignal.value;

  DateTime? get classTableFetchTime =>
      classTableController.classTableFetchTimeComputedSignal.value;

  bool get isExamLoading => examController.examInfoStateSignal.value.isLoading;

  bool get hasExamLoadError =>
      examController.examInfoStateSignal.value is AsyncError;

  bool get isExamFromCache => examController.isExamFromCache.value;

  String? get examCacheHintKey => examController.examCacheHintKey.value;

  bool get isPhysicsExperimentLoading =>
      physicsExperimentController.physicsExperimentStateSignal.value.isLoading;

  bool get hasPhysicsExperimentLoadError =>
      physicsExperimentController.physicsExperimentStateSignal.value
          is AsyncError;

  bool get isPhysicsExperimentFromCache =>
      physicsExperimentController.isPhysicsExperimentFromCache.value;

  String? get physicsExperimentCacheHintKey =>
      physicsExperimentController.physicsExperimentCacheHintKey.value;

  bool get isOtherExperimentLoading =>
      otherExperimentController.otherExperimentStateSignal.value.isLoading;

  bool get hasOtherExperimentLoadError =>
      otherExperimentController.otherExperimentStateSignal.value is AsyncError;

  bool get isOtherExperimentFromCache =>
      otherExperimentController.isOtherExperimentFromCache.value;

  String? get otherExperimentCacheHintKey =>
      otherExperimentController.otherExperimentCacheHintKey.value;

  bool get hasExamArrangement => examController.hasExamArrangement.value;

  bool get hasExperimentArrangement =>
      physicsExperimentController.hasPhysicsExperimentArrangement.value ||
      otherExperimentController.hasOtherExperimentArrangement.value;

  int get currentWeek => ClassTableController.i.currentWeekComputedSignal.value;

  bool get havePhysicsExperiment =>
      ClassTableController.i.havePhysicsExperimentSignal.value;

  List<ClassTableStatusSource> get loadingSources => [
    if (isClassTableLoading) ClassTableStatusSource.classTable,
    if (isExamLoading) ClassTableStatusSource.exam,
    if (isPhysicsExperimentLoading) ClassTableStatusSource.physicsExperiment,
    if (isOtherExperimentLoading) ClassTableStatusSource.otherExperiment,
  ];

  List<ClassTableStatusSource> get cacheSources => [
    if (isClassTableFromCache) ClassTableStatusSource.classTable,
    if (isExamFromCache) ClassTableStatusSource.exam,
    if (isPhysicsExperimentFromCache) ClassTableStatusSource.physicsExperiment,
    if (isOtherExperimentFromCache) ClassTableStatusSource.otherExperiment,
  ];

  List<ClassTableStatusSource> get errorWithoutCacheSources => [
    if (hasClassTableLoadError) ClassTableStatusSource.classTable,
    if (hasExamLoadError) ClassTableStatusSource.exam,
    if (hasPhysicsExperimentLoadError && havePhysicsExperiment)
      ClassTableStatusSource.physicsExperiment,
    if (hasOtherExperimentLoadError) ClassTableStatusSource.otherExperiment,
  ];

  List<ClassTableStatusSource> get errorWithCacheSources => [
    if (!hasClassTableLoadError &&
        isClassTableFromCache &&
        classTableCacheHintKey != null)
      ClassTableStatusSource.classTable,
    if (!hasExamLoadError && isExamFromCache && examCacheHintKey != null)
      ClassTableStatusSource.exam,
    if (!hasPhysicsExperimentLoadError &&
        isPhysicsExperimentFromCache &&
        physicsExperimentCacheHintKey != null)
      ClassTableStatusSource.physicsExperiment,
    if (!hasOtherExperimentLoadError &&
        isOtherExperimentFromCache &&
        otherExperimentCacheHintKey != null)
      ClassTableStatusSource.otherExperiment,
  ];

  /// Current showing week.
  int _chosenWeek = 0;

  /// Change chosen week.
  set chosenWeek(int chosenWeek) {
    if (chosenWeek != _chosenWeek) {
      _chosenWeek = chosenWeek;
    }
    notifyListeners();
  }

  int get chosenWeek => _chosenWeek;

  /// The class details.
  List<ClassDetail> get classDetail =>
      classTableController.classTableComputedSignal.value.classDetail;

  /// The classes without time arrangements.
  List<NotArrangementClassDetail> get notArranged =>
      classTableController.classTableComputedSignal.value.notArranged;

  /// The time arrangements of the class details, use with [classDetail].
  List<TimeArrangement> get timeArrangement =>
      classTableController.classTableComputedSignal.value.timeArrangement;

  /// The class change data.
  List<ClassChange> get classChange =>
      classTableController.classTableComputedSignal.value.classChanges;

  /// The day the semester start, used to calculate the first day of the week.
  DateTime get startDay => DateTime.parse(
    classTableController.classTableComputedSignal.value.termStartDay,
  );

  /// The exam list.
  List<Subject> get subjects => examController.subjects.value;

  /// The experiment list.
  List<ExperimentData> get experiments => [
    ...physicsExperimentController.physicsExperiments.value,
    ...otherExperimentController.otherExperiments.value,
  ];

  /// Get class detail by prividing index of timearrangement
  ClassDetail getClassDetail(int index) => classTableController
      .classTableComputedSignal
      .value
      .getClassDetail(timeArrangement[index]);

  /// Bridge function to add/del/edit user defined class
  /// Only main classtable support it!
  Future<void> addUserDefinedClass(
    ClassDetail classDetail,
    TimeArrangement timeArrangement,
  ) => classTableController
      .addUserDefinedClass(classDetail, timeArrangement)
      .then((value) => notifyListeners());

  Future<void> editUserDefinedClass(
    TimeArrangement oldTimeArrangment,
    ClassDetail classDetail,
    TimeArrangement timeArrangement,
  ) => classTableController
      .editUserDefinedClass(oldTimeArrangment, classDetail, timeArrangement)
      .then((value) => notifyListeners());

  Future<void> deleteUserDefinedClass(TimeArrangement timeArrangement) =>
      classTableController
          .deleteUserDefinedClass(timeArrangement)
          .then((value) => notifyListeners());

  List<Event> get events => buildCalendarEvents(
    classTableData: classTableController.classTableComputedSignal.value,
    subjects: subjects,
    experiments: experiments,
  );

  /// Generate icalendar file string.
  String get iCalenderStr => buildICalendarString(events);

  /// Output to System Calendar
  Future<bool> outputToCalendar(Future<void> Function() showDialog) async {
    return await SystemCalendarSyncService().syncSystemCalendar(
      requestPermissionsIfNeeded: true,
      onlyIfCalendarExists: false,
      showDialog: showDialog,
    );
  }

  /// Update classtable infos
  Future<void> updateClasstable(BuildContext context) async {
    log.info("Updating time arrangement data...");
    await Future.wait([
      classTableController.reloadClassTable(),
      examController.reloadExamInfo(),
      physicsExperimentController.reloadPhysicsExperiment(),
      otherExperimentController.reloadOtherExperiment(),
    ]);
    await maybeAutoSyncSystemCalendar();
    notifyListeners();
  }

  ClassTableWidgetState() {
    _initEffects();
  }

  bool _checkIsOverlapping(
    double eStart1,
    double eEnd1,
    double eStart2,
    double eEnd2,
  ) =>
      (eStart1 >= eStart2 && eStart1 < eEnd2) ||
      (eEnd1 > eStart2 && eEnd1 <= eEnd2) ||
      (eStart2 >= eStart1 && eStart2 < eEnd1) ||
      (eEnd2 > eStart1 && eEnd2 <= eEnd1);

  /// [weekIndex] start from 0 while [dayIndex] start from 1
  List<ClassOrgainzedData> getArrangement({
    required int weekIndex,
    required int dayIndex,
  }) {
    /// Fetch all class in this range.
    List<ClassOrgainzedData> events = [];

    for (final i in timeArrangement) {
      if (i.weekList.length > weekIndex &&
          i.weekList[weekIndex] &&
          i.day == dayIndex) {
        events.add(
          ClassOrgainzedData.fromTimeArrangement(
            i,
            colorList[i.index % colorList.length],
            getClassDetail(timeArrangement.indexOf(i)).name,
          ),
        );
      }
    }

    for (final i in subjects) {
      if (i.startTime == null ||
          i.stopTime == null ||
          i.startTime!.isBefore(startDay)) {
        continue;
      }

      int diff = i.startTime!.difference(startDay).inDays;

      if (diff ~/ 7 == weekIndex && diff % 7 + 1 == dayIndex) {
        events.add(
          ClassOrgainzedData.fromSubject(
            colorList[subjects.indexOf(i) % colorList.length],
            i,
          ),
        );
      }
    }

    for (final experiment in experiments) {
      for (final timeRange in experiment.timeRanges) {
        if (timeRange.$1.isBefore(startDay)) {
          continue;
        }
        int diff = timeRange.$1.difference(startDay).inDays;

        if (diff ~/ 7 == weekIndex && diff % 7 + 1 == dayIndex) {
          events.add(
            ClassOrgainzedData.fromExperiment(
              colorList[experiments.indexOf(experiment) % colorList.length],
              experiment,
              timeRange.$1,
              timeRange.$2,
            ),
          );
        }
      }
    }

    /// Sort it with the ascending order of start time.
    events.sort((a, b) => a.start.compareTo(b.start));

    /// The arrangement to use
    List<ClassOrgainzedData> arrangedEvents = [];

    for (final event in events) {
      final startTime = event.start;
      final endTime = event.stop;

      var eventIndex = -1;
      final arrangeEventLen = arrangedEvents.length;

      for (var i = 0; i < arrangeEventLen; i++) {
        final arrangedEventStart = arrangedEvents[i].start;
        final arrangedEventEnd = arrangedEvents[i].stop;

        if (_checkIsOverlapping(
          arrangedEventStart,
          arrangedEventEnd,
          startTime,
          endTime,
        )) {
          eventIndex = i;
          break;
        }
      }

      if (eventIndex == -1) {
        arrangedEvents.add(event);
      } else {
        final arrangedEventData = arrangedEvents[eventIndex];

        final arrangedEventStart = arrangedEventData.start;
        final arrangedEventEnd = arrangedEventData.stop;

        final startDuration = math.min(startTime, arrangedEventStart);
        final endDuration = math.max(endTime, arrangedEventEnd);

        bool shouldNew =
            (event.stop - event.start) >=
            (arrangedEventData.stop - arrangedEventData.start);

        final top = startDuration;
        final bottom = endDuration;

        final newEvent = ClassOrgainzedData(
          start: top,
          stop: bottom,
          data: [...arrangedEventData.data, ...event.data],
          color: shouldNew ? event.color : arrangedEventData.color,
          name: shouldNew ? event.name : arrangedEventData.name,
          place: shouldNew ? event.place : arrangedEventData.place,
        );

        arrangedEvents[eventIndex] = newEvent;
      }
    }

    return arrangedEvents;
  }
}
