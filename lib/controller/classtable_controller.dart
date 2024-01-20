// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'dart:convert';
import 'dart:io';

import 'package:watermeter/bridge/save_to_groupid.g.dart';
import 'package:watermeter/repository/logger.dart';
import 'package:get/get.dart';
import 'package:jiffy/jiffy.dart';
import 'package:watermeter/model/home_arrangement.dart';
import 'package:watermeter/repository/preference.dart' as preference;
import 'package:watermeter/model/xidian_ids/classtable.dart';
import 'package:watermeter/repository/xidian_ids/ehall_classtable_session.dart';

class ClassTableController extends GetxController {
  bool isGet = false;
  String? error;

  // Classtable Data
  ClassTableData classTableData = ClassTableData();

  // The start day of the semester.
  var startDay = DateTime.parse("2022-01-22");

  // A list as an index of the classtable items.
  RxList<List<List<List<int>>>> pretendLayout = List.generate(
    1,
    (week) => List.generate(
      7,
      (day) => List.generate(10, (classes) => <int>[]),
    ),
  ).obs;

  // Mark the current week.
  int currentWeek = 0;

  // Current Information
  DateTime updateTime = DateTime.now();

  // Get ClassDetail name info
  ClassDetail getClassDetail(int timeArrangementIndex) =>
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

  /// Get the class data about current class.
  (ClassDetail, TimeArrangement)? get currentData {
    if (!isNotVacation) {
      return null;
    }

    int index = timeIndex;
    if (index < 0 || index >= time.length - 1) {
      log.i(
        "[ClassTableController][CurrentData] "
        "Current time is out of range. The index is $index. Now exit.",
      );
      return null;
    }

    log.i(
      "[ClassTableController][CurrentData] "
      "Get the current class $index, current time is after ${time[index]}.",
    );

    int currentDataIndex = -1;
    try {
      if (pretendLayout[currentWeek][updateTime.weekday - 1][index ~/ 2]
          .isNotEmpty) {
        currentDataIndex =
            pretendLayout[currentWeek][updateTime.weekday - 1][index ~/ 2][0];
      }
    } catch (e, s) {
      log.i(
        "[ClassTableController][CurrentData] "
        "No class table data, error is: \n$e\nStacktrace is:\n$s.",
      );
    }

    // No class
    if (currentDataIndex == -1) {
      log.i(
        "[ClassTableController][CurrentData] "
        "No class at the monent.",
      );
      return null;
    }

    // Check the exact time
    TimeArrangement arrangement =
        classTableData.timeArrangement[currentDataIndex];
    if (index < ((arrangement.start - 1) * 2) ||
        index >= ((arrangement.stop - 1) * 2 + 1)) {
      log.i(
        "[ClassTableController][CurrentData] "
        "Current class has not started or has ended. "
        "${time[index]} not in [${time[(arrangement.start - 1) * 2]},"
        " ${time[(arrangement.stop - 1) * 2 + 1]}).",
      );
      return null;
    }

    log.i(
      "[ClassTableController][CurrentData] "
      "Final data is $currentDataIndex.",
    );

    return (
      classTableData.getClassDetail(currentDataIndex),
      arrangement,
    );
  }

  /// Get next class arrangements today or tomorrow
  (List<int>, bool) get nextClassArrangements {
    int weekday = updateTime.weekday - 1;
    int week = currentWeek;
    bool isTomorrow = false;

    log.i(
      "[ClassTableController][ClassSet] "
      "weekday: $weekday, currentWeek: $currentWeek,"
      " isTomorrow: $isTomorrow,"
      " ${updateTime.hour}:${updateTime.minute}.",
    );

    if (week >= classTableData.semesterLength || week < 0) {
      return ([], isTomorrow);
    } else {
      Set<int> classArrangementIndices = {};
      int i = timeIndex ~/ 2 + 1;
      log.i(
        "[ClassTableController][ClassSet] "
        "currentTimeIndex: $i, ${time[i]}",
      );

      for (i; i < 10; ++i) {
        classArrangementIndices.addAll(pretendLayout[week][weekday][i]);
      }

      classArrangementIndices.remove(-1);

      // Remove the current class
      (ClassDetail, TimeArrangement)? currentClass = currentData;
      if (currentClass != null) {
        int idx = classTableData.timeArrangement.indexOf(currentClass.$2);
        classArrangementIndices.remove(idx);
      }

      // Parse isTomorrow
      if (classArrangementIndices.isEmpty &&
              updateTime.hour * 60 + updateTime.minute >= 19 * 60 ||
          updateTime.hour * 60 + updateTime.minute >= 20 * 60 + 35) {
        log.i(
          "[ClassTableController][ClassSet] Need tomorrow data.",
        );

        weekday += 1;
        isTomorrow = true;

        if (weekday >= 7) {
          weekday = 0;
          week += 1;
        }

        log.i(
          "[ClassTableController][ClassSet] "
          "weekday: $weekday, currentWeek: $currentWeek, isTomorrow: $isTomorrow.",
        );

        classArrangementIndices.clear();

        if (week <= classTableData.semesterLength) {
          log.i(
            "[ClassTableController][ClassSet] "
            "Adding ${pretendLayout[week][weekday]}.",
          );
          for (i = 0; i < 10; ++i) {
            classArrangementIndices.addAll(pretendLayout[week][weekday][i]);
          }
          classArrangementIndices.remove(-1);
        }
        log.i(
          "[ClassTableController][ClassSet] "
          "Tomorrow classArrangementIndices $classArrangementIndices.",
        );
      }

      return (classArrangementIndices.toList(), isTomorrow);
    }
  }

