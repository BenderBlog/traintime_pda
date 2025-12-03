// Copyright 2025 BenderBlog Rodriguez and contributors.
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'dart:io';

import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:watermeter/model/xidian_ids/class_attendance.dart';
import 'package:watermeter/repository/logger.dart';
import 'package:watermeter/page/login/jc_captcha.dart';
import 'package:watermeter/repository/xidian_ids/ids_session.dart';

class LearningSession extends IDSSession {
  static const LOGIN_URL = "https://xdspoc.fanya.chaoxing.com/sso/xdspoc";
  static const COURSE_DATA_URL =
      "https://fycourse.fanya.chaoxing.com/courselist/studyCourseDatashow";

  static String userId = "";

  Future<List<ClassAttendance>> getAttandanceRecord() async {
    log.info("[LearningSession][getAttandanceRecord] Finding the record...");
    String? location = await checkAndLogin(
      target: LOGIN_URL,
      sliderCaptcha: (String cookieStr) =>
          SliderCaptchaClientProvider(cookie: cookieStr).solve(null),
    );

    while (location != null) {
      var response = await dio.get(location);
      log.info(
        "[LearningSession][getAttandanceRecord] Received location: $location.",
      );
      location = response.headers[HttpHeaders.locationHeader]?[0];
    }

    log.info(
      "[LearningSession][getAttandanceRecord] Fetching class attendance table.",
    );
    String html = await dio.get(COURSE_DATA_URL).then((data) => data.data);

    Document document = parse(html);
    List<ClassAttendance> results = [];

    Element? tableContainer = document.querySelector('.w_tab_cont');
    Element? table = tableContainer?.querySelector('table');

    if (table == null) {
      return results;
    }

    List<Element> rows = table.querySelectorAll('tbody tr');

    for (var row in rows) {
      List<Element> cells = row.querySelectorAll('td');
      if (cells.length < 17) {
        continue;
      }

      List<String> rowData = cells.map((td) => td.text.trim()).toList();
      if (!rowData[8].contains('-')) {
        results.add(
          ClassAttendance(
            courseName: rowData[0],
            className: rowData[1],
            checkInCount: rowData[2],
            personalLeave: rowData[3],
            sickLeave: rowData[4],
            officialLeave: rowData[5],
            absenceCount: rowData[6],
            requiredCheckIn: rowData[7],
            attendanceRate: rowData[8],
            readCount: rowData[9],
            unreadCount: rowData[10],
            accessCount: rowData[11],
            taskProgress: rowData[12],
            homeworkProgress: rowData[13],
            examProgress: rowData[14],
            discussionCount: rowData[15],
            materialCount: rowData[16],
          ),
        );
      }
    }

    return results;
  }
}
