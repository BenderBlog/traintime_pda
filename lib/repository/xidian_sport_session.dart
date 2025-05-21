// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

// Get data from Xidian Sport.

import 'dart:convert';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:encrypt/encrypt.dart';
import 'package:synchronized/synchronized.dart';
import 'package:watermeter/model/xidian_sport/sport_class.dart';
import 'package:watermeter/repository/logger.dart';
import 'package:get/get.dart';
import 'package:watermeter/repository/network_session.dart';
import 'package:watermeter/repository/preference.dart' as preference;
import 'package:watermeter/model/xidian_sport/score.dart';

var sportClass = SportClass().obs;
var sportScore = SportScore().obs;
// var punchData = PunchDataList().obs;

class SportSession {
  static final _lock = Lock();

  final PersistCookieJar sportCookieJar = PersistCookieJar(
    persistSession: true,
    storage: FileStorage("${supportPath.path}/cookie/sport/"),
  );

  /*
  Future<void> getPunch() async {
    punchData.value.reset();
    try {
      await login();

      var getStore = await require(
        subWebsite: "stuTermPunchRecord/findList",
        body: {'userId': userId},
      );
      punchData.value.score.value = getStore["data"][0]["score"];
      //String termId = await getTermID();

      log.info(
        "[SportSession][getPunch] "
        "Ready to fetch all punch info.",
      );

      await require(
        subWebsite: "stuPunchRecord/findPager",
        body: {
          'sysTermId': 13, //await getTermID(),
          'pageSize': 999,
          'pageIndex': 1
        },
      ).then((response) {
        for (var i in response["data"]) {
          punchData.value.all.add(PunchData(
            i["machineName"],
            i["weekNum"],
            Jiffy.parse(i["punchDay"] + " " + i["punchTime"]),
            i["state"],
          ));
        }
        punchData.value.all.sort((a, b) => a.time.diff(b.time).toInt());
        punchData.value.allTime.value = punchData.value.all.length;
      });

      log.info(
        "[SportSession][getPunch] "
        "Ready to fetch successful punch info.",
      );

      await require(
        subWebsite: "stuPunchRecord/findPagerOk",
        body: {
          'sysTermId': 13, //await getTermID(),
          'pageSize': 999,
          'pageIndex': 1
        },
      ).then((response) {
        for (var i in response["data"]) {
          punchData.value.valid.add(PunchData(
            i["machineName"],
            i["weekNum"],
            Jiffy.parse(i["punchDay"] + " " + i["punchTime"]),
            i["state"],
          ));
        }
        punchData.value.valid.sort((a, b) => a.time.diff(b.time).toInt());
        punchData.value.validTime.value = punchData.value.valid.length;
      });

      punchData.value.situation.value = "";
    } on NoPasswordException {
      punchData.value.situation.value = "没密码";
    } on LoginFailedException catch (e, s) {
      log.warning(
        "[SportSession][getPunch] LoginFailedException",
        error: e,
        stackTrace: s,
      );
      punchData.value.situation.value = e.msg == "系统维护" ? e.msg : "登录失败";
    } on SemesterFailedException catch (e, s) {
      log.warning(
        "[SportSession][getPunch] SemesterFailedException",
        error: e,
        stackTrace: s,
      );
      punchData.value.situation.value = "查询失败";
    } on DioException catch (e, s) {
      log.warning(
        "[SportSession][getPunch] NetWorkExceptions",
        error: e,
        stackTrace: s,
      );
      punchData.value.situation.value = "网络故障";
    } catch (e, s) {
      log.warning(
        "[SportSession][getPunch] Exception",
        error: e,
        stackTrace: s,
      );
      punchData.value.situation.value = "未知故障";
    } finally {
      punchData.value.isLoad.value = false;
    }
  }
  */

