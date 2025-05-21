// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:watermeter/bridge/save_to_groupid.g.dart';
import 'package:watermeter/model/home_arrangement.dart';
import 'package:watermeter/repository/logger.dart';
import 'package:get/get.dart';
import 'package:jiffy/jiffy.dart';
import 'package:watermeter/model/xidian_ids/exam.dart';
import 'package:watermeter/repository/network_session.dart';
import 'package:watermeter/repository/xidian_ids/exam_session.dart';
import 'package:watermeter/repository/preference.dart' as preference;

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

  List<HomeArrangement> getExamOfDate(DateTime now) {
    List<Subject> isFinished = List.from(data.subject);

    isFinished.removeWhere((element) => !(element.startTime?.isSame(
          Jiffy.parseFromDateTime(now),
          unit: Unit.day,
        ) ??
        false));
    return isFinished
        .map((e) => HomeArrangement(
              name: "${e.subject}考试",
              place: e.place,
              seat: e.seat,
              startTimeStr:
                  e.startTime?.format(pattern: HomeArrangement.format) ??
                      e.startTimeStr,
              endTimeStr: e.stopTime?.format(pattern: HomeArrangement.format) ??
                  e.endTimeStr,
            ))
        .toList();
  }

  List<Subject> isFinished(DateTime now) {
    List<Subject> isFinished = List.from(data.subject);
    // Should remove all disqualified.
    isFinished.removeWhere(
      (element) =>
          element.startTime?.isAfter(
            Jiffy.parseFromDateTime(now),
          ) ??
          true,
    );
    return isFinished;
  }

  List<Subject> get isDisQualified {
    List<Subject> isDisQualified = List.from(data.subject);
    isDisQualified.removeWhere(
      (element) => element.startTime != null && element.stopTime != null,
    );
    return isDisQualified;
  }

  List<Subject> isNotFinished(DateTime now) {
    List<Subject> isNotFinished = List.from(data.subject);
    // Should remove all disqualified.
    isNotFinished.removeWhere(
      (element) =>
          element.startTime?.isSameOrBefore(
            Jiffy.parseFromDateTime(now),
          ) ??
          true,
    );
    return isNotFinished
      ..sort(
        (a, b) =>
            a.startTime!.microsecondsSinceEpoch -
            b.startTime!.microsecondsSinceEpoch,
      );
  }

  @override
  void onInit() {
    super.onInit();
    log.info(
      "[ExamController][onInit] "
      "Path at ${supportPath.path}.",
    );
    file = File("${supportPath.path}/$examDataCacheName");
    bool isExist = file.existsSync();

    if (isExist) {
      log.info(
        "[ExamController][onInit] "
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
    update();
    log.info(
      "[ExamController][get] "
      "Fetching data from Internet.",
    );
    try {
      status = ExamStatus.fetching;
      data = preference.getBool(preference.Preference.role)
          ? await ExamSession().getExamYjspt()
          : await ExamSession().getExamEhall();
      status = ExamStatus.fetched;
      error = "";
    } on DioException catch (e, s) {
      log.handle(e, s);
      error = "network_error";
    } catch (e, s) {
      log.handle(e, s);
    } finally {
      if (status == ExamStatus.fetched) {
        log.info(
          "[ExamController][get] "
          "Store to cache.",
        );
        file.writeAsStringSync(jsonEncode(
          data.toJson(),
        ));
        if (Platform.isIOS) {
          final api = SaveToGroupIdSwiftApi();
          try {
            bool result = await api.saveToGroupId(FileToGroupID(
              appid: preference.appId,
              fileName: "ExamFile.json",
              data: jsonEncode(data.toJson()),
            ));
            log.info(
              "[ExamController][get] "
              "ios Save to public place status: $result.",
            );
          } catch (e, s) {
            log.handle(e, s);
          }
        }
      } else if (previous == ExamStatus.cache) {
        status = ExamStatus.cache;
      } else {
        status = ExamStatus.error;
      }
    }
    update();
  }
}
