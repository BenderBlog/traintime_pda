// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0 OR Apache-2.0

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jiffy/jiffy.dart';
import 'package:watermeter/controller/classtable_controller.dart';
import 'package:watermeter/model/xidian_ids/classtable.dart';
import 'package:watermeter/repository/preference.dart' as preference;

/// The controllers and shared datas of the class table.
class ClassTableState extends InheritedWidget {
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

  // The class change data.
  List<ClassChange> get classChange =>
      classTableController.classTableData.classChanges;

  /// Multiplex array which means List[week][day][classindex][classes]
  ///   * week: The week index of the week.
  ///   * day: days in the week
  ///   * classindex: indicate the range of the time when we attending class, normally 0-9
  ///   * classes: the classes in this time, maybe conflicts occurs.
  RxList<List<List<List<int>>>> get pretendLayout =>
      classTableController.pretendLayout;

  /// The day the semester start, used to calculate the first day of the week.
  DateTime get startDay =>
      Jiffy.parse(classTableController.classTableData.termStartDay).dateTime;

  /// The currentWeek.
  int get currentWeek => classTableController.currentWeek;

  /// The changeable data of the state.
  late final ClassTableWidgetState controllers;

  /// Get class detail by prividing index of timearrangement
  ClassDetail getClassDetail(int index) =>
      classTableController.classTableData.getClassDetail(index);

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

  ClassTableState({
    super.key,
    required super.child,
    required BuildContext context,
  }) {
    late int toShowChoiceWeek;
    if (currentWeek < 0) {
      toShowChoiceWeek = 0;
    } else if (currentWeek >= semesterLength) {
      toShowChoiceWeek = semesterLength - 1;
    } else {
      toShowChoiceWeek = currentWeek;
    }
    controllers = ClassTableWidgetState(
      chosenWeek: toShowChoiceWeek,
    );
  }

  static ClassTableState? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ClassTableState>();
  }

  @override
  bool updateShouldNotify(covariant ClassTableState oldWidget) {
    return controllers.chosenWeek != oldWidget.controllers.chosenWeek;
  }
}

/// The changeable data of the class table state.
class ClassTableWidgetState extends ChangeNotifier {
  /// Current showing week.
  int chosenWeek;

  ClassTableWidgetState({
    required this.chosenWeek,
  });
}
