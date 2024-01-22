// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'dart:convert';
import 'dart:io';

import 'package:home_widget/home_widget.dart';
import 'package:watermeter/bridge/save_to_groupid.g.dart';
import 'package:watermeter/repository/logger.dart';
import 'package:get/get.dart';
import 'package:jiffy/jiffy.dart';
import 'package:watermeter/model/home_arrangement.dart';
import 'package:watermeter/repository/preference.dart' as preference;
import 'package:watermeter/model/xidian_ids/classtable.dart';
import 'package:watermeter/repository/xidian_ids/ehall_classtable_session.dart';

enum ClassTableState {
  fetching,
  fetched,
  error,
  none,
}

class ClassTableController extends GetxController {
  ClassTableState state = ClassTableState.none;
  String? error;

  // Classtable Data
  ClassTableData classTableData = ClassTableData();

  // The start day of the semester.
  DateTime startDay = DateTime.parse("2022-01-22");

  // Mark the current week.
  int currentWeek = 0;

  // Current Information
  Jiffy updateTime = Jiffy.now();

  // Get ClassDetail name info
  ClassDetail getClassDetail(TimeArrangement timeArrangementIndex) =>
      classTableData.getClassDetail(timeArrangementIndex);

  // Get all user-add classes
  UserDefinedClassData get userDefinedClassData =>
      ClassTableFile().getUserDefinedData().$1;

  /// The time index.
  /// - `-1`: means the time is before 8:30.
  /// - `time.length-1`: means the time is after 20:35.
  /// - otherwise, means the time is in range [`time[timeIndex]`, `time[timeIndex+1]`).
  int get timeIndex {
    // Deal with the current time.
    int currentTime = 60 * updateTime.hour + updateTime.minute;

    // Check for all the time.
    int index = time.length - 1;
    for (int i = 0; i < time.length; ++i) {
      var split = time[i].split(":");
      int toDeal = 60 * int.parse(split[0]) + int.parse(split[1]);

      if (currentTime < toDeal) {
        // The time is after the time[i-1]
        index = i - 1;
        break;
      }
    }
    return index;
  }

  bool get isTomorrow =>
      updateTime.hour * 60 + updateTime.minute > 20 * 60 + 35;

  /// Get current class. (bool isNext, HomeArrangement arrangement)
  (bool, HomeArrangement?) get currentData {
    if (!isNotVacation) return (false, null);
    for (var i in classTableData.timeArrangement) {
      if (i.weekList.length > currentWeek &&
          i.weekList[currentWeek] &&
          i.day == updateTime.dateTime.weekday) {
        HomeArrangement toReturn = HomeArrangement(
          name: getClassDetail(i).name,
          teacher: i.teacher ?? "未知",
          place: i.classroom ?? "未知",
          startTimeStr: Jiffy.parseFromDateTime(DateTime(
            updateTime.year,
            updateTime.month,
            updateTime.date,
            int.parse(time[(i.start - 1) * 2].split(':')[0]),
            int.parse(time[(i.start - 1) * 2].split(':')[1]),
          )).format(pattern: HomeArrangement.format),
          endTimeStr: Jiffy.parseFromDateTime(DateTime(
            updateTime.year,
            updateTime.month,
            updateTime.date,
            int.parse(time[(i.stop - 1) * 2 + 1].split(':')[0]),
            int.parse(time[(i.stop - 1) * 2 + 1].split(':')[1]),
          )).format(pattern: HomeArrangement.format),
        );
        if (updateTime.isBetween(
          Jiffy.parseFromDateTime(toReturn.startTime),
          Jiffy.parseFromDateTime(toReturn.endTime),
        )) {
          return (false, toReturn);
        }
        if (List<int>.generate(
          30,
          (index) => index,
        ).contains(
          Jiffy.parseFromDateTime(toReturn.startTime).diff(
            updateTime,
            unit: Unit.minute,
          ),
        )) {
          return (true, toReturn);
        }
      }
    }
    return (false, null);
  }

  /// Get today's arrangement in classtable
  List<HomeArrangement> get todayArrangement {
    Set<HomeArrangement> todayArrangement = {};
    if (isNotVacation) {
      for (var i in classTableData.timeArrangement) {
        if (i.weekList.length > currentWeek &&
            i.weekList[currentWeek] &&
            i.day == updateTime.dateTime.weekday) {
          /// If passed, do no show.
          Jiffy start = Jiffy.parseFromDateTime(DateTime(
            updateTime.year,
            updateTime.month,
            updateTime.date,
            int.parse(time[(i.start - 1) * 2].split(':')[0]),
            int.parse(time[(i.start - 1) * 2].split(':')[1]),
          ));
          Jiffy end = Jiffy.parseFromDateTime(DateTime(
            updateTime.year,
            updateTime.month,
            updateTime.date,
            int.parse(time[(i.stop - 1) * 2 + 1].split(':')[0]),
            int.parse(time[(i.stop - 1) * 2 + 1].split(':')[1]),
          ));
          if (updateTime.isBefore(end)) {
            todayArrangement.add(HomeArrangement(
              name: getClassDetail(i).name,
              teacher: i.teacher ?? "未知",
              place: i.classroom ?? "未知",
              startTimeStr: start.format(pattern: HomeArrangement.format),
              endTimeStr: end.format(pattern: HomeArrangement.format),
            ));
          }
        }
      }
    }
    var toReturn = todayArrangement.toList();

    toReturn.sort((a, b) => Jiffy.parseFromDateTime(a.startTime)
        .diff(Jiffy.parseFromDateTime(b.startTime))
        .toInt());

    return toReturn;
  }

