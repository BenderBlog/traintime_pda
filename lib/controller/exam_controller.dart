// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_logs/flutter_logs.dart';
import 'package:get/get.dart';
import 'package:jiffy/jiffy.dart';
import 'package:watermeter/model/xidian_ids/exam.dart';
import 'package:watermeter/repository/electricity_session.dart';
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
  late ExamData data;
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
    FlutterLogs.logInfo(
      "PDA ExamController",
      "onInit",
      "Path at ${supportPath.path}.",
    );
    file = File("${supportPath.path}/$examDataCacheName");
    bool isExist = file.existsSync();

    if (isExist) {
      FlutterLogs.logInfo(
        "PDA ExamController",
        "onInit",
        "Init from cache.",
      );
      data = ExamData.fromJson(jsonDecode(file.readAsStringSync()));
      status = ExamStatus.cache;
    } else {
      data = ExamData(subject: [], toBeArranged: []);
    }
  }

  @override
  void onReady() async {
    super.onReady();
    get().then((value) => update());
  }

  Future<void> get() async {
    ExamStatus previous = status;
    FlutterLogs.logInfo(
      "PDA ExamController",
      "get",
      "Fetching data from Internet.",
    );
    try {
      now = Jiffy.now();
      status = ExamStatus.fetching;
      data = await JiaowuServiceSession().getExam();
      status = ExamStatus.fetched;
      error = "";
    } on DioException catch (e, s) {
      FlutterLogs.logWarn(
        "PDA ExamController",
        "get",
        "Network exception: \n${e.message}\nStack: \n$s",
      );
      error = "网络错误，可能是没联网，可能是学校服务器出现了故障:-P";
    } catch (e, s) {
      FlutterLogs.logWarn(
        "PDA ExamController",
        "get",
        "Exception: \n$e\nStack: \n$s",
      );
      error = "获取考试信息错误，请刷新。";
    } finally {
      if (status == ExamStatus.fetched) {
        FlutterLogs.logInfo(
          "PDA ExamController",
          "get",
          "Store to cache.",
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
