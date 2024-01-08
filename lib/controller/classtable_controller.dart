// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'package:get/get.dart';
import 'package:jiffy/jiffy.dart';
import 'package:watermeter/applet/widget_worker.dart';
import 'dart:developer' as developer;
import 'package:watermeter/repository/preference.dart' as preference;
import 'package:watermeter/model/xidian_ids/classtable.dart';
import 'package:watermeter/repository/xidian_ids/classtable_session.dart';

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
    (week) =>
        List.generate(7, (day) => List.generate(10, (classes) => <int>[])),
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
    developer.log(
      "Current time is $updateTime, ${Jiffy.parse(time[0], pattern: "hh:mm").format()}",
      name: "ClassTableControllerTimeIndex",
    );

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

    developer.log(
      "Current index is $index, which is ${time[index < 0 ? 0 : index]}",
      name: "ClassTableControllerTimeIndex",
    );

    return index;
  }

  /// Get the class data about current class.
  (ClassDetail, TimeArrangement)? get currentData {
    if (!isNotVacation) {
      return null;
    }

    int index = timeIndex;
    if (index < 0 || index >= time.length - 1) {
      developer.log(
        "Current time is out of range. The index is $index",
        name: "ClassTableControllerCurrentData",
      );
      return null;
    }

    developer.log(
      "Get the current class $index",
      name: "ClassTableControllerCurrentData",
    );
    developer.log(
      "Current time is after ${time[index]} $index",
      name: "ClassTableControllerCurrentData",
    );

    int currentDataIndex = -1;
    try {
      if (pretendLayout[currentWeek][updateTime.weekday - 1][index ~/ 2]
          .isNotEmpty) {
        currentDataIndex =
            pretendLayout[currentWeek][updateTime.weekday - 1][index ~/ 2][0];
      }
    } catch (e, s) {
      developer.log(
        "No class table data, $e",
        name: "ClassTableControllerCurrentData",
      );
      developer.log(
        "The stacktrace is $s",
        name: "ClassTableControllerCurrentData",
      );
    }

    // No class
    if (currentDataIndex == -1) {
      developer.log(
        "No class",
        name: "ClassTableControllerCurrentData",
      );
      return null;
    }

    // Check the exact time
    TimeArrangement arrangement =
        classTableData.timeArrangement[currentDataIndex];
    if (index < ((arrangement.start - 1) * 2) ||
        index >= ((arrangement.stop - 1) * 2 + 1)) {
      developer.log(
        "Current class has not started or has ended. ${time[index]} not in [${time[(arrangement.start - 1) * 2]}, ${time[(arrangement.stop - 1) * 2 + 1]})",
        name: "ClassTableControllerCurrentData",
      );
      return null;
    }

    developer.log(
      "Final data is $currentDataIndex",
      name: "ClassTableControllerCurrentData",
    );

    return (classTableData.classDetail[arrangement.index], arrangement);
  }

  /// Get next class arrangements today or tomorrow
  (List<TimeArrangement>, bool) get nextClassArrangements {
    int weekday = updateTime.weekday - 1;
    int week = currentWeek;
    bool isTomorrow = false;

    developer.log(
      "weekday: $weekday, currentWeek: $currentWeek, isTomorrow: $isTomorrow.",
      name: "ClassTableControllerClassSet",
    );
    developer.log(
      "${updateTime.hour}:${updateTime.minute}",
      name: "ClassTableControllerClassSet",
    );

    if (week >= classTableData.semesterLength || week < 0) {
      return ([], isTomorrow);
    } else {
      Set<int> classArrangementIndices = {};
      int i = timeIndex ~/ 2 + 1;
      developer.log(
        "currentindex: $i.",
        name: "ClassTableControllerClassSet",
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
        developer.log(
          "Need tomorrow data.",
          name: "ClassTableControllerClassSet",
        );

        weekday += 1;
        isTomorrow = true;

        if (weekday >= 7) {
          weekday = 0;
          week += 1;
        }

        developer.log(
          "weekday: $weekday, currentWeek: $currentWeek, isTomorrow: $isTomorrow.",
          name: "ClassTableControllerClassSet",
        );

        classArrangementIndices.clear();

        if (week <= classTableData.semesterLength) {
          developer.log(
            "adding  ${pretendLayout[week][weekday]}",
            name: "ClassTableControllerClassSet",
          );
          for (i = 0; i < 10; ++i) {
            classArrangementIndices.addAll(pretendLayout[week][weekday][i]);

            developer.log(
              "now tomorrow: $classArrangementIndices",
              name: "ClassTableControllerClassSet",
            );
          }
          classArrangementIndices.remove(-1);

          developer.log(
            "$classArrangementIndices",
            name: "ClassTableControllerClassSet",
          );
        }
      }

      return (
        classArrangementIndices
            .map((idx) => classTableData.timeArrangement[idx])
            .toList(),
        isTomorrow
      );
    }
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

    developer.log(
      "startDay: $startDay, currentWeek: $currentWeek, isNotVacation: $isNotVacation.",
      name: "ClassTableController",
    );

    updateClasstableInfo();
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
            if (i.weekList[week] == "1" && i.day == day + 1) {
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

      isGet = true;
      updateCurrent();
      update();
    } catch (e, s) {
      error = e.toString() + s.toString();
      rethrow;
    }
  }
}
