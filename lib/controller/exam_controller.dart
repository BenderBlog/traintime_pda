// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'dart:developer' as developer;
import 'package:jiffy/jiffy.dart';
import 'package:watermeter/model/xidian_ids/exam.dart';
import 'package:watermeter/repository/xidian_ids/jiaowu_service_session.dart';

class ExamController extends GetxController {
  bool isGet = false;
  String? error;
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
  void onReady() async {
    get();
    update();
  }

  Future<void> get() async {
    isGet = false;
    error = null;
    try {
      now = Jiffy.now();
      var data = await JiaowuServiceSession().getExam();

      subjects = data.$1;
      toBeArranged = data.$2;

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
        "On exam controller: $e\nStack: $s",
        name: "ScoreController",
      );
      error = "On exam controller: $e\nStack: $s";
    }
    update();
  }
}