  /// Homearrangement get today's data...
  (List<HomeArrangement>, List<HomeArrangement>) get homeArrangementData {
    Set<HomeArrangement> todayData = {};
    Set<HomeArrangement> tomorrowData = {};
    int currentWeekIndex = currentWeek;
    int currentDayIndex = updateTime.weekday;
    if (currentWeekIndex >= 0 &&
        currentWeekIndex < classTableData.semesterLength) {
      for (var i in classTableData.timeArrangement) {
        if (i.weekList.length > currentWeekIndex &&
            i.weekList[currentWeekIndex] &&
            i.day == currentDayIndex) {
          todayData.add(HomeArrangement(
            name: getClassDetail(i.index).name,
            teacher: i.teacher ?? "未知",
            place: i.classroom ?? "未知",
            startTimeStr: Jiffy.parseFromDateTime(DateTime(
              updateTime.year,
              updateTime.month,
              updateTime.day,
              int.parse(time[(i.start - 1) * 2].split(':')[0]),
              int.parse(time[(i.start - 1) * 2].split(':')[1]),
            )).format(pattern: HomeArrangement.format),
            endTimeStr: Jiffy.parseFromDateTime(DateTime(
              updateTime.year,
              updateTime.month,
              updateTime.day,
              int.parse(time[(i.stop - 1) * 2 + 1].split(':')[0]),
              int.parse(time[(i.stop - 1) * 2 + 1].split(':')[1]),
            )).format(pattern: HomeArrangement.format),
          ));
        }
      }
    }
    currentDayIndex += 1;
    if (currentDayIndex > 7) {
      currentDayIndex = 1;
      currentWeekIndex += 1;
    }
    if (currentWeekIndex >= 0 &&
        currentWeekIndex < classTableData.semesterLength) {
      for (var i in classTableData.timeArrangement) {
        if (i.weekList.length > currentWeekIndex &&
            i.weekList[currentWeekIndex] &&
            i.day == currentDayIndex) {
          tomorrowData.add(HomeArrangement(
            name: getClassDetail(i.index).name,
            teacher: i.teacher ?? "未知",
            place: i.classroom ?? "未知",
            startTimeStr: Jiffy.parseFromDateTime(DateTime(
              updateTime.year,
              updateTime.month,
              updateTime.day,
              int.parse(time[(i.start - 1) * 2].split(':')[0]),
              int.parse(time[(i.start - 1) * 2].split(':')[1]),
            )).format(pattern: HomeArrangement.format),
            endTimeStr: Jiffy.parseFromDateTime(DateTime(
              updateTime.year,
              updateTime.month,
              updateTime.day,
              int.parse(time[(i.stop - 1) * 2 + 1].split(':')[0]),
              int.parse(time[(i.stop - 1) * 2 + 1].split(':')[1]),
            )).format(pattern: HomeArrangement.format),
          ));
        }
      }
    }
    return (todayData.toList(), tomorrowData.toList());
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
    if (!isGet) return;

    // Get the start day of the semester. Append offset
    startDay = DateTime.parse(classTableData.termStartDay).add(
        Duration(days: 7 * preference.getInt(preference.Preference.swift)));

    log.i(
      "[ClassTableController][addUserDefinedClass] "
      "startDay is $startDay with offset ${preference.getInt(preference.Preference.swift)}.",
    );

    updateTime = DateTime.now();

    // Get the current index.
    // A day = 1000 milliseconds as one second
    // A hour contains 3600 seconds = 60 * 60.
    // A day contains 24 * 3600 seconds
    // emmm
    int delta = (Jiffy.parseFromDateTime(updateTime).millisecondsSinceEpoch -
            Jiffy.parseFromDateTime(startDay).millisecondsSinceEpoch) ~/
        86400000;
    if (delta < 0) delta = -7;
    currentWeek = delta ~/ 7;

    log.i(
      "[ClassTableController][addUserDefinedClass] "
      "startDay: $startDay, currentWeek: $currentWeek, isNotVacation: $isNotVacation.",
    );
  }

  Future<void> updateClassTable({bool isForce = false}) async {
    isGet = false;
    error = null;
    try {
      classTableData = await ClassTableFile().get(isForce: isForce);

      // Init the matrix.
      // 1. prepare the structure, a three-deminision array.
      //    for week-day~class array
      pretendLayout.value = List.generate(
        classTableData.semesterLength,
        (week) => List.generate(7, (day) => List.generate(10, (classes) => [])),
      );

      // 2. init each week's array
      for (int week = 0; week < classTableData.semesterLength; ++week) {
        for (int day = 0; day < 7; ++day) {
          // 2.a. Choice the class in this day.
          List<TimeArrangement> thisDay = [];
          for (var i in classTableData.timeArrangement) {
            // If the class has ended, skip.
            if (i.weekList.length < week + 1) {
              continue;
            }
            if (i.weekList[week] && i.day == day + 1) {
              thisDay.add(i);
            }
          }

          // 2.b. The longest class should be solved first.
          thisDay.sort((a, b) => b.step.compareTo(a.step));

          // 2.c Arrange the layout. Solve the conflex.
          for (var i in thisDay) {
            for (int j = i.start - 1; j <= i.stop - 1; ++j) {
              pretendLayout[week][day][j]
                  .add(classTableData.timeArrangement.indexOf(i));
            }
          }

          // 2.d. Deal with the empty space.
          for (var i in pretendLayout[week][day]) {
            if (i.isEmpty) {
              i.add(-1);
            }
          }
        }
      }
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
      }

      isGet = true;
      updateCurrent();
      update();
    } catch (e, s) {
      log.w(
        "[ClassTableController][updateClassTable] "
        "updateClassTable failed",
        error: e,
        stackTrace: s,
      );
      //rethrow;
    }
  }
}
