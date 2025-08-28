// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:time/time.dart';
import 'package:watermeter/bridge/save_to_groupid.g.dart';
import 'package:watermeter/model/home_arrangement.dart';
import 'package:watermeter/model/xidian_ids/experiment.dart';
import 'package:watermeter/repository/experiment_session.dart';
import 'package:watermeter/repository/logger.dart';
import 'package:get/get.dart';
import 'package:watermeter/repository/network_session.dart';
import 'package:watermeter/repository/preference.dart' as preference;

enum ExperimentStatus { cache, fetching, fetched, error, none }

class ExperimentController extends GetxController {
  static const experimentCacheName = "Experiment.json";

  ExperimentStatus status = ExperimentStatus.none;
  String error = "";
  late List<ExperimentData> data;
  late File file;

  int get sum {
    int score = 0;
    for (var i in data) {
      if (!i.score.contains("未录入")) score += int.parse(i.score);
    }
    return score;
  }

  List<HomeArrangement> getExperimentOfDay(DateTime now) {
    List<ExperimentData> isFinished = List.from(data);
    DateFormat formatter = DateFormat(HomeArrangement.format);
    isFinished.removeWhere((element) => !element.time.first.isAtSameDayAs(now));
    return isFinished
        .map(
          (e) => HomeArrangement(
            name: e.name,
            place: e.classroom,
            teacher: e.teacher,
            startTimeStr: formatter.format(e.time[0]),
            endTimeStr: formatter.format(e.time[1]),
          ),
        )
        .toList();
  }

  List<ExperimentData> isFinished(DateTime now) {
    List<ExperimentData> isFinished = List.from(data);
    isFinished.removeWhere((e) => e.time[0].isAfter(now));
    return isFinished..sort(
      (a, b) =>
          a.time[1].microsecondsSinceEpoch - b.time[1].microsecondsSinceEpoch,
    );
  }

  List<ExperimentData> isNotFinished(DateTime now) {
    List<ExperimentData> isNotFinished = List.from(data);
    isNotFinished.removeWhere(
      (e) => e.time[0].isAtSameMicrosecondAs(now) || e.time[0].isBefore(now),
    );
    return isNotFinished..sort(
      (a, b) =>
          a.time[0].microsecondsSinceEpoch - b.time[1].microsecondsSinceEpoch,
    );
  }

  List<ExperimentData> doing(DateTime now) {
    List<ExperimentData> isNotFinished = List.from(data);
    isNotFinished.removeWhere(
      (element) =>
          now.microsecondsSinceEpoch < element.time[0].microsecondsSinceEpoch ||
          now.microsecondsSinceEpoch > element.time[1].microsecondsSinceEpoch,
    );
    return isNotFinished..sort(
      (a, b) =>
          a.time[1].microsecondsSinceEpoch - b.time[1].microsecondsSinceEpoch,
    );
  }

  @override
  void onInit() {
    super.onInit();
    log.info(
      "[ExamController][onInit] "
      "Path at ${supportPath.path}.",
    );
    file = File("${supportPath.path}/$experimentCacheName");
    bool isExist = file.existsSync();

    if (isExist) {
      log.info(
        "[ExamController][onInit] "
        "Init from cache.",
      );
      List<dynamic> toDecode = jsonDecode(file.readAsStringSync());
      data = List<ExperimentData>.generate(
        toDecode.length,
        (index) => ExperimentData.fromJson(toDecode[index]),
      );
      status = ExperimentStatus.cache;
    } else {
      data = [];
    }
  }

  @override
  void onReady() async {
    super.onReady();
    get();
  }

  Future<void> get() async {
    ExperimentStatus previous = status;
    status = ExperimentStatus.fetching;
    update();
    log.info(
      "[ExperimentController][get] "
      "Fetching data from Internet.",
    );
    try {
      (ExperimentFetchStatus, List<ExperimentData>) returnedData =
          await ExperimentSession().getData();
      if (returnedData.$1 == ExperimentFetchStatus.notSchoolNetwork) {
        log.warning(
          "[ExperimentController][get] "
          "Not in school exception",
        );
        error = "not_school_network";
      } else if (returnedData.$1 == ExperimentFetchStatus.noPassword) {
        log.warning(
          "[ExperimentController][get] "
          "Do not find experiment password",
        );
        error = "experiment_controller.no_password";
      } else {
        data = returnedData.$2;
        status = ExperimentStatus.fetched;
        error = "";
      }
    } on LoginFailedException catch (e, s) {
      log.handle(e, s);
      if (e.msg != null && e.msg!.isNotEmpty) {
        error = e.msg!;
      } else {
        error = "experiment_controller.login_failed";
      }
    } on DioException catch (e, s) {
      log.handle(e, s);
      error = "network_error";
    } catch (e, s) {
      log.handle(e, s);
      error = "error_detect";
    } finally {
      if (status == ExperimentStatus.fetched) {
        log.info(
          "[ExperimentController][get] "
          "Store to cache.",
        );
        file.writeAsStringSync(jsonEncode(data));
        if (Platform.isIOS) {
          final api = SaveToGroupIdSwiftApi();
          try {
            bool result = await api.saveToGroupId(
              FileToGroupID(
                appid: preference.appId,
                fileName: experimentCacheName,
                data: jsonEncode(data),
              ),
            );
            log.info(
              "[ExperimentController][get] "
              "ios Save to public place status: $result.",
            );
          } catch (e, s) {
            log.handle(e, s);
          }
        }
      } else if (previous == ExperimentStatus.cache) {
        status = ExperimentStatus.cache;
      } else {
        status = ExperimentStatus.error;
      }
      update();
    }
  }
}
