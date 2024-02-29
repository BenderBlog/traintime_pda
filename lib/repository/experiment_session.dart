// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:charset_converter/charset_converter.dart';
import 'package:dio/dio.dart';
import 'package:html/parser.dart';
import 'package:watermeter/repository/logger.dart';
import 'package:watermeter/repository/preference.dart' as preference;
import 'package:watermeter/repository/network_session.dart';
import 'package:watermeter/model/xidian_ids/experiment.dart';

class ExperimentSession extends NetworkSession {
  static const experimentCacheName = "Experiment.json";
  @override
  Dio get dio => Dio()
    ..interceptors.add(alice.getDioInterceptor())
    ..options.contentType = Headers.formUrlEncodedContentType
    ..options.followRedirects = false
    ..options.responseDecoder = (responseBytes, options, responseBody) async {
      String gbk = await CharsetConverter.availableCharsets().then(
          (value) => value.firstWhere((element) => element.contains("18030")));
      return await CharsetConverter.decode(
        gbk,
        Uint8List.fromList(responseBytes),
      );
    }
    ..options.validateStatus =
        (status) => status != null && status >= 200 && status < 400;

  static Map<String, String> selectInfo = {};
  String cookieStr = "";

  /// This function is used to fetch the teacher for the experiment class.
  Future<String> teacher({
    required String time,
    required String subject,
  }) async {
    RegExp weekGet = RegExp(
      r'<span id="plan1_PlanGrid_TimeN_[0-9]{1,2}">(?<week>(.*))</span>',
    );
    RegExp teacherGet = RegExp(
      r'<span id="plan1_PlanGrid_Teacher_[0-9]{1,2}">(?<teacher>(.*))</span>',
    );
    /*
    RegExp headerGet = RegExp(
      r'<input type="hidden" name="(?<name>(.*))" id="(?<id>(.*))" value="(?<value>(.*))">',
    );*/

    /// Get inside
    String page = await dio
        .get(
          "http://wlsy.xidian.edu.cn/PhyEws/student/course.aspx",
          options: Options(
            headers: {
              HttpHeaders.cookieHeader: cookieStr,
              HttpHeaders.hostHeader: "wlsy.xidian.edu.cn",
            },
          ),
        )
        .then(
          (value) => value.data,
        );

    /// Fetch heder
    /// headerGet.allMatches(page).toList();
    /*
    String header = publicHeader;
    var hiddenItems = BeautifulSoup(page).findAll("input");
    if (hiddenItems.isEmpty) throw FailedToFetchException;
    for (var i in hiddenItems) {
      if (["__EVENTTARGET", "__EVENTARGUMENT", "__LASTFOCUS"].contains(i.id)) {
        continue;
      }
      header += "${i.id}=${Uri.encodeFull(i.getAttrValue("value") ?? "")}&";
    }
    */

    /// Init the select info if necessary
    if (selectInfo.isEmpty) {
      var expInfo = parse(page).getElementById("plan1_ExpeList")!.children;
      for (var i in expInfo) {
        selectInfo[i.innerHtml] = i.attributes["value"]!;
      }
    }

    log.d(
      "[experiment_session][getData] "
      "$selectInfo will be remembered...",
    );

    if (selectInfo[subject] != selectInfo.values.first) {
      log.d(
        "[experiment_session][getData] "
        "${selectInfo[subject]} ferching...",
      );

      Map<String, String> dataToSend = {};

      parse(page)
          .getElementsByTagName("input")
          .forEach((e) => dataToSend[e.id] = e.attributes["value"]!);
      dataToSend["__EVENTTARGET"] = "plan1\$ExpeList";
      dataToSend["plan1\$ExpeList"] = selectInfo[subject]!;

      page = await dio
          .post(
            "http://wlsy.xidian.edu.cn/PhyEws/student/course.aspx",
            data: FormData.fromMap(dataToSend),
            options: Options(
              headers: {
                HttpHeaders.cookieHeader: cookieStr,
                HttpHeaders.hostHeader: "wlsy.xidian.edu.cn",
              },
            ),
          )
          .then(
            (value) => value.data,
          );
    }
    var weekInfo = weekGet.allMatches(page).toList();
    var teacherInfo = teacherGet.allMatches(page).toList();

    for (int i = 0; i < weekInfo.length; ++i) {
      if (weekInfo[i].namedGroup('week')?.contains(time) ?? false) {
        return teacherInfo[i].namedGroup('teacher')!;
      }
    }

    throw NotFoundTeacherException;
  }

