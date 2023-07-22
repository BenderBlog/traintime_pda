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
  ClassDetail? classToShow;
  TimeArrangement? timeArrangementToShow;
  bool? isNext;

  @override
  void onReady() async {
    await updateClassTable();
    update();
  }

  bool get isNotVacation =>
      currentWeek >= 0 && currentWeek < classTableData.semesterLength;

  void updateCurrent() {
    // Get the current time.
    if (isNotVacation) {
      developer.log("Get the current class", name: "ClassTableController");
      DateTime now = DateTime.now();
      if ((now.hour >= 8 && now.hour < 20) ||
          (now.hour == 20 && now.minute < 35)) {
        // Check the index.
        int index = -1;
        developer.log(
          "Current time is $now",
          name: "ClassTableController",
        );
        for (int i = 0; i < time.length; ++i) {
          var split = time[i].split(":");

          int toDeal = 60 * int.parse(split[0]) + int.parse(split[1]);
          int currentTime = 60 * now.hour + now.minute;

          if (currentTime < toDeal) {
            // The time is after the time[i-1]
            index = i - 1;
            break;
          }
        }

        if (index >= 0) {
          developer.log(
            "Current time is after ${time[index]} $index",
            name: "ClassTableController",
          );
          // If in the class, the current class.
          // Else, the previous class.
          int currentClassIndex =
              pretendLayout[currentWeek][now.weekday - 1][index ~/ 2][0];
          // In the class
          if (index % 2 == 0) {
            developer.log(
              "In class.",
              name: "ClassTableController",
            );
            if (currentClassIndex != -1) {
              isNext = false;
              timeArrangementToShow =
                  classTableData.timeArrangement[currentClassIndex];
            }
          } else {
            developer.log(
              "Not in class, seek the next class...",
              name: "ClassTableController",
            );
            // See the next class.
            int nextIndex = pretendLayout[currentWeek][now.weekday - 1]
                [(index + 1) ~/ 2][0];
            // If really have class.
            if (nextIndex != -1) {
              if (currentClassIndex != nextIndex) {
                isNext = true;
              } else {
                isNext = false;
              }
              timeArrangementToShow = classTableData.timeArrangement[nextIndex];
            }
          }
          if (timeArrangementToShow != null &&
              timeArrangementToShow!.index != -1) {
            classToShow =
                classTableData.classDetail[timeArrangementToShow!.index];
          }
        } else {
          developer.log(
            "Current time is before ${time[0]} 0",
            name: "ClassTableController",
          );
          isNext = true;
          int currentClassIndex =
              pretendLayout[currentWeek][now.weekday - 1][0][0];
          timeArrangementToShow =
              classTableData.timeArrangement[currentClassIndex];
          classToShow =
              classTableData.classDetail[timeArrangementToShow!.index];
        }
      }
    }
  }

  Future<void> updateClassTable({bool isForce = false}) async {
    isGet = false;
    error = null;
    try {
      classTableData = await ClassTableFile().get(isForce: isForce);
      startDay = DateTime.parse(classTableData.termStartDay);
      currentWeek = (Jiffy.now().dayOfYear -
              Jiffy.parseFromDateTime(startDay).dayOfYear) ~/
          7;

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

      // Get the start day of the semester.
      startDay = DateTime.parse(classTableData.termStartDay);
      startDay = startDay.add(
          Duration(days: 7 * preference.getInt(preference.Preference.swift)));

      // Get the current index.
      currentWeek = (Jiffy.now().dayOfYear -
              Jiffy.parseFromDateTime(startDay).dayOfYear) ~/
          7;

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