  Future<void> getScore() async {
    sportScore.value.situation = "situation_fetching";
    log.info(
      "[SportSession][getScore]"
      "Ready to get sport score.",
    );
    SportScore toReturn = SportScore();
    try {
      await _lock.synchronized(() async {
        if (userId.isEmpty || token.isEmpty) {
          await login();
        }
      });

      var response = await require(
        subWebsite: "measure/getStuTotalScore",
        body: {"userId": userId},
      );
      for (var i in response["data"]) {
        if (i.keys.contains("graduationStatus")) {
          toReturn.total = i["totalScore"];
          toReturn.detail = i["gradeType"];
          toReturn.rank = i['rank'];
        } else {
          SportScoreOfYear toAdd = SportScoreOfYear(
            year: i["year"],
            totalScore: i["totalScore"],
            rank: i["rank"],
            gradeType: i["gradeType"],
          );
          var anotherResponse = await require(
            subWebsite: "measure/getStuScoreDetail",
            body: {"meaScoreId": i["meaScoreId"]},
          );
          if (anotherResponse["returnCode"] != "200") {
            toAdd.moreinfo += anotherResponse["returnMsg"].toString();
          } else {
            for (var i in anotherResponse["data"]) {
              toAdd.details.add(
                SportItems(
                  examName: i["examName"],
                  examunit: i["examunit"],
                  actualScore: i["actualScore"] ?? "0",
                  score: i["score"] ?? 0.0,
                  rank: i["rank"] ?? "不及格",
                ),
              );
            }
          }

          toReturn.list.add(toAdd);
        }
      }
    } on NoPasswordException {
      toReturn.situation = "sport.situation_nopassword";
    } on LoginFailedException catch (e, s) {
      log.handle(e, s);
      toReturn.situation = e.msg == "sport.situation_maintain"
          ? e.msg
          : "sport.situation_failed_login";
    } on SemesterFailedException catch (e, s) {
      log.handle(e, s);
      toReturn.situation = "sport.situation_query";
    } on DioException catch (e, s) {
      log.handle(e, s);
      toReturn.situation = "sport.situation_network";
    } catch (e, s) {
      log.handle(e, s);
      toReturn.situation = "sport.situation_unknown\n: $e at\n$s";
    } finally {
      sportScore.value = toReturn;
    }
  }

  Future<void> getClass() async {
    sportClass.value.situation = "sport.situation_fetching";
    log.info(
      "[SportSession][getClass]"
      "Ready to get latest class.",
    );
    SportClass toReturn = SportClass();
    try {
      await _lock.synchronized(() async {
        if (userId.isEmpty || token.isEmpty) {
          await login();
        }
      });
      var response = await require(
        subWebsite: "stuTermScore/uidSelect",
        body: {
          "uid": userId,
          "pageIndex": "1",
          "pageSize": "100",
        },
      );
      for (var i in response["data"]) {
        try {
          int latestId = i["id"];
          var classData = await require(
            subWebsite: "stuTeacherCurriculum/selstuTeacherCurriculum",
            body: {
              "stuid": userId,
              "stuTermScoreid": latestId,
            },
          ).then((value) => value["data"][0]);
          toReturn.items.add(SportClassItem.fromData(
            termName: classData["teacherCurriculumSysTermName"],
            name: classData["teacherCurriculumTeachingCurriculumName"],
            teacher: classData["teacherCurriculumSysUserName"],
            time: classData["teacherCurriculumTeachingSchoolTimeName"],
            place: classData["teacherCurriculumTeachingAddressName"],
            score: i["score"],
            type: i["type"],
          ));
        } catch (e, s) {
          log.handle(e, s);
          continue;
        }
      }
    } on NoPasswordException {
      toReturn.situation = "sport.situation_nopassword";
    } on LoginFailedException catch (e, s) {
      log.handle(e, s);
      toReturn.situation = e.msg == "sport.situation_maintain"
          ? e.msg
          : "sport.situation_failed_login";
    } on SemesterFailedException catch (e, s) {
      log.handle(e, s);
      toReturn.situation = "sport.situation_query";
    } on DioException catch (e, s) {
      log.handle(e, s);
      toReturn.situation = "sport.situation_network";
    } catch (e, s) {
      log.handle(e, s);
      toReturn.situation = "sport.situation_unknown\n: $e at\n$s";
    } finally {
      sportClass.value = toReturn;
    }
  }

  /// Get base64 encoded data. Which is rsa encrypted [toEnc] using [pubKey].
  String rsaEncrypt(String toEnc, String pubKey) {
    dynamic publicKey = RSAKeyParser().parse(pubKey);
    return Encrypter(RSA(publicKey: publicKey)).encrypt(toEnc).base64;
  }

  static var userId = '';

  static var token = '';

  final baseURL = 'http://tybjxgl.xidian.edu.cn/app/';

