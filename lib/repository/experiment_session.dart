// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:charset_converter/charset_converter.dart';
import 'package:dio/dio.dart';
import 'package:html/parser.dart';
import 'package:watermeter/repository/logger.dart';
import 'package:watermeter/repository/preference.dart' as preference;
import 'package:watermeter/repository/network_session.dart';
import 'package:watermeter/model/xidian_ids/experiment.dart';

enum ExperimentFetchStatus { notSchoolNetwork, noPassword, success }

class ExperimentSession extends NetworkSession {
  @override
  Dio get dio => Dio()
    ..interceptors.add(logDioAdapter)
    ..options.contentType = Headers.formUrlEncodedContentType
    ..options.followRedirects = false
    ..options.responseDecoder = (responseBytes, options, responseBody) async {
      String gbk = await CharsetConverter.availableCharsets().then(
        (value) => value.firstWhere((element) => element.contains("18030")),
      );
      return await CharsetConverter.decode(
        gbk,
        Uint8List.fromList(responseBytes),
      );
    }
    ..options.validateStatus = (status) =>
        status != null && status >= 200 && status < 400;

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
        .then((value) => value.data);

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

    log.debug(
      "[experiment_session][getData] "
      "$selectInfo will be remembered...",
    );

    if (selectInfo[subject] != selectInfo.values.first) {
      log.debug(
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
          .then((value) => value.data);
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

  Future<(ExperimentFetchStatus, List<ExperimentData>)> getData() async {
    // if (await NetworkSession.isInSchool() == false) {
    //   return (ExperimentFetchStatus.notSchoolNetwork, <ExperimentData>[]);
    // }

    if (preference
        .getString(preference.Preference.experimentPassword)
        .isEmpty) {
      return (ExperimentFetchStatus.noPassword, <ExperimentData>[]);
    }

    log.debug(
      "[experiment_session][getData] "
      "Get login in experiment_session.",
    );

    var loginResponse = await dio.post(
      'http://wlsy.xidian.edu.cn/PhyEws/default.aspx',
      data:
          '__EVENTTARGET=&__EVENTARGUMENT=&'
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
      throw LoginFailedException()
        ..msg = parse(loginResponse.data)
            .getElementById("login1_Label1")
            ?.innerHtml
            .replaceAll("<font color=\"Red\">", "")
            .replaceAll("</font>", "")
            .replaceAll("<br>", "。");
    }

    cookieStr = "";

    log.debug(
      "[experiment_session][getData] "
      "Start fetching data.",
    );

    for (String i in loginResponse.headers[HttpHeaders.setCookieHeader] ?? []) {
      log.debug(
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

    log.debug(
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
        .then((value) => value.data);

    var expInfo =
        parse(
          data,
        ).getElementById("Orders_ctl00")?.getElementsByTagName('tr') ??
        [];

    log.debug(
      "[experiment_session][getData] "
      "Data have ${expInfo.length}.",
    );

    List<ExperimentData> toReturn = [];
    for (var i in expInfo) {
      var expTds = i.getElementsByTagName('td');
      if (expTds.isEmpty) continue;
      log.debug(
        "[experiment_session][getData] "
        "expTds have ${expTds.length}.",
      );

      String date = expTds[4].getElementsByTagName("span").first.innerHtml;
      List<int> dateNums = List<int>.generate(
        date.split('/').length,
        (index) => int.parse(date.split('/')[index]),
      );

      String timeStr = expTds[3].getElementsByTagName("span").first.innerHtml;
      (DateTime, DateTime) timeRange = timeStr.contains("15")
          ? (
              DateTime(dateNums[2], dateNums[0], dateNums[1], 15, 55, 00),
              DateTime(dateNums[2], dateNums[0], dateNums[1], 18, 10, 00),
            )
          : (
              DateTime(dateNums[2], dateNums[0], dateNums[1], 18, 30, 00),
              DateTime(dateNums[2], dateNums[0], dateNums[1], 20, 45, 00),
            ); // Evening 18:30～20:45

      toReturn.add(
        ExperimentData(
          type: ExperimentType.physics,
          name: expTds[1]
              .getElementsByClassName("linkSmallBold")
              .first
              .innerHtml
              .replaceAll('（3学时）', ''),
          score: expTds[7].getElementsByTagName("span").first.innerHtml,
          classroom: expTds[5].getElementsByTagName("span").first.innerHtml,
          timeRanges: [timeRange],
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
    return (ExperimentFetchStatus.success, toReturn);
  }

  /// Get the score image from the report system
  Future<Map<String, String>> getScoreImage(String account, String pwd) async {
    final commonHeaders = {
      HttpHeaders.acceptLanguageHeader: 'zh-CN,zh;q=0.9',
      HttpHeaders.userAgentHeader:
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36',
      HttpHeaders.acceptEncodingHeader: 'gzip, deflate, br',
      HttpHeaders.connectionHeader: 'keep-alive',
      'Origin': 'http://wlsy.xidian.edu.cn',
      HttpHeaders.refererHeader:
          'http://wlsy.xidian.edu.cn/wgyreport/wgyreport.dll/?id=stu',
    };

    final getHeaders = {
      ...commonHeaders,
      HttpHeaders.acceptHeader:
          'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7',
      'Upgrade-Insecure-Requests': '1',
      'X-Requested-With': 'XMLHttpRequest',
    };

    final postHeaders = {
      ...commonHeaders,
      HttpHeaders.contentTypeHeader:
          'application/x-www-form-urlencoded; charset=UTF-8',
      'X-Requested-With': 'XMLHttpRequest',
      HttpHeaders.acceptHeader: '*/*',
    };

    // Simple Cookie string manager
    String cookieStr = '';
    String sid = '';

    log.debug(
      "[experiment_session][getScoreImage] "
      "Send the first GET request",
    );

    var initQuest = await dio.get(
      'http://wlsy.xidian.edu.cn/wgyreport/wgyreport.dll/?id=stu',
      options: Options(headers: getHeaders),
    );

    // Extract the Session ID from html
    var responseData = initQuest.data.toString();
    var sidRegex = RegExp(r'(\d+_[a-zA-Z0-9]+111D[a-fA-F0-9]+)');
    var match = sidRegex.firstMatch(responseData);
    if (match != null) {
      sid = match.group(1) ?? '';
      cookieStr = 'UNI_GUI_SESSION_ID=$sid';
    }

    log.debug(
      "[experiment_session][getScoreImage] "
      "[initQuest Data - Length: ${responseData.length}]\n${responseData.substring(0, responseData.length > 500 ? 500 : responseData.length)}...\n"
      "[Cookie String]\n$cookieStr\n"
      "[Session ID]\n$sid\n",
    );

    // Send machine info to sever
    var postData =
        'Ajax=1&IsEvent=1&Obj=O0&Evt=cinfo&ci=br%3D33%3Bos%3D4%3Bbv%3D140%3Bww%3D2048%3Bwh%3D1018&_S_ID=$sid&_seq_=0&_uo_=O0';

    await dio.post(
      'http://wlsy.xidian.edu.cn/wgyreport/wgyreport.dll/HandleEvent',
      data: postData,
      options: Options(
        headers: {...postHeaders, HttpHeaders.cookieHeader: cookieStr},
      ),
    );

    // Send Move event
    log.debug(
      "[experiment_session][getScoreImage] "
      "Send the second POST request (Move)",
    );

    var movePostData =
        'Ajax=1&IsEvent=1&Obj=O0&Evt=move&this=O0&x=868&y=381&_S_ID=$sid&_seq_=1&_uo_=O0';

    await dio.post(
      'http://wlsy.xidian.edu.cn/wgyreport/wgyreport.dll/HandleEvent',
      data: movePostData,
      options: Options(
        headers: {...postHeaders, HttpHeaders.cookieHeader: cookieStr},
      ),
    );

    // Send Activate event
    log.debug(
      "[experiment_session][getScoreImage] "
      "Send the third POST request (Activate)",
    );

    var activatePostData =
        'Ajax=1&IsEvent=1&Obj=O0&Evt=activate&this=O0&_S_ID=$sid&_seq_=2&_uo_=O0';

    await dio.post(
      'http://wlsy.xidian.edu.cn/wgyreport/wgyreport.dll/HandleEvent',
      data: activatePostData,
      options: Options(
        headers: {...postHeaders, HttpHeaders.cookieHeader: cookieStr},
      ),
    );

    // Send resize event
    log.debug(
      "[experiment_session][getScoreImage] "
      "Send the fourth POST request (Resize)",
    );

    var resizePostData =
        'Ajax=1&IsEvent=1&Obj=O0&Evt=resize&this=O0&w=311&h=255&_S_ID=$sid&_seq_=3&_uo_=O0';

    dio.post(
      'http://wlsy.xidian.edu.cn/wgyreport/wgyreport.dll/HandleEvent',
      data: resizePostData,
      options: Options(
        headers: {...postHeaders, HttpHeaders.cookieHeader: cookieStr},
      ),
    );

    // Send click event, also as sign in
    log.debug(
      "[experiment_session][getScoreImage] "
      "Send the fifth POST request (Click)",
    );

    var clickPostData =
        'Ajax=1&IsEvent=1&Obj=O1F&Evt=click&this=O1F&_S_ID=$sid&_fp_=%26O17%3D%25020%2502%2502$account%26O1B%3D%25020%2502%2502$pwd&_seq_=4&_uo_=O0';

    var clickResponse = await dio.post(
      'http://wlsy.xidian.edu.cn/wgyreport/wgyreport.dll/HandleEvent',
      data: clickPostData,
      options: Options(
        headers: {...postHeaders, HttpHeaders.cookieHeader: cookieStr},
      ),
    );

    // Get the cookie sid
    var clickSetCookieHeaders = clickResponse.headers['set-cookie'];
    if (clickSetCookieHeaders != null && clickSetCookieHeaders.isNotEmpty) {
      for (var header in clickSetCookieHeaders) {
        if (header.startsWith('sid=')) {
          var sidValue = header.split(';')[0].split('=')[1];
          cookieStr = 'UNI_GUI_SESSION_ID=$sid; sid=$sidValue';
          log.debug(
            "[experiment_session][getScoreImage] "
            "[Updated Cookie String]\n$cookieStr",
          );
          break;
        }
      }
    }

    // Get the score information
    log.debug(
      "[experiment_session][getScoreImage] "
      "Send the final GET request",
    );

    var dataResponse = await dio.get(
      'http://wlsy.xidian.edu.cn/wgyreport/wgyreport.dll/HandleEvent',
      queryParameters: {
        'IsEvent': '1',
        'Obj': 'OA7',
        'Evt': 'data',
        '_dc': DateTime.now().millisecondsSinceEpoch,
        'start': '0',
        'limit': '25',
        'options': '1',
        'page': '1',
      },
      options: Options(
        headers: {
          ...commonHeaders,
          'X-Requested-With': 'XMLHttpRequest',
          'UniSessionId': sid,
          '_S_ID': sid,
          HttpHeaders.acceptHeader: '*/*',
          HttpHeaders.cookieHeader: cookieStr,
        },
      ),
    );

    // Parse the information and get the result
    Map<String, String> experimentInfo = _extractExperimentInfo(
      dataResponse.data,
    );

    log.debug('[experiment_session][getScoreImage]', experimentInfo);

    return experimentInfo;
  }

  /// Extract the score information from the raw data
  Map<String, String> _extractExperimentInfo(dynamic responseData) {
    Map<String, String> result = {};

    try {
      // Process the escape character
      String jsonString = responseData
          .toString()
          .replaceAll(r'\x3C', '<')
          .replaceAll(r'\x3E', '>');

      // parse the json data
      Map<String, dynamic> jsonData = jsonDecode(jsonString);

      List<dynamic> rows = jsonData['rows'] ?? [];

      for (var row in rows) {
        String experimentName = row['1'] ?? '';

        String imageHtml = row['2'] ?? '';

        RegExp srcRegex = RegExp(r'src="([^"]+)"');
        Match? match = srcRegex.firstMatch(imageHtml);

        if (match != null && experimentName.isNotEmpty) {
          String imageUrl = match.group(1) ?? '';

          if (imageUrl.startsWith('/')) {
            imageUrl = 'http://wlsy.xidian.edu.cn$imageUrl';
          }
          result[experimentName] = imageUrl;
        }
      }
    } catch (e) {
      log.error(
        '[experiment_session][getScoreImage]', 
        'Fail to parse JSON: $e',
      );
    }

    return result;
  }
}

class LoginFailedException implements Exception {
  String? msg;
}

class FailedToFetchException implements Exception {}

class NotFoundTeacherException implements Exception {}

class NoExperimentPasswordException implements Exception {}

class ExperimentClosedException implements Exception {}
