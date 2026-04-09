// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:watermeter/bridge/save_to_groupid.g.dart';
import 'package:watermeter/model/fetch_result.dart';
import 'package:watermeter/model/not_school_network_exception.dart';
import 'package:watermeter/model/xidian_ids/experiment.dart';
import 'package:watermeter/model/time_list.dart';
import 'package:watermeter/page/login/jc_captcha.dart';
import 'package:watermeter/repository/logger.dart';
import 'package:watermeter/repository/network_session.dart';
import 'package:watermeter/repository/preference.dart' as prefs;
import 'package:watermeter/repository/xidian_ids/ids_session.dart';

Future<FetchResult<List<ExperimentData>>> getOtherExperimentData() async {
  try {
    List<ExperimentData> data = await SysjSession().getDataFromSysj();
    DateTime fetchTime = DateTime.now();
    await SysjSession.writeCache(data);
    return FetchResult.fresh(fetchTime: fetchTime, data: data);
  } on PasswordWrongException {
    log.error(
      "[SysjSession][getExperimentData] "
      "Password changed, remove cache",
    );
    await SysjSession.deleteCache();
    rethrow;
  } catch (e, s) {
    log.handle(e, s, "[ExperimentSession][getExperimentData] Have issue");
    var cache = SysjSession.getCache();
    if (cache != null) {
      return FetchResult.cache(
        fetchTime: cache.$1,
        data: cache.$2,
        hintKey: "local_cache_hint",
      );
    }
    rethrow;
  }
}

class SysjSession extends IDSSession {
  static const otherExperimentCacheName = "OtherExperiment.json";
  static File otherExperimentCacheFile = File(
    "${supportPath.path}/$otherExperimentCacheName",
  );
  static bool get isCacheExist => otherExperimentCacheFile.existsSync();

  static Future<void> deleteCache() async {
    if (await otherExperimentCacheFile.exists()) {
      await otherExperimentCacheFile.delete();
    }
  }

