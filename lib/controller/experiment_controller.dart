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
import 'package:watermeter/repository/xidian_ids/sysj_session.dart';

enum ExperimentStatus { cache, fetching, fetched, error, none }

class ExperimentController extends GetxController {
  /// NOTE: Rename from Experiment to avoid "data structure immigration"
  static const physicsCacheName = "PhysicsExperiment.json";
  static const otherCacheName = "OtherExperiment.json";

  ExperimentStatus physicsStatus = ExperimentStatus.none;
  ExperimentStatus otherStatus = ExperimentStatus.none;

  String physicsStatusError = "";
  String otherStatusError = "";

  List<ExperimentData> data = [];

  late File physicsCacheFile;
  late File otherCacheFile;

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
    List<ExperimentData> toReturn = [];

    bool isQualified((DateTime, DateTime) timeRange) =>
        now.isAfter(timeRange.$2);
    for (final experiment in data) {
      bool containsDoing = experiment.timeRanges.where(isQualified).isNotEmpty;
      if (!containsDoing) continue;
      ExperimentData toAdd = ExperimentData.from(experiment);
      toAdd.timeRanges.removeWhere((timeRange) => !isQualified(timeRange));
      toReturn.add(toAdd);
    }

    toReturn.sort(
      (a, b) => a.timeRanges.first.$1
          .difference(b.timeRanges.first.$1)
          .inMicroseconds,
    );

