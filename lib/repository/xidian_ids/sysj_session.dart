// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:watermeter/model/xidian_ids/experiment.dart';
import 'package:watermeter/page/login/jc_captcha.dart';
import 'package:watermeter/repository/experiment_session.dart';
import 'package:watermeter/repository/logger.dart';
import 'package:watermeter/repository/preference.dart' as prefs;
import 'package:watermeter/repository/xidian_ids/ids_session.dart';

class SysjSession extends IDSSession {
  /// These are from sysj.xidian.edu.cn's js file
  Future<(ExperimentFetchStatus, List<ExperimentData>)>
  getDataFromSysj() async {
    // if (!(await NetworkSession.isInSchool())) {
    //   log.info("[SysjSession][getDataFromSysj] Not in schoolnet.");
    //   throw NotSchoolNetworkException();
    // }

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

    for (int i = 1; i <= 25; ++i) {
      Document classTableHtml = await dio
          .post(
            "https://sysj.xidian.edu.cn/xidian/StudentCurrWeekTimetable",
            data: {"weeks": i},
          )
          .then((value) {
            log.debug(value.data.toString().trim());
            return parse(value.data.toString().trim());
          });

      List<Element> tables = classTableHtml.getElementsByTagName("table");
      if (tables.length < 2) {
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

      /// TODO: USE getElementFromTags to clearify the data get from the table
      table.querySelectorAll('tbody tr').asMap().forEach((rowIndex, row) {
        var periodElement = row.querySelector('th span');
        if (periodElement == null) return;

        String periodName = periodElement.innerHtml.split('<font>')[0].trim();

        row.querySelectorAll('td').asMap().forEach((cellIndex, cell) {
          String cellContent = cell.innerHtml.trim();

          if (cellContent.isEmpty) return;
          if (cellContent.contains('课程：') ||
              cellContent.contains('实验室：') ||
              cellContent.contains('教师：')) {
            /// TODO: CHECK ALL [cellIndex] and [rowIndex] stuff.
            List<String> dateNums = weekdays[cellIndex].split('/');
            String date = "${dateNums[1]}/${dateNums[2]}/${dateNums[0]}";

            String timeStr = "$date $periodName";

            List<String> contentList = cellContent.split('\n')
              ..removeWhere((e) => e.isEmpty)
              ..map((e) => e.trim());

            experimentData.add(
              ExperimentData(
                name: contentList[0].replaceAll("课程：", ""),
                score: "",
                classroom: contentList[1].replaceAll("实验室：", ""),
                date: date,
                timeStr: timeStr,
                teacher: contentList[2].replaceAll("教师：", ""),
                reference: "",
              ),
            );
          }
        });
      });
    }

    return (ExperimentFetchStatus.success, experimentData);
  }
}
