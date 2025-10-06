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
  /// NOTE: Rename from Experiment to avoid "data structure immigration"
  static const experimentCacheName = "Experiments.json";

  ExperimentStatus status = ExperimentStatus.none;
  String error = "";
  late List<ExperimentData> data;
  late File file;

  // int get sum {
  //   int score = 0;
  //   for (var i in data) {
  //     if (!i.score.contains("未录入")) score += int.parse(i.score);
  //   }
  //   return score;
  // }

  List<HomeArrangement> getExperimentOfDay(DateTime now) {
    List<HomeArrangement> toReturn = [];
    DateFormat formatter = DateFormat(HomeArrangement.format);

    for (final experiment in data) {
      for (final timeRange in experiment.timeRanges) {
        if (!timeRange.$1.isAtSameDayAs(now)) continue;
        toReturn.add(
          HomeArrangement(
            name: experiment.name,
            place: experiment.classroom,
            teacher: experiment.teacher,
            startTimeStr: formatter.format(timeRange.$1),
            endTimeStr: formatter.format(timeRange.$2),
          ),
        );
      }
    }

    return toReturn;
  }

  List<ExperimentData> isFinished(DateTime now) {
    Set<ExperimentData> toReturn = {};

    for (final experiment in data) {
      for (final timeRange in experiment.timeRanges) {
        if (now.isAfter(timeRange.$2)) {
          toReturn.add(experiment);
        }
      }
    }

    return toReturn.toList();
  }

  List<ExperimentData> isNotFinished(DateTime now) {
    Set<ExperimentData> toReturn = {};

    for (final experiment in data) {
      for (final timeRange in experiment.timeRanges) {
        if (now.isBefore(timeRange.$1)) {
          toReturn.add(experiment);
        }
      }
    }

    return toReturn.toList();
  }

  List<ExperimentData> doing(DateTime now) {
    Set<ExperimentData> toReturn = {};

    for (final experiment in data) {
      for (final timeRange in experiment.timeRanges) {
        if (now.isAtSameDayAs(timeRange.$1) &&
            now.isAfter(timeRange.$1) &&
            now.isBefore(timeRange.$2)) {
          toReturn.add(experiment);
        }
      }
    }

    return toReturn.toList();
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
