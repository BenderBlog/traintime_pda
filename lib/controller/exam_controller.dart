// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'dart:developer' as developer;
import 'package:jiffy/jiffy.dart';
import 'package:watermeter/model/xidian_ids/exam.dart';
import 'package:watermeter/repository/network_session.dart';
import 'package:watermeter/repository/xidian_ids/jiaowu_service_session.dart';

enum ExamStatus {
  cache,
  fetching,
  fetched,
  error,
  none,
}

class ExamController extends GetxController {
  static const examDataCacheName = "exam.json";

  ExamStatus status = ExamStatus.none;
  String error = "";
  ExamData data = ExamData(
    subject: [],
    toBeArranged: [],
  );
  late File file;
  Jiffy now = Jiffy.now();

  List<Subject> get isFinished {
    List<Subject> isFinished = List.from(data.subject);
    isFinished.removeWhere(
      (element) => element.startTime.isAfter(now),
    );
    return isFinished;
  }

  List<Subject> get isNotFinished {
    List<Subject> isNotFinished = List.from(data.subject);
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
    super.onInit();
    developer.log("Path at ${supportPath.path}.", name: "ExamController");
    file = File("${supportPath.path}/$examDataCacheName");

    if (file.existsSync()) {
      developer.log("Init from cache.", name: "ExamController");
      data = ExamData.fromJson(jsonDecode(file.readAsStringSync()));
      status = ExamStatus.cache;
    }
  }

  @override
  void onReady() async {
    super.onReady();
    get();
    update();
  }

  Future<void> get() async {
    ExamStatus previous = status;
    try {
      now = Jiffy.now();
      status = ExamStatus.fetching;
      data = await JiaowuServiceSession().getExam();
      status = ExamStatus.fetched;
      error = "";
    } on DioException catch (e, s) {
      developer.log(
        "Network exception: ${e.message}\nStack: $s",
        name: "ExamController",
      );
      error = "网络错误，可能是没联网，可能是学校服务器出现了故障:-P";
    } catch (e, s) {
      developer.log(
        "On exam controller: $e\nStack: $s",
        name: "ExamController",
      );
      error = "On exam controller: $e\nStack: $s";
    } finally {
      if (status == ExamStatus.fetched) {
        developer.log(
          "Store to cache.",
          name: "ExamController",
        );
        file.writeAsStringSync(jsonEncode(
          data.toJson(),
        ));
      } else if (previous == ExamStatus.cache) {
        status = ExamStatus.cache;
      } else {
        status = ExamStatus.error;
      }
    }
    update();
  }
}