    return toReturn;
  }

  List<ExperimentData> isNotStarted(DateTime now) {
    List<ExperimentData> toReturn = [];

    bool isQualified((DateTime, DateTime) timeRange) =>
        now.isBefore(timeRange.$1);
    for (final experiment in data) {
      bool containsDoing = experiment.timeRanges.where(isQualified).isNotEmpty;
      if (!containsDoing) continue;
      ExperimentData toAdd = ExperimentData.from(experiment);
      toAdd.timeRanges.removeWhere((timeRange) => !isQualified(timeRange));
      toReturn.add(toAdd);
    }

    toReturn.sort(
      (a, b) => a.timeRanges.first.$1
          .difference(b.timeRanges.first.$1)
          .inMicroseconds,
    );

    return toReturn;
  }

  List<ExperimentData> doing(DateTime now) {
    List<ExperimentData> toReturn = [];

    bool isQualified((DateTime, DateTime) timeRange) =>
        now.isAfter(timeRange.$1) && now.isBefore(timeRange.$2);
    for (final experiment in data) {
      bool containsDoing = experiment.timeRanges.where(isQualified).isNotEmpty;
      if (!containsDoing) continue;
      ExperimentData toAdd = ExperimentData.from(experiment);
      toAdd.timeRanges.removeWhere((timeRange) => !isQualified(timeRange));
      toReturn.add(toAdd);
    }

    toReturn.sort(
      (a, b) => a.timeRanges.first.$1
          .difference(b.timeRanges.first.$1)
          .inMicroseconds,
    );

    return toReturn;
  }

  @override
  void onInit() {
    super.onInit();
    log.info(
      "[ExamController][onInit] "
      "Path at ${supportPath.path}.",
    );

    physicsCacheFile = File("${supportPath.path}/$physicsCacheName");
    bool isExist = physicsCacheFile.existsSync();
    if (isExist) {
      log.info(
        "[ExamController][onInit] "
        "Init physics experiment from cache.",
      );
      try {
        List<dynamic> toDecode = jsonDecode(
          physicsCacheFile.readAsStringSync(),
        );
        var physicsData = List<ExperimentData>.generate(
          toDecode.length,
          (index) => ExperimentData.fromJson(toDecode[index]),
        );

        // Check if cache contains old format data (score field was migrated from String)
        // Old format will have been converted to null by _recognitionResultFromJson
        var rawJson = toDecode.firstOrNull;
        bool hasOldFormat =
            rawJson != null &&
            rawJson['score'] != null &&
            rawJson['score'] is String;

        if (hasOldFormat) {
          log.info(
            "[ExamController][onInit] "
            "Detected old String format in physics cache, will trigger refresh.",
          );
          // Delete old cache file to force refresh
          physicsCacheFile.deleteSync();
          physicsStatus = ExperimentStatus.none;
        } else {
          data.addAll(physicsData);
          physicsStatus = ExperimentStatus.cache;
        }
      } catch (e, s) {
        log.handle(e, s);
        log.warning(
          "[ExamController][onInit] "
          "Failed to parse physics cache, will refresh.",
        );
        physicsStatus = ExperimentStatus.none;
      }
    }

    otherCacheFile = File("${supportPath.path}/$otherCacheName");
    isExist = otherCacheFile.existsSync();
    if (isExist) {
      log.info(
        "[ExamController][onInit] "
        "Init other experiment from cache.",
      );
      try {
        List<dynamic> toDecode = jsonDecode(otherCacheFile.readAsStringSync());
        var otherData = List<ExperimentData>.generate(
          toDecode.length,
          (index) => ExperimentData.fromJson(toDecode[index]),
        );

        // Check if cache contains old format data
        var rawJson = toDecode.firstOrNull;
        bool hasOldFormat =
            rawJson != null &&
            rawJson['score'] != null &&
            rawJson['score'] is String;

        if (hasOldFormat) {
          log.info(
            "[ExamController][onInit] "
            "Detected old String format in other cache, will trigger refresh.",
          );
          // Delete old cache file to force refresh
          otherCacheFile.deleteSync();
          otherStatus = ExperimentStatus.none;
        } else {
          data.addAll(otherData);
          otherStatus = ExperimentStatus.cache;
        }
      } catch (e, s) {
        log.handle(e, s);
        log.warning(
          "[ExamController][onInit] "
          "Failed to parse other cache, will refresh.",
        );
        otherStatus = ExperimentStatus.none;
      }
    }
  }

  @override
  void onReady() async {
    super.onReady();
    get();
  }

  Future<List<ExperimentData>> getPhysicsExperiment() async {
    ExperimentStatus previous = physicsStatus;
    physicsStatus = ExperimentStatus.fetching;
    update();
    List<ExperimentData> toReturn = [];
    log.info(
      "[ExperimentController][getPhysicsExperiment] "
      "Fetching data from Internet.",
    );
    try {
      (ExperimentFetchStatus, List<ExperimentData>) returnedData =
          await ExperimentSession().getData();
      if (returnedData.$1 == ExperimentFetchStatus.notSchoolNetwork) {
        log.warning(
          "[ExperimentController][getPhysicsExperiment] "
          "Not in school exception",
        );
        if (physicsCacheFile.existsSync()) {
          log.info(
            "[ExamController][getPhysicsExperiment] "
            "Try to get physics experiment from cache.",
          );
          try {
            List<dynamic> toDecode = jsonDecode(
              physicsCacheFile.readAsStringSync(),
            );
            var physicsData = List<ExperimentData>.generate(
              toDecode.length,
              (index) => ExperimentData.fromJson(toDecode[index]),
            );

            // Check if cache contains old format data (score field was migrated from String)
            // Old format will have been converted to null by _recognitionResultFromJson
            var rawJson = toDecode.firstOrNull;
            bool hasOldFormat =
                rawJson != null &&
                rawJson['score'] != null &&
                rawJson['score'] is String;

            if (hasOldFormat) {
              log.info(
                "[ExamController][getPhysicsExperiment] "
                "Detected old String format in physics cache.",
              );
              // Delete old cache file to force refresh
              physicsCacheFile.deleteSync();
            } else {
              toReturn.addAll(physicsData);
              physicsStatus = ExperimentStatus.cache;
            }
          } catch (e, s) {
            log.handle(e, s);
            log.warning(
              "[ExamController][getPhysicsExperiment] "
              "Failed to parse physics cache.",
            );
            physicsStatusError = "not_school_network";
          }
        }
      } else if (returnedData.$1 == ExperimentFetchStatus.noPassword) {
        log.warning(
          "[ExperimentController][getPhysicsExperiment] "
          "Do not find experiment password",
        );
        physicsStatusError = "experiment_controller.no_password";
      } else {
        toReturn.addAll(returnedData.$2);
        physicsStatus = ExperimentStatus.fetched;
        physicsStatusError = "";
      }
    } on LoginFailedException catch (e, s) {
      log.handle(e, s);
      if (e.msg != null && e.msg!.isNotEmpty) {
        physicsStatusError = e.msg!;
      } else {
        physicsStatusError = "experiment_controller.login_failed";
      }
    } on DioException catch (e, s) {
      log.handle(e, s);
      physicsStatusError = "network_error";
    } catch (e, s) {
      log.handle(e, s);
      physicsStatusError = "error_detect";
    } finally {
      if (physicsStatus == ExperimentStatus.fetched) {
        log.info(
          "[ExperimentController][getPhysicsExperiment] "
          "Store to cache.",
        );
        physicsCacheFile.writeAsStringSync(jsonEncode(toReturn));
        if (Platform.isIOS) {
          final api = SaveToGroupIdSwiftApi();
          try {
            bool result = await api.saveToGroupId(
              FileToGroupID(
                appid: preference.appId,
                fileName: physicsCacheName,
                data: jsonEncode(toReturn),
              ),
            );
            log.info(
              "[ExperimentController][getPhysicsExperiment] "
              "ios Save to public place status: $result.",
            );
          } catch (e, s) {
            log.handle(e, s);
          }
        }
      } else if (previous == ExperimentStatus.cache) {
        physicsStatus = ExperimentStatus.cache;
      } else {
        physicsStatus = ExperimentStatus.error;
      }
    }
    return toReturn;
  }

  Future<List<ExperimentData>> getOtherExperiment() async {
    ExperimentStatus previous = otherStatus;
    otherStatus = ExperimentStatus.fetching;
    update();
    List<ExperimentData> toReturn = [];
    log.info(
      "[ExperimentController][getOtherExperiment] "
      "Fetching data from Internet.",
    );
    try {
      (ExperimentFetchStatus, List<ExperimentData>) returnedData =
          await SysjSession().getDataFromSysj();
      if (returnedData.$1 == ExperimentFetchStatus.notSchoolNetwork) {
        log.warning(
          "[ExperimentController][getOtherExperiment] "
          "Not in school exception",
        );

        if (otherCacheFile.existsSync()) {
          log.info(
            "[ExamController][getOtherExperiment] "
            "Init other experiment from cache.",
          );
          try {
            List<dynamic> toDecode = jsonDecode(
              otherCacheFile.readAsStringSync(),
            );
            var otherData = List<ExperimentData>.generate(
              toDecode.length,
              (index) => ExperimentData.fromJson(toDecode[index]),
            );

            // Check if cache contains old format data
            var rawJson = toDecode.firstOrNull;
            bool hasOldFormat =
                rawJson != null &&
                rawJson['score'] != null &&
                rawJson['score'] is String;

            if (hasOldFormat) {
              log.info(
                "[ExamController][getOtherExperiment] "
                "Detected old String format in other cache.",
              );
              otherCacheFile.deleteSync();
            } else {
              toReturn.addAll(otherData);
              otherStatus = ExperimentStatus.cache;
            }
          } catch (e, s) {
            log.handle(e, s);
            log.warning(
              "[ExamController][getOtherExperiment] "
              "Failed to parse other cache.",
            );
            otherStatusError = "not_school_network";
          }
        }
      } else if (returnedData.$1 == ExperimentFetchStatus.noPassword) {
        log.warning(
          "[ExperimentController][getOtherExperiment] "
          "Do not find experiment password",
        );
        otherStatusError = "experiment_controller.no_password";
      } else {
        toReturn.addAll(returnedData.$2);
        otherStatus = ExperimentStatus.fetched;
        otherStatusError = "";
      }
    } on LoginFailedException catch (e, s) {
      log.handle(e, s);
      if (e.msg != null && e.msg!.isNotEmpty) {
        otherStatusError = e.msg!;
      } else {
        otherStatusError = "experiment_controller.login_failed";
      }
    } on DioException catch (e, s) {
      log.handle(e, s);
      otherStatusError = "network_error";
    } catch (e, s) {
      log.handle(e, s);
      otherStatusError = "error_detect";
    } finally {
      if (otherStatus == ExperimentStatus.fetched) {
        log.info(
          "[ExperimentController][getOtherExperiment] "
          "Store to cache.",
        );
        otherCacheFile.writeAsStringSync(jsonEncode(toReturn));
        if (Platform.isIOS) {
          final api = SaveToGroupIdSwiftApi();
          try {
            bool result = await api.saveToGroupId(
              FileToGroupID(
                appid: preference.appId,
                fileName: otherCacheName,
                data: jsonEncode(toReturn),
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
        otherStatus = ExperimentStatus.cache;
      } else {
        otherStatus = ExperimentStatus.error;
      }
    }
    return toReturn;
  }

  Future<void> get() async {
    await Future.wait([getPhysicsExperiment(), getOtherExperiment()]).then((
      values,
    ) {
      data.clear();
      for (final value in values) {
        data.addAll(value);
      }
      log.info(
        "[ExperimentController] Current status: "
        "phy $physicsStatus oth $otherStatus",
      );
      update();
    });
  }
}
