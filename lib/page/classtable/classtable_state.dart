// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0 OR Apache-2.0

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jiffy/jiffy.dart';
import 'package:watermeter/controller/classtable_controller.dart';
import 'package:watermeter/model/xidian_ids/classtable.dart';
import 'package:watermeter/repository/preference.dart' as preference;

/// Use a inheritedWidget to share the ClassTableWidgetState
class ClassTableState extends InheritedWidget {
  final ClassTableWidgetState controllers;

  const ClassTableState({
    super.key,
    required super.child,
    required BuildContext context,
    required this.controllers,
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
  int get currentWeek => classTableController.currentWeek;

  ///*****************************///
  /// Following are dynamic data. ///
  /// ****************************///

  /// Multiplex array which means List[week][day][classindex][classes]
  ///   * week: The week index of the week.
  ///   * day: days in the week
  ///   * classindex: indicate the range of the time when we attending class, normally 0-9
  ///   * classes: the classes in this time, maybe conflicts occurs.
  late List<List<List<List<int>>>> pretendLayout;

  /// Update the pretendLayout when add/del user defined class.
  void updatePretendLayout() {
    /// Init the matrix.
    /// 1. prepare the structure, a three-deminision array.
    ///    for week-day~class array
    List<List<List<List<int>>>> toReturn = List.generate(
      semesterLength,
      (week) => List.generate(7, (day) => List.generate(10, (classes) => [])),
    );

    /// 2. init each week's array
    for (int week = 0; week < semesterLength; ++week) {
      for (int day = 0; day < 7; ++day) {
        // 2.a. Choice the class in this day.
        List<TimeArrangement> thisDay = [];
        for (var i in timeArrangement) {
          // If the class has ended, skip.
          if (i.weekList.length < week + 1) {
            continue;
          }
          if (i.weekList[week] && i.day == day + 1) {
            thisDay.add(i);
          }
        }

        /// 2.b. The longest class should be solved first.
        thisDay.sort((a, b) => b.step.compareTo(a.step));

        /// 2.c Arrange the layout. Solve the conflex.
        for (var i in thisDay) {
          for (int j = i.start - 1; j <= i.stop - 1; ++j) {
            toReturn[week][day][j].add(timeArrangement.indexOf(i));
          }
        }

        /// 2.d. Deal with the empty space.
        for (var i in toReturn[week][day]) {
          if (i.isEmpty) i.add(-1);
        }
      }
    }
    pretendLayout = toReturn;
    notifyListeners();
  }

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

  /// bridge function to add/del user defined class
  Future<void> addUserDefinedClass(
    ClassDetail classDetail,
    TimeArrangement timeArrangement,
  ) async {
    await classTableController
        .addUserDefinedClass(classDetail, timeArrangement)
        .then((value) => updatePretendLayout());
  }

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

  ClassTableWidgetState() {
    if (currentWeek < 0) {
      _chosenWeek = 0;
    } else if (currentWeek >= semesterLength) {
      _chosenWeek = semesterLength - 1;
    } else {
      _chosenWeek = currentWeek;
    }
    updatePretendLayout();
  }
}
