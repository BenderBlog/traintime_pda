// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:charset_converter/charset_converter.dart';
import 'package:dio/dio.dart';
import 'package:html/parser.dart';
import 'package:pool/pool.dart';
import 'package:watermeter/bridge/save_to_groupid.g.dart';
import 'package:watermeter/model/fetch_result.dart';
import 'package:watermeter/model/not_school_network_exception.dart';
import 'package:watermeter/model/password_exceptions.dart';
import 'package:watermeter/repository/experiment_score/image_recognition.dart';
import 'package:watermeter/repository/logger.dart';
import 'package:watermeter/repository/preference.dart' as prefs;
import 'package:watermeter/repository/network_session.dart';
import 'package:watermeter/model/xidian_ids/experiment.dart';
import 'package:watermeter/repository/xidian_ids/ids_session.dart';

Future<FetchResult<List<ExperimentData>>> getPhysicsExperimentData() async {
  try {
    List<ExperimentData> data = await ExperimentSession().getData();
    DateTime fetchTime = DateTime.now();
    await ExperimentSession.writeCache(data);
    return FetchResult.fresh(fetchTime: fetchTime, data: data);
  } on PasswordWrongException {
    log.error(
      "[ExperimentSession][getExperimentData] "
      "Password changed, remove cache",
    );
    await ExperimentSession.deleteCache();
    rethrow;
  } catch (e, s) {
    log.handle(e, s, "[ExperimentSession][getExperimentData] Have issue");
    var cache = ExperimentSession.getCache();
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

class ExperimentSession extends NetworkSession {
  static const physicsExperimentCacheName = "PhysicsExperiment.json";
  static File physicsExperimentCacheFile = File(
    "${supportPath.path}/$physicsExperimentCacheName",
  );
  static bool get isCacheExist => physicsExperimentCacheFile.existsSync();

  static Future<void> deleteCache() async {
    if (await physicsExperimentCacheFile.exists()) {
      await physicsExperimentCacheFile.delete();
    }
  }

  static Future<void> writeCache(List<ExperimentData> data) async {
    log.info(
      "[ExperimentSession][writeCache] "
      "Store to cache.",
    );
    physicsExperimentCacheFile.writeAsStringSync(jsonEncode(data));
    if (Platform.isIOS) {
      final api = SaveToGroupIdSwiftApi();
      try {
        bool result = await api.saveToGroupId(
          FileToGroupID(
            appid: prefs.appId,
            fileName: physicsExperimentCacheName,
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
        physicsExperimentCacheFile.readAsStringSync(),
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
        physicsExperimentCacheFile.deleteSync();
        return null;
      }

      DateTime lastUpdateTime = physicsExperimentCacheFile.lastModifiedSync();
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

  Future<List<ExperimentData>> getData() async {
    if (await NetworkSession.isInSchool() == false) {
      throw NotSchoolNetworkException();
    }

    if (prefs.getString(prefs.Preference.experimentPassword).isEmpty) {
      throw NoPasswordException(type: PasswordType.physicsExperiment);
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
          'login1%24StuLoginID=${prefs.getString(prefs.Preference.idsAccount)}&'
          'login1%24StuPassword=${prefs.getString(prefs.Preference.experimentPassword)}&'
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

    final scoreImageRecognitionService = ImageRecognitionService();

    final Map<String, RecognitionResult> scoreResults = {};

    try {
      scoreResults.addAll(
        await scoreImageRecognitionService.recognizeAllScores(),
      );
    } catch (e) {
      log.error(
        "[experiment_session][getData]"
        "Failed to recognize scores, skipping score fetch to parse schedule: $e",
      );
    }

    Pool pool = Pool(3);

    await Future.wait([
      ...expInfo.map(
        (i) => pool.withResource(() async {
          var expTds = i.getElementsByTagName('td');
          if (expTds.isEmpty) return;
          log.debug(
            "[experiment_session][getData] "
            "expTds have ${expTds.length}.",
          );

          String date = expTds[4].getElementsByTagName("span").first.innerHtml;
          List<int> dateNums = List<int>.generate(
            date.split('/').length,
            (index) => int.parse(date.split('/')[index]),
          );

          String timeStr = expTds[3]
              .getElementsByTagName("span")
              .first
              .innerHtml;
          (DateTime, DateTime) timeRange = timeStr.contains("15")
              ? (
                  DateTime(dateNums[2], dateNums[0], dateNums[1], 15, 55, 00),
                  DateTime(dateNums[2], dateNums[0], dateNums[1], 18, 10, 00),
                )
              : (
                  DateTime(dateNums[2], dateNums[0], dateNums[1], 18, 30, 00),
                  DateTime(dateNums[2], dateNums[0], dateNums[1], 20, 45, 00),
                ); // Evening 18:30～20:45

          final name = expTds[1]
              .getElementsByClassName("linkSmallBold")
              .first
              .innerHtml
              .replaceAll('（3学时）', '');

          toReturn.add(
            ExperimentData(
              type: ExperimentType.physics,
              name: name,
              score: scoreResults[name],
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
        }),
      ),
    ]);
    return toReturn;
  }
}

class LoginFailedException implements Exception {
  String? msg;
}

class FailedToFetchException implements Exception {}

class NotFoundTeacherException implements Exception {}

class NoExperimentPasswordException implements Exception {}

class ExperimentClosedException implements Exception {}
