// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:jiffy/jiffy.dart';
import 'dart:developer' as developer;
import 'package:watermeter/repository/preference.dart' as preference;
import 'package:watermeter/model/xidian_ids/classtable.dart';
import 'package:watermeter/repository/xidian_ids/ehall/classtable_session.dart';

enum Source {
  school,
  experiment,
  examation,
  userdefined,
  empty,
}

class ClassTableController extends GetxController {
  bool isGet = false;
  String? error;

  // Classtable Data
  ClassTableData classTableData = ClassTableData();

  // TODO: Add experiment and exam info here.
  ClassTableData userDefinedData = ClassTableData();

  // The start day of the semester.
  var startDay = DateTime.parse("2022-01-22");

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

  /// Fetch (ClassDetail, TimeArrangement) with (Source, index)
  /// index stand for time arrangement index
  (ClassDetail, TimeArrangement) fetchClassData((Source, int) data) {
    print(data);
    late ClassDetail classDetail;
    late TimeArrangement timeArrangement;

    switch (data.$1) {
      case Source.school:
        timeArrangement = classTableData.timeArrangement[data.$2];
        classDetail = classTableData.classDetail[timeArrangement.index];
        break;
      case Source.userdefined:
        timeArrangement = userDefinedData.timeArrangement[data.$2];
        classDetail = userDefinedData.classDetail[timeArrangement.index];
        break;
      case Source.examation:
      case Source.experiment:
        break;
      case Source.empty:
      default:
        throw NotImplementedException();
    }

    return (classDetail, timeArrangement);
  }

  // A list as an index of the classtable items.
  List<List<List<List<(Source, int)>>>> get pretendLayout {
    // Init the matrix.
    // 1. prepare the structure, a three-deminision array.
    //    for week-day~class array
    var pretendLayout = List<List<List<List<(Source, int)>>>>.generate(
      classTableData.semesterLength,
      (week) => List.generate(7, (day) => List.generate(10, (classes) => [])),
    );

    // Since we are going to write lots of ClassTableData here,
    // we write it as a independent stuff.
    void writeToPretendLayout(ClassTableData data, Source source) {
      // 2. init each week's array
      for (int week = 0; week < data.semesterLength; ++week) {
        for (int day = 0; day < 7; ++day) {
          // 2.a. Choice the class in this day.
          List<TimeArrangement> thisDay = [];
          for (var i in data.timeArrangement) {
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
                  .add((source, classTableData.timeArrangement.indexOf(i)));
            }
          }

          // 2.d. Deal with the empty space.
          for (var i in pretendLayout[week][day]) {
            if (i.isEmpty) {
              i.add((Source.empty, -1));
            }
          }
        }
      }
    }

    writeToPretendLayout(classTableData, Source.school);

    return pretendLayout;
  }

  /// [currentData] shows the class data about current, next or tomorrow's class.
  /// First a list of the classes, then mark isNext with a bool.
  (List<(ClassDetail, TimeArrangement)>, bool?) get currentData {
    List<(ClassDetail, TimeArrangement)> classToShow = [];
    bool? isNext;

    if (isNotVacation) {
      List<(Source, int)> currentDataIndex = [];

      /// Deal with the current time.
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
        currentDataIndex
            .addAll(pretendLayout[currentWeek][updateTime.weekday - 1][0]);
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
          currentDataIndex.addAll(pretendLayout[week][weekday][0]);
        }
      } else {
        // Eval between 8:30 and 20:35
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
        currentDataIndex.addAll(
            pretendLayout[currentWeek][updateTime.weekday - 1][index ~/ 2]);
        currentDataIndex.remove((Source.empty, -1));
        if (index % 2 == 0) {
          // In the class
          developer.log(
            "In class.",
            name: "ClassTableControllerCurrentData",
          );
          bool isEmpty = currentDataIndex.remove((Source.empty, -1));
          if (isEmpty) {
            isNext = false;
          }
        } else {
          // See the next class.
          var nextIndex = List<(Source, int)>.from(pretendLayout[currentWeek]
              [updateTime.weekday - 1][(index + 1) ~/ 2]);
          bool isEmpty = nextIndex.remove((Source.empty, -1));
          developer.log(
            "Not in class, seek the next class index is $nextIndex",
            name: "ClassTableControllerCurrentData",
          );
          // If in supper/lunch
          if ([7, 15].contains(index)) {
            currentDataIndex.addAll(nextIndex);
          }
          // If really have class.
          else if (!isEmpty) {
            isNext = listEquals(currentDataIndex, nextIndex) ? true : false;
            currentDataIndex = nextIndex;
          }
        }
      }

      developer.log(
        "Final data is $currentDataIndex",
        name: "ClassTableControllerCurrentData",
      );

      // If no class, "have class" and "next class" notice is useless
      if (currentDataIndex.isEmpty) {
        isNext = null;
      } else {
        for (var i in currentDataIndex) {
          classToShow.add(fetchClassData(i));
        }
      }
    }

    return (classToShow, isNext);
  }

  // Today or tomorrow class
  (List<(ClassDetail, TimeArrangement)>, bool) get classSet {
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
      Set<(Source, int)> classes = {};
      int i = timeIndex ~/ 2 + 1;
      developer.log(
        "currentindex: $i.",
        name: "ClassTableControllerClassSet",
      );

      for (i; i < 10; ++i) {
        classes.addAll(pretendLayout[week][weekday][i]);
      }
      classes.remove((Source.empty, -1));

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
          classes.remove((Source.empty, -1));
          developer.log(
            "$classes",
            name: "ClassTableControllerClassSet",
          );
        }
      }

      return (
        List<(ClassDetail, TimeArrangement)>.generate(
          classes.toList().length,
          (index) => fetchClassData(
            classes.toList()[index],
          ),
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

    updateTime = DateTime.now();

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

      isGet = true;
      updateCurrent();
      update();
    } catch (e, s) {
      error = e.toString() + s.toString();
      rethrow;
    }
  }
}

class NotImplementedException implements Exception {}