  Future<List<ExperimentData>> getData() async {
    log.i(
      "[experiment_session][getData] "
      "Path at ${supportPath.path}.",
    );
    var file = File("${supportPath.path}/$experimentCacheName");
    bool isExist = file.existsSync();
    log.i(
      "[experiment_session][getData] "
      "File exist: $isExist.",
    );
    try {
      if (await NetworkSession.isInSchool() == false) {
        throw NotSchoolNetworkException;
      }

      if (preference
          .getString(preference.Preference.experimentPassword)
          .isEmpty) {
        throw NoExperimentPasswordException;
      }

      log.d(
        "[experiment_session][getData] "
        "Get login in experiment_session.",
      );

      var loginResponse = await dio.post(
        'http://wlsy.xidian.edu.cn/PhyEws/default.aspx',
        data: '__EVENTTARGET=&__EVENTARGUMENT=&'
            '__VIEWSTATE=%2FwEPDwUKMTEzNzM0MjM0OWQYAQUeX19D'
            'b250cm9sc1JlcXVpcmVQb3N0QmFja0tleV9fFgEFD2xvZ2luMSRidG5Mb2dpbkOuzGVaztce4Ict7jsIJ0F5pUDb%2BsmSbCCrNVSBlPML&'
            '__VIEWSTATEGENERATOR=EE008CD9&'
            '__EVENTVALIDATION=%2FwEdAAcKecdPGDB%2BfW8Tyghx'
            '7AeSpOzeiNZ7aaEg5p6LqSa9cODI2bZwNtRxUKPkisVLf8l'
            '8Vv4WhRVIIhZlyYNJO%2BySrDKOhP%2B%2FYMNbVIh74hA2r'
            'CYnBBSTsX9SjxiYNNk%2B5kglM%2B6pGIq22Oi5mNu6u6eC2W'
            'EBfKAmATKwSpsOL%2FPNcRyi9l8Dnp6JamksyAzjhW4%3D&'
            'login1%24StuLoginID=${preference.getString(preference.Preference.idsAccount)}&'
            'login1%24StuPassword=${preference.getString(preference.Preference.experimentPassword)}&'
            'login1%24UserRole=Student&'
            'login1%24btnLogin.x=28&'
            'login1%24btnLogin.y=14',
      );

      if (loginResponse.statusCode != 302) {
        throw LoginFailedException();
      }

      cookieStr = "";

      log.d(
        "[experiment_session][getData] "
        "Start fetching data.",
      );

      for (String i
          in loginResponse.headers[HttpHeaders.setCookieHeader] ?? []) {
        log.d(
          "[experiment_session][getData] "
          "Cookie $i.",
        );
        if (i.contains("PhyEws_StuName")) {
          /// This guy find out the secret.
          cookieStr += "PhyEws_StuName=waterfloatinggenderly; ";
        } else if (i.contains('HttpOnly')) {
          continue;
        } else {
          cookieStr += '${i.split(';')[0]}; ';
        }
      }

      log.d(
        "[experiment_session][getData] "
        "Cookie is $cookieStr.",
      );

      var data = await dio
          .get(
            "http://wlsy.xidian.edu.cn/PhyEws/student/select.aspx",
            options: Options(
              headers: {
                HttpHeaders.cookieHeader: cookieStr,
                HttpHeaders.hostHeader: "wlsy.xidian.edu.cn",
              },
            ),
          )
          .then(
            (value) => value.data,
          );

      var expInfo = parse(data)
              .getElementById("Orders_ctl00")
              ?.getElementsByTagName('tr') ??
          [];

      log.d(
        "[experiment_session][getData] "
        "Data have ${expInfo.length}.",
      );

      List<ExperimentData> toReturn = [];
      for (var i in expInfo) {
        var expTds = i.getElementsByTagName('td');
        if (expTds.isEmpty) continue;
        log.d(
          "[experiment_session][getData] "
          "expTds have ${expTds.length}.",
        );

        toReturn.add(
          ExperimentData(
            name: expTds[1]
                .getElementsByClassName("linkSmallBold")
                .first
                .innerHtml,
            score: expTds[7].getElementsByTagName("span").first.innerHtml,
            classroom: expTds[5].getElementsByTagName("span").first.innerHtml,
            date: expTds[4].getElementsByTagName("span").first.innerHtml,
            timeStr: expTds[3].getElementsByTagName("span").first.innerHtml,
            reference: expTds[9].getElementsByTagName("span").first.innerHtml,
            teacher: await teacher(
              time: expTds[3].getElementsByTagName("span").first.innerHtml,
              subject: expTds[1]
                  .getElementsByClassName("linkSmallBold")
                  .first
                  .innerHtml
                  .replaceAll('（3学时）', ''),
            ),
          ),
        );
      }

      log.i(
        "[experiment_session][getData] "
        "Evaluating cache. ${jsonEncode(toReturn)}.",
      );
      if (isExist) {
        log.i(
          "[experiment_session][getData] "
          "Refreshing cache...",
        );
        file.deleteSync();
      }

      file.writeAsStringSync(jsonEncode(toReturn));
      return toReturn;
    } catch (e, s) {
      log.i(
        "[experiment_session][getData] "
        "Exception with $e\nstacktrace $s",
      );
      if (isExist) {
        log.i(
          "[experiment_session][getData] "
          "Using cache...",
        );
        List<dynamic> data = jsonDecode(file.readAsStringSync());
        return List<ExperimentData>.generate(
          data.length,
          (index) => ExperimentData.fromJson(data[index]),
        );
      } else {
        rethrow;
      }
    }
  }
}

class LoginFailedException implements Exception {}

class FailedToFetchException implements Exception {}

class NotFoundTeacherException implements Exception {}

class NoExperimentPasswordException implements Exception {}

class ExperimentClosedException implements Exception {}