  final rsaKey = """-----BEGIN PUBLIC KEY-----
MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAq4l
aolA7zAk7jzsqDb3Oa5pS/uCPlZfASK8Soh/NzEmry77QDZ
2koyr96M5Wx+A9cxwewQMHzi8RoOfb3UcQO4UDQlMUImLuz
Unfbk3TTppijSLH+PU88XQxcgYm2JTa546c7JdZSI6dBeXO
JH20quuxWyzgLk9jAlt3ytYygPQ7C6o6ZSmjcMgE3xgLaHG
vixEVpOjL/pdVLzXhrMqWVAnB/snMjpCqesDVTDe5c6OOmj
2q5J8n+tzIXtnvrkxQSDaUp8DWF8meMwyTErmYklMXzKic2
rjdYZpHh4x98Fg0Q28sp6i2ZoWiGrJDKW29mntVQQiDNhKD
awb4B45zUwIDAQAB
-----END PUBLIC KEY-----""";

  final commonHeader = {
    'channel': 'H5',
    'version': '99999',
    'type': '0',
  };

  Map<String, String> get header => commonHeader
    ..addAll({
      "token": token,
    });

  final commonSignParams = {
    'appId': '3685bc028aaf4e64ad6b5d2349d24ba8',
    'appSecret': 'e8167ef026cbc5e456ab837d9d6d9254'
  };

  String _getSign(Map<String, dynamic> params) {
    var toCalculate = '';
    // Map in dart is not sorted by keys:-O
    for (var i in params.keys.toList()..sort()) {
      toCalculate += "&$i=${params[i]}";
    }
    // sure it is hexString.
    return md5.convert(utf8.encode(toCalculate.substring(1))).toString();
  }

  Map<String, dynamic> _getHead(Map<String, dynamic> payload) {
    Map<String, dynamic> toReturn = header;
    toReturn["timestamp"] = DateTime.now().millisecondsSinceEpoch.toString();
    Map<String, dynamic> forSign = payload;
    forSign["timestamp"] = toReturn["timestamp"];
    toReturn['sign'] = _getSign(forSign);
    return toReturn;
  }

  /// Maybe I wrote how to store the data is better.
  Dio get _dio {
    Dio toReturn = Dio(BaseOptions(
      baseUrl: baseURL,
      contentType: Headers.formUrlEncodedContentType,
    ));
    toReturn.interceptors.add(CookieManager(sportCookieJar));
    toReturn.interceptors.add(logDioAdapter);
    return toReturn;
  }

  Future<Map<String, dynamic>> require({
    required String subWebsite,
    required Map<String, dynamic> body,
    bool isForce = false,
  }) async {
    var response = await _dio.post(subWebsite,
        data: body, options: Options(headers: _getHead(body)));
    return response.data;
  }

  Future<void> login() async {
    if (preference.getString(preference.Preference.idsAccount).isEmpty ||
        preference.getString(preference.Preference.sportPassword).isEmpty) {
      throw NoPasswordException();
    }
    if (userId.isNotEmpty && token.isNotEmpty) {
      log.info(
        "[SportSession][login]"
        "Already login.",
      );
      return;
    }

    late Map<String, dynamic> response;

    try {
      response = await require(
        subWebsite: "/h5/login",
        body: {
          "uname": preference.getString(preference.Preference.idsAccount),
          "pwd": rsaEncrypt(
            preference.getString(preference.Preference.sportPassword),
            rsaKey,
          ),
          "openid": ""
        },
      );
      if (response["returnCode"] != "200" && response["returnCode"] != 200) {
        throw LoginFailedException(msg: response["returnMsg"]);
      } else {
        userId = response["data"]["id"].toString();
        token = response["data"]["token"];
      }
    } on DioException catch (e) {
      if (e.message?.contains("404") ?? false) {
        throw const LoginFailedException(msg: "系统维护");
      }
      rethrow;
    }
  }

  Future<String> getTermID() async {
    var response =
        await require(subWebsite: "/stuTermPunchRecord/findList", body: {
      'userId': userId,
    });
    if (response["returnCode"] == "200") {
      return response["data"][0]["sysTermId"].toString();
    } else {
      throw SemesterFailedException(msg: response["returnMsg"]);
    }
  }
}

class NoPasswordException implements Exception {}

class LoginFailedException implements Exception {
  final String msg;
  const LoginFailedException({required this.msg});

  @override
  String toString() => msg;
}

class SemesterFailedException implements Exception {
  final String msg;
  const SemesterFailedException({required this.msg});

  @override
  String toString() => msg;
}
