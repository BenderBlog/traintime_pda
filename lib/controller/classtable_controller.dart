import 'package:get/get.dart';
import 'package:jiffy/jiffy.dart';
import 'dart:developer' as developer;
import 'package:watermeter/model/user.dart';
import 'package:watermeter/model/xidian_ids/classtable.dart';
import 'package:watermeter/repository/xidian_ids/classtable_session.dart';

class ClassTableController extends GetxController {
  bool isGet = false;
  String? error;

  // Classtable Data
  List<ClassDetail> classDetail = <ClassDetail>[];
  List<ClassDetail> notArranged = <ClassDetail>[];
  List<TimeArrangement> timeArrangement = <TimeArrangement>[];
  String semesterCode = "";
  String termStartDay = "";
  int semesterLength = 0;

  // The start day of the semester.
  var startDay = DateTime.parse("2022-01-22");

  // A list as an index of the classtable items.
  late List<List<List<List<int>>>> pretendLayout;

  // Mark the current week.
  late int currentWeek;

  // Current Information
  ClassDetail? classToShow;
  TimeArrangement? timeArrangementToShow;
  bool? isNext;

  @override
  void onReady() async {
    await updateClassTable();
    update();
  }

  Future<void> updateClassTable({bool isForce = false}) async {
    isGet = false;
    error = null;
    try {
      var value = await ClassTableFile().get(isForce: isForce);

      // Init the arraies.
      classDetail = [];
      timeArrangement = [];

      // Deal with the classtable data.
      semesterCode = value["semesterCode"];
      termStartDay = value["termStartDay"];
      developer.log(termStartDay, name: "updateClassTable");
      semesterLength = 0;
      for (var i in value["rows"]) {
        var toDeal = ClassDetail(
          name: i["KCM"],
          teacher: i["SKJS"],
          place: i["JASDM"],
          code: i["KCH"],
          number: i["KXH"],
        );
        if (!classDetail.contains(toDeal)) {
          classDetail.add(toDeal);
        }
        timeArrangement.add(
          TimeArrangement(
            index: classDetail.indexOf(toDeal),
            start: int.parse(i["KSJC"]),
            stop: int.parse(i["JSJC"]),
            day: int.parse(i["SKXQ"]),
            weekList: i["SKZC"].toString(),
          ),
        );
        if (i["SKZC"].toString().length > semesterLength) {
          semesterLength = i["SKZC"].toString().length;
        }
      }

      // Deal with the not arranged data.
      for (var i in value["notArranged"]) {
        notArranged.add(ClassDetail(
          name: i["KCM"],
          teacher: i["SKJS"],
          code: i["KCH"],
          number: i["KXH"],
        ));
      }

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
      startDay = DateTime.parse(termStartDay);
      if (user["swift"] != null) {
        startDay = startDay.add(Duration(days: 7 * int.parse(user["swift"]!)));
      }

      // Get the current index.
      currentWeek =
          (Jiffy(DateTime.now()).dayOfYear - Jiffy(startDay).dayOfYear) ~/ 7;

      // Init the matrix.
      // 1. prepare the structure, a three-deminision array.
      //    for week-day~class array
      pretendLayout = List.generate(
        semesterLength,
        (week) => List.generate(7, (day) => List.generate(10, (classes) => [])),
      );

      // 2. init each week's array
      for (int week = 0; week < semesterLength; ++week) {
        for (int day = 0; day < 7; ++day) {
          // 2.a. Choice the class in this day.
          List<TimeArrangement> thisDay = [];
          for (var i in timeArrangement) {
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
              pretendLayout[week][day][j].add(timeArrangement.indexOf(i));
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

      // Get the current time.
      if (currentWeek >= 0 && currentWeek < semesterLength) {
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
                timeArrangementToShow = timeArrangement[currentClassIndex];
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
                timeArrangementToShow = timeArrangement[nextIndex];
              }
            }
            if (timeArrangementToShow != null &&
                timeArrangementToShow!.index != -1) {
              classToShow = classDetail[timeArrangementToShow!.index];
            }
          } else {
            developer.log(
              "Current time is before ${time[0]} 0",
              name: "ClassTableController",
            );
            isNext = true;
            int currentClassIndex =
                pretendLayout[currentWeek][now.weekday - 1][0][0];
            timeArrangementToShow = timeArrangement[currentClassIndex];
            classToShow = classDetail[timeArrangementToShow!.index];
          }
        }
      }

      update();
    } catch (e, s) {
      error = e.toString() + s.toString();
      throw error!;
    }
  }
}
