// Copyright 2025 BenderBlog Rodriguez and contributors.
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

// ignore_for_file: constant_identifier_names

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:watermeter/model/xidian_ids/class_attendance.dart';
import 'package:watermeter/repository/logger.dart';
import 'package:watermeter/page/login/jc_captcha.dart';
import 'package:watermeter/repository/xidian_ids/ids_session.dart';

class LearningSession extends IDSSession {
  static const LOGIN_URL = "https://xdspoc.fanya.chaoxing.com/sso/xdspoc";
  static const COURSE_INFO_URL =
      "https://fycourse.fanya.chaoxing.com/courselist/study";
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

    log.info("[LearningSession][getAttandanceRecord] Fetching class list info");
    String courseListHtml = await dio
        .get(
          COURSE_INFO_URL,
          options: Options(
            headers: {HttpHeaders.hostHeader: "fycourse.fanya.chaoxing.com"},
          ),
        )
        .then((data) => data.data);

    final doc = parse(courseListHtml);

    String semester =
        doc
            .getElementById("yearList")
            ?.children
            .firstWhere(
              (ele) => ele.attributes["selected"]?.contains("true") ?? false,
            )
            .attributes["value"] ??
        "";
    log.info(
      "[LearningSession][getAttandanceRecord] Fetching semester $semester",
    );

    final items = doc.querySelectorAll('div.myde_course_item');

    final resultsClassInfo = <Map<String, String>>[];
    final seen = <String>{}; // 用 courseId|clazzId 去重

    for (final item in items) {
      final cnameAttr = (item.attributes['cname'] ?? '').trim();
      final dtText = item.querySelector('dl.myde_course_dl > dt')?.text ?? "";
      final courseNameFromDt = dtText
          .replaceAll(RegExp(r'\s*\(.*?\)\s*$'), '')
          .trim();
      final courseName = cnameAttr.isNotEmpty ? cnameAttr : courseNameFromDt;

      // dd[0]=老师 dd[1]=班级 dd[2]=开课时间
      final dds = item.querySelectorAll('dl.myde_course_dl > dd');
      final teacher = dds.isNotEmpty ? dds[0].text : '';
      final classNo = dds.length >= 2 ? dds[1].text : '';
      // final startDate = dds.length >= 3
      //     ? extractDate(cleanText(dds[2].text))
      //     : '';

      // 从 href 解析：courseId/clazzId/cpi
      final href =
          item
              .querySelector('div.myde_course_pic a[href]')
              ?.attributes['href'] ??
          '';
      String courseId = '';
      String clazzId = '';
      String cpi = '';

      if (href.isNotEmpty) {
        final uri = Uri.tryParse(
          href.startsWith('http') ? href : 'https://dummy$href',
        );
        if (uri != null) {
          courseId = (uri.queryParameters['courseId'] ?? '').trim();
          clazzId = (uri.queryParameters['clazzId'] ?? '').trim();
          cpi = (uri.queryParameters['cpi'] ?? '').trim();
        }
      }

      // 如果 href 里没有，兜底用 cid 当 courseId（很多情况下相同）
      if (courseId.isEmpty) courseId = (item.attributes['cid'] ?? '').trim();

      // 基本校验
      if (courseId.isEmpty || clazzId.isEmpty) continue;

      final key = '$courseId|$clazzId';
      if (!seen.add(key)) continue;

      resultsClassInfo.add({
        "courseId": courseId,
        "clazzId": clazzId,
        "cpi": cpi,
        "courseName": courseName,
        "teacher": teacher,
        "classNo": classNo,
        // "startDate": startDate,
      });
    }

    log.info(
      "[LearningSession][getAttandanceRecord] Fetching class attendance table.",
    );
    String html = await dio
        .get(
          COURSE_DATA_URL,
          queryParameters: {"v": 1, "semesternum": semester},
          options: Options(
            headers: {HttpHeaders.hostHeader: "fycourse.fanya.chaoxing.com"},
          ),
        )
        .then(
          (data) => data.data.toString().replaceAll(RegExp(r'\r|\n|\t'), ""),
        );

    Document document = parse(html);
    List<ClassAttendance> results = [];

    Element? table = document.querySelector('table');

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
      Map<String, String> data = resultsClassInfo.firstWhere(
        (data) =>
            data["courseName"] == rowData[0] && data["classNo"] == rowData[1],
        orElse: () => {},
      );
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
          courseId: data["courseId"],
          clazzId: data["clazzId"],
          cpi: data["cpi"],
        ),
      );
    }

    return results;
  }
}