  /// Tomorrow Arrangement
  List<HomeArrangement> get tomorrowArrangement {
    Set<HomeArrangement> tomorrowArrangement = {};
    int tomorrowWeekIndex = currentWeek;
    int tomorrowDayIndex = updateTime.dateTime.weekday + 1;
    if (tomorrowDayIndex > 7) {
      tomorrowDayIndex = 1;
      tomorrowWeekIndex += 1;
    }
    if (tomorrowWeekIndex >= 0 &&
        tomorrowWeekIndex < classTableData.semesterLength) {
      for (var i in classTableData.timeArrangement) {
        if (i.weekList.length > tomorrowWeekIndex &&
            i.weekList[tomorrowWeekIndex] &&
            i.day == tomorrowDayIndex) {
          tomorrowArrangement.add(HomeArrangement(
            name: getClassDetail(i).name,
            teacher: i.teacher ?? "未知",
            place: i.classroom ?? "未知",
            startTimeStr: Jiffy.parseFromDateTime(DateTime(
              updateTime.year,
              updateTime.month,
              updateTime.date,
              int.parse(time[(i.start - 1) * 2].split(':')[0]),
              int.parse(time[(i.start - 1) * 2].split(':')[1]),
            )).format(pattern: HomeArrangement.format),
            endTimeStr: Jiffy.parseFromDateTime(DateTime(
              updateTime.year,
              updateTime.month,
              updateTime.date,
              int.parse(time[(i.stop - 1) * 2 + 1].split(':')[0]),
              int.parse(time[(i.stop - 1) * 2 + 1].split(':')[1]),
            )).format(pattern: HomeArrangement.format),
          ));
        }
      }
    }
    var toReturn = tomorrowArrangement.toList();

    toReturn.sort((a, b) => Jiffy.parseFromDateTime(a.startTime)
        .diff(Jiffy.parseFromDateTime(b.startTime))
        .toInt());

    return toReturn;
  }

  bool get isNotVacation =>
      currentWeek >= 0 && currentWeek < classTableData.semesterLength;

  @override
  void onReady() async {
    await updateClassTable();
    update();
  }

  Future<void> addUserDefinedClass(
    ClassDetail classDetail,
    TimeArrangement timeArrangement,
  ) async {
    ClassTableFile().saveUserDefinedData(classDetail, timeArrangement);
    await updateClassTable(isForce: false);
  }

  void updateCurrent() {
    if (state != ClassTableState.fetched) return;

    updateTime = Jiffy.now();

    // Get the current index.
    int delta = updateTime
        .diff(Jiffy.parseFromDateTime(startDay), unit: Unit.day)
        .toInt();
    if (delta < 0) delta = -7;
    currentWeek = delta ~/ 7;

    log.i(
      "[ClassTableController][addUserDefinedClass] "
      "startDay: $startDay, currentWeek: $currentWeek, isNotVacation: $isNotVacation.",
    );
  }

  Future<void> updateClassTable({bool isForce = false}) async {
    state = ClassTableState.fetching;
    error = null;
    try {
      classTableData = await ClassTableFile().get(isForce: isForce);

      /// Get the start day of the semester. Append offset
      startDay = DateTime.parse(classTableData.termStartDay).add(
          Duration(days: 7 * preference.getInt(preference.Preference.swift)));

      /// If ios, store the file to groupid public place
      /// in order to refresh the widget...
      if (Platform.isIOS) {
        final api = SaveToGroupIdSwiftApi();
        try {
          bool data = await api.saveToGroupId(FileToGroupID(
            appid: preference.appId,
            fileName: "ClassTable.json",
            data: jsonEncode(classTableData.toJson()),
          ));
          log.i(
            "[ClassTableController][updateClassTable] "
            "ios ClassTable.json save to public place status: $data.",
          );
        } catch (e, s) {
          log.w(
            "[ClassTableController][updateClassTable] "
            "ios ClassTable.json save to public place failed with error: ",
            error: e,
            stackTrace: s,
          );
        }
        try {
          bool data = await api.saveToGroupId(FileToGroupID(
            appid: preference.appId,
            fileName: "WeekSwift.txt",
            data: preference.getInt(preference.Preference.swift).toString(),
          ));
          log.i(
            "[ClassTableController][updateClassTable] "
            "ios WeekSwift.txt save to public place status: $data.",
          );
        } catch (e, s) {
          log.w(
            "[ClassTableController][updateClassTable] "
            "ios WeekSwift.txt save to public place failed with error: ",
            error: e,
            stackTrace: s,
          );
        }
        HomeWidget.updateWidget(iOSName: "ClasstableWidget");
      }

      state = ClassTableState.fetched;
      updateCurrent();
      update();
    } catch (e, s) {
      log.w(
        "[ClassTableController][updateClassTable] "
        "updateClassTable failed",
        error: e,
        stackTrace: s,
      );
      state = ClassTableState.error;
      error = e.toString();
    }
  }
}