  static Future<void> writeCache(List<ExperimentData> data) async {
    log.info(
      "[ExperimentSession][writeCache] "
      "Store to cache.",
    );
    otherExperimentCacheFile.writeAsStringSync(jsonEncode(data));
    if (Platform.isIOS) {
      final api = SaveToGroupIdSwiftApi();
      try {
        bool result = await api.saveToGroupId(
          FileToGroupID(
            appid: prefs.appId,
            fileName: otherExperimentCacheName,
            data: jsonEncode(data),
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
  }

  static (DateTime, List<ExperimentData>)? getCache() {
    if (!isCacheExist) return null;
    try {
      List<dynamic> toDecode = jsonDecode(
        otherExperimentCacheFile.readAsStringSync(),
      );
      List<ExperimentData> physicsData = List<ExperimentData>.generate(
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
        otherExperimentCacheFile.deleteSync();
        return null;
      }

      DateTime lastUpdateTime = otherExperimentCacheFile.lastModifiedSync();
      return (lastUpdateTime, physicsData);
    } catch (e, s) {
      log.handle(e, s);
      log.warning(
        "[ExperimentSession][getCache] "
        "Failed to parse physics cache, will refresh.",
      );
      return null;
    }
  }

  /// These are from sysj.xidian.edu.cn's js file
  Future<List<ExperimentData>> getDataFromSysj() async {
    if (!(await NetworkSession.isInSchool())) {
      throw NotSchoolNetworkException();
    }

    Response firstRequest = await dio.get(
      "https://sysj.xidian.edu.cn/xidian/test",
    );

    if (firstRequest.isRedirect) {
      String redirectUrl = firstRequest.headers[HttpHeaders.locationHeader]![0];
      firstRequest = await dio.get(redirectUrl);

      redirectUrl = firstRequest.headers[HttpHeaders.locationHeader]![0];

      Uri toParseParameter = Uri.parse(redirectUrl);
      String state = toParseParameter.queryParameters["state"]!;

      firstRequest = await dio.get(redirectUrl);

      firstRequest = await dio.getUri<String>(
        Uri.https("sysj.xidian.edu.cn", "/uaa/xidian/login", {
          "redirect_uri": "https://sysj.xidian.edu.cn/xidian/webapp/callback",
          "state": state,
          "client_id": "GvsunLims",
          "response_type": "code",
          "authorize_uri": "https://sysj.xidian.edu.cn/uaa/oauth/authorize",
        }),
      );

      // String clientId = RegExp(
      //   "let\\sclient_id\\s=\\s\"(?<clientId>\\d+)\";",
      // ).firstMatch(firstRequest.data!.toString())!.namedGroup("clientId")!;

      Uri hrefIds =
          Uri.https("ids.xidian.edu.cn", "authserver/oauth2.0/authorize", {
            "redirect_uri": "https://sysj.xidian.edu.cn/uaa/xidian/callback",
            "response_type": "code",
            "state": state,
            "client_id": "1387116615722893312",
          });

      firstRequest = await dio.getUri(hrefIds);

      hrefIds = Uri.parse(firstRequest.headers[HttpHeaders.locationHeader]![0]);

      log.info(hrefIds);

      String? location;

      if (!hrefIds.authority.contains("sysj")) {
        log.info(
          "[SysjSession][getDataFromSysj] Jump not have sysj, treat as new login.",
        );
        location = await checkAndLogin(
          target: hrefIds.queryParameters["service"]!,
          sliderCaptcha: (String cookieStr) =>
              SliderCaptchaClientProvider(cookie: cookieStr).solve(null),
        );
      } else {
        location = hrefIds.toString();
      }

      while (location != null) {
        var response = await dio.get(location);
        log.info(
          "[SysjSession][getDataFromSysj] Received location: $location.",
        );
        location = response.headers[HttpHeaders.locationHeader]?[0];
      }

      location = await dio
          .getUri(
            Uri.https("sysj.xidian.edu.cn", "/uaa/oauth/authorize", {
              "redirect_uri":
                  "https://sysj.xidian.edu.cn/xidian/webapp/callback",
              "state": state,
              "client_id": "GvsunLims",
              "response_type": "code",
            }),
          )
          .then((value) => value.data.toString());
      final match = RegExp(r'\?code=(?<code>.*)\\u0026').firstMatch(location!);
      String code = match!.namedGroup("code")!;

      String loginLastTime = await dio
          .getUri(
            Uri.https("sysj.xidian.edu.cn", "/xidian/webapp/callback", {
              "code": code,
              "state": state,
            }),
          )
          .then((value) => value.data.toString());
      final matchPwd = RegExp(
        r"var password = \'(?<pwd>.*)\';",
      ).firstMatch(loginLastTime);
      String pwd = matchPwd!.namedGroup("pwd")!;
      Response data = await dio.post(
        "https://sysj.xidian.edu.cn/xidian/webapp/login",
        data: {
          "username": prefs.getString(prefs.Preference.idsAccount),
          "password": pwd,
        },
      );
      if (data.statusCode == 302) {
        log.info(
          "[SysjSession][getDataFromSysj] Login post returns a redirect "
          "${data.headers[HttpHeaders.locationHeader]![0]}.",
        );

        data = await dio.get(data.headers[HttpHeaders.locationHeader]![0]);
      }
    }

    List<ExperimentData> experimentData = [];

    const experimentNameMark = '???student.timetable.course???：';
    const experimentClassroomMark = '???schedule.course.lab???：';
    const experimentTeacherMark = '???student.timetable.teacher???：';

    for (int i = 1; i <= 25; ++i) {
      Document classTableHtml = await dio
          .post(
            "https://sysj.xidian.edu.cn/xidian/StudentCurrWeekTimetable",
            data: "weeks=$i",
          )
          .then((value) {
            return parse(value.data.toString().trim());
          });

      List<Element> tables = classTableHtml.getElementsByTagName("table");
      if (tables.length < 2) {
        log.info("[SysjSession][getDataFromSysj] No tables at week $i");
        continue;
      }

      Element table = tables[1];

      /// Fetch the weekdays
      List<String> weekdays = [];
      table.querySelectorAll('thead th').forEach((e) {
        if (e.innerHtml.isEmpty) return;
        String dateStr = e.innerHtml.split('<br>')[1].trim();
        weekdays.add(dateStr);
      });

      for (int weekDay = 1; weekDay <= 7; ++weekDay) {
        for (int classIndex = 1; classIndex <= 13; ++classIndex) {
          String cellContent =
              table
                  .querySelector("td[do-labReservation='$weekDay,$classIndex']")
                  ?.innerHtml
                  .trim() ??
              "";

          if (cellContent.isEmpty ||
              !cellContent.contains(experimentNameMark) ||
              !cellContent.contains(experimentClassroomMark) ||
              !cellContent.contains(experimentTeacherMark)) {
            continue;
          }

          log.info(
            "[SysjSession][getDataFromSysj] cellContent of week $weekDay class $classIndex is $cellContent",
          );

          List<String> contentList = cellContent.split('\n')
            ..removeWhere((e) => e.isEmpty)
            ..map((e) => e.trim());
          String name = contentList[0]
              .replaceAll(experimentNameMark, "")
              .trim()
              .replaceAll("<br>", "");
          String classroom = contentList[1]
              .replaceAll(experimentClassroomMark, "")
              .trim()
              .replaceAll("<br>", "");
          String teacher = contentList[2]
              .replaceAll(experimentTeacherMark, "")
              .trim()
              .replaceAll("<br>", "");

          List<int> dateNums = weekdays[weekDay - 1]
              .split('-')
              .map<int>((e) => int.parse(e))
              .toList();
          List<int> startTimeList = timeList[(classIndex - 1) * 2]
              .split(":")
              .map<int>((e) => int.parse(e))
              .toList();
          List<int> endTimeList = timeList[(classIndex - 1) * 2 + 1]
              .split(":")
              .map<int>((e) => int.parse(e))
              .toList();
          DateTime startTime = DateTime(
            dateNums[0],
            dateNums[1],
            dateNums[2],
            startTimeList[0],
            startTimeList[1],
          );
          DateTime endTime = DateTime(
            dateNums[0],
            dateNums[1],
            dateNums[2],
            endTimeList[0],
            endTimeList[1],
          );

          while (classIndex < 13) {
            String nextCellContent =
                table
                    .querySelector(
                      "td[do-labReservation='$weekDay,${classIndex + 1}']",
                    )
                    ?.innerHtml
                    .trim() ??
                "";
            log.info(
              "[SysjSession][getDataFromSysj] fetching next class, "
              "nextCellContent of week $weekDay class $classIndex is $cellContent",
            );

            if (cellContent != nextCellContent) {
              log.info(
                "[SysjSession][getDataFromSysj] fetching next class, "
                "not match the last one, break looping",
              );
              break;
            }

            // Actually +1 for next day, then -1 to match the index of the array
            List<int> newEndTimeList = timeList[classIndex * 2 + 1]
                .split(":")
                .map<int>((e) => int.parse(e))
                .toList();
            endTime = DateTime(
              dateNums[0],
              dateNums[1],
              dateNums[2],
              newEndTimeList[0],
              newEndTimeList[1],
            );
            log.info(
              "[SysjSession][getDataFromSysj] fetching next class, "
              "new endTime $endTime",
            );

            classIndex++;
          }

          // If the list have no data related to this name, lab or teacher, just add it.
          int dataWithSameInfoIndex = experimentData.indexWhere(
            (e) =>
                e.name == name &&
                e.classroom == classroom &&
                e.teacher == teacher,
          );
          if (experimentData.isEmpty || dataWithSameInfoIndex == -1) {
            final newData = ExperimentData(
              type: ExperimentType.others,
              name: name,
              classroom: classroom,
              timeRanges: [(startTime, endTime)],
              teacher: teacher,
            );
            log.info("[SysjSession][getDataFromSysj] Added: $newData");
            experimentData.add(newData);
            continue;
          }

          experimentData[dataWithSameInfoIndex].timeRanges.add((
            startTime,
            endTime,
          ));
          log.info(
            "[SysjSession][getDataFromSysj] Updated: ${experimentData[dataWithSameInfoIndex]}",
          );
        }
      }
    }

    return experimentData;
  }
}
