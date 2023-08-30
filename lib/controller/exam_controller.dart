// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'dart:developer' as developer;
import 'package:jiffy/jiffy.dart';
import 'package:watermeter/model/xidian_ids/exam.dart';
import 'package:watermeter/repository/preference.dart' as preference;
import 'package:watermeter/repository/xidian_ids/ehall/exam_session.dart';

class ExamController extends GetxController {
  bool isGet = false;
  String? error;
  String currentSemester = "";
  List<String> semesters = [];
  late List<Subject> subjects;
  late List<ToBeArranged> toBeArranged;
  int dropdownValue = 0;
  Jiffy now = Jiffy.now();

  List<Subject> get isFinished {
    List<Subject> isFinished = List.from(subjects);
    isFinished.removeWhere(
      (element) => element.startTime.isAfter(now),
    );
    return isFinished;
  }

  List<Subject> get isNotFinished {
    List<Subject> isNotFinished = List.from(subjects);
    isNotFinished.removeWhere(
      (element) => element.startTime.isSameOrBefore(now),
    );
    return isNotFinished
      ..sort(
        (a, b) =>
            a.startTime.microsecondsSinceEpoch -
            b.startTime.microsecondsSinceEpoch,
      );
  }

  @override
  void onInit() {
    currentSemester =
        preference.getString(preference.Preference.currentSemester);
    super.onInit();
  }

  @override
  void onReady() async {
    get(semesterStr: currentSemester);
    update();
  }

  Future<void> get({String? semesterStr}) async {
    isGet = false;
    error = null;
    try {
      now = Jiffy.now();
      var qResult = await ExamFile().get(semester: semesterStr);
      int grade = int.parse(
          "20${preference.getString(preference.Preference.idsAccount).substring(0, 2)}");

      if (semesters.isEmpty) {
        double current = int.parse(currentSemester.substring(0, 4)) +
            (int.parse(currentSemester.substring(10)) - 1) * 0.5;
        for (var i in qResult["semester"]) {
          double data = int.parse(i["DM"].toString().substring(0, 4)) +
              (int.parse(i["DM"].substring(10)) - 1) * 0.5;
          if (int.parse(i["DM"].toString().substring(0, 4)) < grade) {
            break;
          } else if (data > current) {
            continue;
          } else {
            semesters.add(i["DM"]);
          }
        }
      }

      subjects = [];
      if (qResult["subjects"] != null) {
        for (var i in qResult["subjects"]) {
          subjects.add(Subject(
            subject: i["KCM"],
            type: i["KSMC"].toString().contains("期末考试") ? "期末考试" : i["KSMC"],
            time: i["KSSJMS"],
            place: i["JASMC"],
            teacher: i["ZJJSXM"],
            seat: int.parse(i["ZWH"]),
          ));
        }
      }

      toBeArranged = [];
      for (var i in qResult["tobearranged"]) {
        toBeArranged.add(ToBeArranged(
          subject: i["KCM"],
          teacher: i["ZJJSXM"],
          id: i["KCH"],
        ));
      }

      isGet = true;
      error = null;
    } on DioException catch (e, s) {
      developer.log(
        "Network exception: ${e.message}\nStack: $s",
        name: "ScoreController",
      );
      error = "网络错误，可能是没联网，可能是学校服务器出现了故障:-P";
    } catch (e, s) {
      developer.log(
        "Other exception: $e\nStack: $s",
        name: "ScoreController",
      );
      error = "未知错误，感兴趣的话，请接到电脑 adb 查看日志。";
    }
    update();
  }
}
