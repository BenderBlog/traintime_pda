// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0 OR Apache-2.0

import 'dart:math' as math;

import 'package:device_calendar/device_calendar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:watermeter/controller/classtable_controller.dart';
import 'package:watermeter/controller/exam_controller.dart';
import 'package:watermeter/controller/experiment_controller.dart';
import 'package:watermeter/model/xidian_ids/classtable.dart';
import 'package:watermeter/model/xidian_ids/exam.dart';
import 'package:watermeter/model/xidian_ids/experiment.dart';
import 'package:watermeter/page/classtable/class_table_view/class_organized_data.dart';
import 'package:watermeter/repository/logger.dart';
import 'package:watermeter/repository/preference.dart' as preference;
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

/// The controllers and shared datas of the class table.
class ClassTableWidgetState with ChangeNotifier {
  ///*******************************************************************///
  /// Hack on notifyListeners, do not fire when the widget is disposed. ///
  ///*******************************************************************///
  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
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
  final ClassTableController classTableController = Get.find();
  final ExamController examController = Get.find();
  final ExperimentController experimentController = Get.find();

  /// The length of the semester, the amount of the class table.
  int get semesterLength => classTableController.classTableData.semesterLength;

  /// The semester code.
  String get semesterCode => classTableController.classTableData.semesterCode;

  /// The offset append to start day of the week.
  final int offset = preference.getInt(preference.Preference.swift);

  ///*****************************///
  /// Following are dynamic data. ///
  /// ****************************///

  /// If no class, a special page appears.
  bool get haveClass => timeArrangement.isNotEmpty && classDetail.isNotEmpty;

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
      classTableController.classTableData.classDetail;

  /// The classes without time arrangements.
  List<NotArrangementClassDetail> get notArranged =>
      classTableController.classTableData.notArranged;

  /// The time arrangements of the class details, use with [classDetail].
  List<TimeArrangement> get timeArrangement =>
      classTableController.classTableData.timeArrangement;

  /// The class change data.
  List<ClassChange> get classChange =>
      classTableController.classTableData.classChanges;

  /// The day the semester start, used to calculate the first day of the week.
  DateTime get startDay =>
      DateTime.parse(classTableController.classTableData.termStartDay);

  /// The currentWeek.
  final int currentWeek;

  /// The exam list.
  List<Subject> get subjects => examController.data.subject;

  /// The experiment list.
  List<ExperimentData> get experiments => experimentController.data;

  /// Get class detail by prividing index of timearrangement
  ClassDetail getClassDetail(int index) => classTableController.classTableData
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
    classTableData: classTableController.classTableData,
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
    return await Future.wait([
      classTableController.updateClassTable(isForce: true),
      examController.get(),
      experimentController.get(),
    ]).then((value) async {
      await maybeAutoSyncSystemCalendar();
      notifyListeners();
    });
  }

  ClassTableWidgetState({required this.currentWeek}) {
    if (currentWeek < 0) {
      _chosenWeek = 0;
    } else if (currentWeek >= semesterLength) {
      _chosenWeek = semesterLength - 1;
    } else {
      _chosenWeek = currentWeek;
    }
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
