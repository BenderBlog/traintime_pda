import 'package:get/get.dart';
import 'package:jiffy/jiffy.dart';
import 'package:watermeter/model/user.dart';
import 'package:watermeter/model/xidian_ids/classtable.dart';
import 'package:watermeter/repository/xidian_ids/classtable_session.dart';

class ClassTableController extends GetxController {
  bool isGet = false;
  String? error;

  // Classtable Data
  List<ClassDetail> classDetail = <ClassDetail>[];
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

  @override
  void onReady() async {
    await ClassTableFile().get().onError((error, stackTrace) {
      error = error.toString();
      throw error;
    }).then((value) {
      // Deal with the classtable data.
      semesterCode = value["semesterCode"];
      termStartDay = value["termStartDay"];
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

        // Uncomment to see the conflict.
        /*
        classData.classDetail.add(ClassDetail(
          name: "测试连课",
          teacher: "SPRT",
          place: "Flutter",
        ));
        classData.timeArrangement.addAll([
          TimeArrangement(
            index: classData.classDetail.length - 1,
            start: 2,
            stop: 8,
            day: 2,
            weekList: "1111111111111111111111",
          ),
          TimeArrangement(
            index: classData.classDetail.length - 1,
            start: 4,
            stop: 8,
            day: 6,
            weekList: "1111111111111111111111",
          ),
        ]);
        */

        // Get the start day of the semester.
        startDay = DateTime.parse(termStartDay);
        if (user["swift"] != null) {
          startDay =
              startDay.add(Duration(days: 7 * int.parse(user["swift"]!)));
        }

        // Get the current index.
        currentWeek =
            (Jiffy(DateTime.now()).dayOfYear - Jiffy(startDay).dayOfYear) ~/ 7;

        // Init the matrix.
        // 1. prepare the structure, a three-deminision array.
        //    for week-day~class array
        pretendLayout = List.generate(
          semesterLength,
          (week) =>
              List.generate(7, (day) => List.generate(10, (classes) => [])),
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
      }
      isGet = true;
    });
    update();
  }
}
