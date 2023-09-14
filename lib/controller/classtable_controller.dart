// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'package:get/get.dart';
import 'package:jiffy/jiffy.dart';
import 'dart:developer' as developer;
import 'package:watermeter/repository/preference.dart' as preference;
import 'package:watermeter/model/xidian_ids/classtable.dart';
import 'package:watermeter/repository/xidian_ids/ehall/classtable_session.dart';

class ClassTableController extends GetxController {
  bool isGet = false;
  String? error;

  // Classtable Data
  ClassTableData classTableData = ClassTableData();

  // The start day of the semester.
  var startDay = DateTime.parse("2022-01-22");

  // A list as an index of the classtable items.
  late List<List<List<List<int>>>> pretendLayout;

  // Mark the current week.
  int currentWeek = 0;

  // Current Information
  DateTime updateTime = DateTime.now();

  // The time index.
  int get timeIndex {
    // Default set to -2 as not in class.
    int index = -2;
    developer.log(
      "Current time is $updateTime, ${Jiffy.parse(time[0], pattern: "hh:mm").format()}",
      name: "ClassTableControllerTimeIndex",
    );

    // Deal with the current time.
    int currentTime = 60 * updateTime.hour + updateTime.minute;

    // Check for all the time.
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

  // The left of the class card, shows the class data about
  // current class, next class or tomorrow's class.
  (ClassDetail?, TimeArrangement?, bool?) get currentData {
    ClassDetail? classToShow;
    TimeArrangement? timeArrangementToShow;
    bool? isNext;

    if (isNotVacation) {
      int currentDataIndex = -1;

      // Deal with the current time.
      int currentTime = 60 * updateTime.hour + updateTime.minute;
      var split = time.first.split(":");
      int beginTime = 60 * int.parse(split[0]) + int.parse(split[1]);
      split = time.last.split(':');
      int endTime = 60 * int.parse(split[0]) + int.parse(split[1]);

      // Eval with: before 8:30, between, after 20:35
      if (currentTime < beginTime) {
        developer.log(
          "Current time is before ${time.first}",
          name: "ClassTableControllerCurrentData",
        );
        isNext = true;
        currentDataIndex =
            pretendLayout[currentWeek][updateTime.weekday - 1][0][0];
      } else if (currentTime > endTime) {
        developer.log(
          "Current time is after ${time.last}",
          name: "ClassTableControllerCurrentData",
        );
        // Actually first -1 to fit the index.
        // But I mean tomorrow, so +1. And -1+1=0
        int weekday = updateTime.weekday;
        int week = currentWeek;

        if (weekday >= 7) {
          weekday = 0;
          week += 1;
        }

        if (week >= classTableData.semesterLength || week < 0) {
          // Get the first class of tomorrow, if have...
          isNext = true;
          currentDataIndex = pretendLayout[week][weekday][0][0];
        }
      } else {
        int index = timeIndex;
        developer.log(
          "Get the current class $index",
          name: "ClassTableControllerCurrentData",
        );
        developer.log(
          "Current time is after ${time[index]} $index",
          name: "ClassTableControllerCurrentData",
        );

        // If in the class, the current class.
        // Else, the previous class.
        currentDataIndex =
            pretendLayout[currentWeek][updateTime.weekday - 1][index ~/ 2][0];
        // In the class
        if (index % 2 == 0) {
          developer.log(
            "In class.",
            name: "ClassTableControllerCurrentData",
          );
          if (currentDataIndex != -1) {
            isNext = false;
          }
        } else {
          // See the next class.
          int nextIndex = pretendLayout[currentWeek][updateTime.weekday - 1]
              [(index + 1) ~/ 2][0];
          developer.log(
            "Not in class, seek the next class index is $nextIndex",
            name: "ClassTableControllerCurrentData",
          );
          // If in supper/lunch
          if ([7, 15].contains(index)) {
            currentDataIndex = nextIndex;
          }
          // If really have class.
          else if (nextIndex != -1) {
            if (currentDataIndex != nextIndex) {
              isNext = true;
            } else {
              isNext = false;
            }
            currentDataIndex = nextIndex;
          }
        }
      }

      developer.log(
        "Final data is $currentDataIndex",
        name: "ClassTableControllerCurrentData",
      );

      // If no class, "have class" and "next class" notice is useless
      if (currentDataIndex == -1) {
        isNext = null;
      } else {
        timeArrangementToShow =
            classTableData.timeArrangement[currentDataIndex];
        classToShow = classTableData.classDetail[timeArrangementToShow.index];
      }
    }
    return (classToShow, timeArrangementToShow, isNext);
  }

  // Today or tomorrow class
  (List<TimeArrangement>, bool) get classSet {
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
      Set<int> classes = {};
      int i = timeIndex ~/ 2 + 1;
      developer.log(
        "currentindex: $i.",
        name: "ClassTableControllerClassSet",
      );

      for (i; i < 10; ++i) {
        classes.addAll(pretendLayout[week][weekday][i]);
      }
      classes.remove(-1);

      /// Parse isTomorrow
      if (classes.isEmpty &&
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

        classes.clear();

        if (week <= classTableData.semesterLength) {
          developer.log(
            "adding ${pretendLayout[week][weekday]}",
            name: "ClassTableControllerClassSet",
          );
          for (i = 0; i < 10; ++i) {
            classes.addAll(pretendLayout[week][weekday][i]);
            developer.log(
              "$classes",
              name: "ClassTableControllerClassSet",
            );
          }
          classes.remove(-1);
          developer.log(
            "$classes",
            name: "ClassTableControllerClassSet",
          );
        }
      }

      return (
        List<TimeArrangement>.generate(
          classes.toList().length,
          (index) => classTableData.timeArrangement[classes.toList()[index]],
        ),
        isTomorrow
      );
    }
  }

  @override
  void onReady() async {
    await updateClassTable();
    update();
  }

  bool get isNotVacation =>
      currentWeek >= 0 && currentWeek < classTableData.semesterLength;

  void updateCurrent() {
    // Get the start day of the semester. Append offset
    startDay = DateTime.parse(classTableData.termStartDay).add(
        Duration(days: 7 * preference.getInt(preference.Preference.swift)));

    // Get the current index.
    int delta =
        Jiffy.now().dayOfYear - Jiffy.parseFromDateTime(startDay).dayOfYear;
    if (delta < 0) delta = -7;
    currentWeek = delta ~/ 7;

    updateTime = DateTime(
      2023,
      9,
      13,
      21,
      00,
      00,
    );

    developer.log(
      "startDay: $startDay, currentWeek: $currentWeek, isNotVacation: $isNotVacation.",
      name: "ClassTableController",
    );
  }

  Future<void> updateClassTable({bool isForce = false}) async {
    isGet = false;
    error = null;
    try {
      classTableData = await ClassTableFile().get(isForce: isForce);

      // Uncomment to see the conflict.
      /*
      classDetail.add(ClassDetail(
        name: "测试连课",
        teacher: "SPRT",
        place: "Flutter",
      ));
      timeArrangement.addAll([
        TimeArrangement(
          index: classDetail.length - 1,
          start: 9,
          stop: 10,
          day: 1,
          weekList: "1111111111111111111111",
        ),
        TimeArrangement(
          index: classDetail.length - 1,
          start: 4,
          stop: 8,
          day: 3,
          weekList: "1111111111111111111111",
        ),
      ]);*/

      // Init the matrix.
      // 1. prepare the structure, a three-deminision array.
      //    for week-day~class array
      pretendLayout = List.generate(
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
