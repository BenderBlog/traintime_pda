// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0 OR Apache-2.0

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jiffy/jiffy.dart';
import 'package:watermeter/controller/classtable_controller.dart';
import 'package:watermeter/controller/exam_controller.dart';
import 'package:watermeter/controller/experiment_controller.dart';
import 'package:watermeter/model/xidian_ids/classtable.dart';
import 'package:watermeter/model/xidian_ids/exam.dart';
import 'package:watermeter/model/xidian_ids/experiment.dart';
import 'package:watermeter/page/classtable/class_table_view/class_organized_data.dart';
import 'package:watermeter/repository/preference.dart' as preference;
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
    return controllers.chosenWeek != oldWidget.controllers.chosenWeek;
  }
}

/// The controllers and shared datas of the class table.
class ClassTableWidgetState with ChangeNotifier {
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
      Jiffy.parse(classTableController.classTableData.termStartDay).dateTime;

  /// The currentWeek.
  final int currentWeek;

  /// The exam list.
  List<Subject> get subjects => examController.data.subject;

  /// The experiment list.
  List<ExperimentData> get experiments => experimentController.data;

  ///*****************************///
  /// Following are dynamic data. ///
  /// ****************************///

  /// Current showing week.
  int _chosenWeek = 0;

  /// Change chosen week.
  set chosenWeek(int chosenWeek) {
    _chosenWeek = chosenWeek;
    notifyListeners();
  }

  int get chosenWeek => _chosenWeek;

  /// Get class detail by prividing index of timearrangement
  ClassDetail getClassDetail(int index) =>
      classTableController.classTableData.getClassDetail(
        classTableController.classTableData.timeArrangement[index],
      );

  /// Bridge function to add/del/edit user defined class
  Future<void> addUserDefinedClass(
    ClassDetail classDetail,
    TimeArrangement timeArrangement,
  ) =>
      classTableController
          .addUserDefinedClass(
            classDetail,
            timeArrangement,
          )
          .then((value) => notifyListeners());

  Future<void> editUserDefinedClass(
    TimeArrangement oldTimeArrangment,
    ClassDetail classDetail,
    TimeArrangement timeArrangement,
  ) =>
      classTableController
          .editUserDefinedClass(
            oldTimeArrangment,
            classDetail,
            timeArrangement,
          )
          .then((value) => notifyListeners());

  Future<void> deleteUserDefinedClass(
    TimeArrangement timeArrangement,
  ) =>
      classTableController
          .deleteUserDefinedClass(timeArrangement)
          .then((value) => notifyListeners());

  /// Generate icalendar file string.
  String get iCalenderStr {
    String toReturn = "BEGIN:VCALENDAR\n";
    for (var i in timeArrangement) {
      String summary =
          "SUMMARY:${classDetail[i.index].name}@${i.classroom ?? "待定"}\n";
      String description =
          "DESCRIPTION:课程名称：${classDetail[i.index].name}; 上课地点：${i.classroom ?? "待定"}\n";
      for (int j = 0; j < i.weekList.length; ++j) {
        if (!i.weekList[j]) {
          continue;
        }
        Jiffy day =
            Jiffy.parseFromDateTime(startDay).add(weeks: j, days: i.day - 1);
        String vevent = "BEGIN:VEVENT\n$summary";
        List<String> startTime = time[(i.start - 1) * 2].split(":");
        List<String> stopTime = time[(i.stop - 1) * 2 + 1].split(":");
        vevent +=
            "DTSTART:${day.add(hours: int.parse(startTime[0]), minutes: int.parse(startTime[1])).format(pattern: 'yyyyMMddTHHmmss')}\n";
        vevent +=
            "DTEND:${day.add(hours: int.parse(stopTime[0]), minutes: int.parse(stopTime[1])).format(pattern: 'yyyyMMddTHHmmss')}\n";
        toReturn += "$vevent${description}END:VEVENT\n";
      }
    }
    return "${toReturn}END:VCALENDAR";
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
        events.add(ClassOrgainzedData.fromTimeArrangement(
          i,
          colorList[i.index % colorList.length],
          getClassDetail(timeArrangement.indexOf(i)).name,
        ));
      }
    }

    for (final i in subjects) {
      if (i.startTime == null ||
          i.stopTime == null ||
          i.startTime!.isBefore(Jiffy.parseFromDateTime(startDay))) {
        continue;
      }

      int diff = i.startTime!
          .diff(Jiffy.parseFromDateTime(startDay), unit: Unit.day)
          .toInt();

      if (diff ~/ 7 == weekIndex && diff % 7 + 1 == dayIndex) {
        events.add(ClassOrgainzedData.fromSubject(
          colorList[subjects.indexOf(i) % colorList.length],
          i,
        ));
      }
    }

    for (final i in experiments) {
      int diff = Jiffy.parseFromDateTime(i.time[0])
          .diff(Jiffy.parseFromDateTime(startDay), unit: Unit.day)
          .toInt();

      if (diff ~/ 7 == weekIndex && diff % 7 + 1 == dayIndex) {
        events.add(ClassOrgainzedData.fromExperiment(
          colorList[experiments.indexOf(i) % colorList.length],
          i,
        ));
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
            arrangedEventStart, arrangedEventEnd, startTime, endTime)) {
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

        bool shouldNew = (event.stop - event.start) >=
            (arrangedEventData.stop - arrangedEventData.start);

        final top = startDuration;
        // TODO: check whether it is good.
        final bottom = endDuration;

        final newEvent = ClassOrgainzedData(
          start: top,
          stop: bottom,
          data: [
            ...arrangedEventData.data,
            ...event.data,
          ],
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
