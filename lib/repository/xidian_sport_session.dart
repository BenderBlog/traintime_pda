// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

// Get data from Xidian Sport.

import 'dart:convert';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:encrypter_plus/encrypter_plus.dart';
import 'package:synchronized/synchronized.dart';
import 'package:watermeter/model/fetch_result.dart';
import 'package:watermeter/model/password_exceptions.dart';
import 'package:watermeter/model/xidian_sport/sport_class.dart';
import 'package:watermeter/model/xidian_sport/sport_score.dart';
import 'package:watermeter/repository/logger.dart';
import 'package:watermeter/repository/network_session.dart';
import 'package:watermeter/repository/preference.dart' as preference;

class SportSession {
  static final _lock = Lock();
  static const _cacheHintMissingPasswordKey =
      "sport.cache_hint_missing_password";
  static const _cacheHintCredentialInvalidKey =
      "sport.cache_hint_credential_invalid";
  static const _cacheHintMaintainKey = "sport.cache_hint_maintain";
  static const _cacheHintLoginFailedKey = "sport.cache_hint_login_failed";
  static const _cacheHintQueryFailedKey = "sport.cache_hint_query_failed";
  static const _cacheHintNetworkKey = "sport.cache_hint_network";
  static const _cacheHintUnknownKey = "sport.cache_hint_unknown";
  static const _authExpiredMessageKey = "sport.error_auth_expired";
  static const _credentialInvalidMessageKey = "sport.error_credential_invalid";
  static const _credentialMissingMessageKey = "sport.error_missing_password";
  static const _wrongPasswordKeywords = {"用户名", "账号", "密码"};
  static const _authFailureKeywords = {
    "未登录",
    "登录失效",
    "自动登录失效",
    "token失效",
    "重新登录",
  };

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

  static SportScore? _scoreCache;
  static DateTime _scoreCacheFetchTime = DateTime.now();
  static SportClass? _classCache;
  static DateTime _classCacheFetchTime = DateTime.now();

  // First bool stands for cache, second bool stands for fetch time.
  Future<FetchResult<SportScore>> getScore() async {
    log.info(
      "[SportSession][getScore]"
      "Ready to get sport score.",
    );
    SportScore toReturn = SportScore();
    try {
      await _ensureAuthenticated();

      var response = await _authenticatedRequire(
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
          var anotherResponse = await _authenticatedRequire(
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
      _scoreCache = toReturn;
      _scoreCacheFetchTime = DateTime.now();
      log.info(
        "[SportSession][getScore] Score cache updated at $_scoreCacheFetchTime",
      );
      return FetchResult.fresh(fetchTime: _scoreCacheFetchTime, data: toReturn);
    } catch (e, s) {
      log.handle(
        e,
        s,
        "[SportSession][getScore] Error occured, and cache ${_scoreCache != null ? "exist" : "not exist"}",
      );
      if (_scoreCache != null) {
        return FetchResult.cache(
          fetchTime: _scoreCacheFetchTime,
          data: _scoreCache!,
          hintKey: _cacheHintFromError(e),
        );
      } else {
        rethrow;
      }
    }
    // } on NoPasswordException {
    //   toReturn.situation = "sport.situation_nopassword";
    // } on LoginFailedException catch (e, s) {
    //   log.handle(e, s);
    //   toReturn.situation = e.msg == "sport.situation_maintain"
    //       ? e.msg
    //       : "sport.situation_failed_login";
    // } on SemesterFailedException catch (e, s) {
    //   log.handle(e, s);
    //   toReturn.situation = "sport.situation_query";
    // } on DioException catch (e, s) {
    //   log.handle(e, s);
    //   toReturn.situation = "sport.situation_network";
    // } catch (e, s) {
    //   log.handle(e, s);
    //   toReturn.situation = "sport.situation_unknown\n: $e at\n$s";
    // }
  }

  Future<FetchResult<SportClass>> getClass() async {
    log.info(
      "[SportSession][getClass]"
      "Ready to get latest class.",
    );
    SportClass toReturn = [];
    try {
      await _ensureAuthenticated();
      var response = await _authenticatedRequire(
        subWebsite: "stuTermScore/uidSelect",
        body: {"uid": userId, "pageIndex": "1", "pageSize": "100"},
      );
      for (var i in response["data"]) {
        try {
          int latestId = i["id"];
          var classData = await _authenticatedRequire(
            subWebsite: "stuTeacherCurriculum/selstuTeacherCurriculum",
            body: {"stuid": userId, "stuTermScoreid": latestId},
          ).then((value) => value["data"][0]);
          toReturn.add(
            SportClassItem.fromData(
              termName: classData["teacherCurriculumSysTermName"],
              name: classData["teacherCurriculumTeachingCurriculumName"],
              teacher: classData["teacherCurriculumSysUserName"],
              time: classData["teacherCurriculumTeachingSchoolTimeName"],
              place: classData["teacherCurriculumTeachingAddressName"],
              score: i["score"],
              type: i["type"],
            ),
          );
        } catch (e, s) {
          log.handle(e, s);
          continue;
        }
      }

      _classCache = toReturn;
      _classCacheFetchTime = DateTime.now();
      log.info(
        "[SportSession][getScore] Class cache updated at $_classCacheFetchTime",
      );
      return FetchResult.fresh(
        fetchTime: _classCacheFetchTime,
        data: _classCache!,
      );
    } catch (e, s) {
      log.handle(
        e,
        s,
        "[SportSession][getClass] Error occured, and cache ${_classCache != null ? "exist" : "not exist"}",
      );
      if (_classCache != null) {
        log.warning("[SportSession][getClass] Use cache.");
        return FetchResult.cache(
          fetchTime: _classCacheFetchTime,
          data: _classCache!,
          hintKey: _cacheHintFromError(e),
        );
      } else {
        rethrow;
      }
    }
    // } on NoPasswordException {
    //   toReturn.situation = "sport.situation_nopassword";
    // } on LoginFailedException catch (e, s) {
    //   log.handle(e, s);
    //   toReturn.situation = e.msg == "sport.situation_maintain"
    //       ? e.msg
    //       : "sport.situation_failed_login";
    // } on SemesterFailedException catch (e, s) {
    //   log.handle(e, s);
    //   toReturn.situation = "sport.situation_query";
    // } on DioException catch (e, s) {
    //   log.handle(e, s);
    //   toReturn.situation = "sport.situation_network";
    // } catch (e, s) {
    //   log.handle(e, s);
    //   toReturn.situation = "sport.situation_unknown\n: $e at\n$s";
    // }
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

  final commonHeader = {'channel': 'H5', 'version': '99999', 'type': '0'};

  Map<String, String> get header => commonHeader..addAll({"token": token});

  final commonSignParams = {
    'appId': '3685bc028aaf4e64ad6b5d2349d24ba8',
    'appSecret': 'e8167ef026cbc5e456ab837d9d6d9254',
  };

  Future<void> _ensureAuthenticated({bool force = false}) async {
    await _lock.synchronized(() async {
      if (!force && userId.isNotEmpty && token.isNotEmpty) {
        return;
      }
      try {
        await login(force: force);
      } on NoPasswordException {
        throw const SportCredentialMissingException();
      } on WrongPasswordException {
        throw const SportCredentialInvalidException();
      } on LoginFailedException catch (e) {
        if (e.msg == "系统维护") {
          rethrow;
        }
        rethrow;
      }
    });
  }

  bool _isAuthFailureResponse(Map<String, dynamic> response) {
    final returnCode = response["returnCode"]?.toString();
    if (returnCode == "401" || returnCode == "402") {
      return true;
    }
    final returnMsg =
        response["returnMsg"]?.toString() ?? response["msg"]?.toString() ?? "";
    return _authFailureKeywords.any(returnMsg.contains);
  }

  bool _isAuthFailureDioException(DioException e) {
    final statusCode = e.response?.statusCode;
    if (statusCode == 401 || statusCode == 402) {
      return true;
    }

    final responseData = e.response?.data;
    if (responseData is Map<String, dynamic> &&
        _isAuthFailureResponse(responseData)) {
      return true;
    }

    final rawMessage = [
      e.message,
      e.response?.statusMessage,
      responseData?.toString(),
    ].whereType<String>().join(" ");
    return _authFailureKeywords.any(rawMessage.contains);
  }

  bool _isWrongPasswordMessage(String message) {
    return _wrongPasswordKeywords.any(message.contains);
  }

  String? _cacheHintFromError(Object error) {
    if (error is SportCredentialMissingException) {
      return _cacheHintMissingPasswordKey;
    }
    if (error is SportCredentialInvalidException) {
      return _cacheHintCredentialInvalidKey;
    }
    if (error is LoginFailedException) {
      return error.msg == "系统维护"
          ? _cacheHintMaintainKey
          : _cacheHintLoginFailedKey;
    }
    if (error is SemesterFailedException) {
      return _cacheHintQueryFailedKey;
    }
    if (error is DioException) {
      return _cacheHintNetworkKey;
    }
    return _cacheHintUnknownKey;
  }

  Future<Map<String, dynamic>> _authenticatedRequire({
    required String subWebsite,
    required Map<String, dynamic> body,
    bool allowRetry = true,
  }) async {
    try {
      final response = await require(
        subWebsite: subWebsite,
        body: Map<String, dynamic>.from(body),
      );
      if (_isAuthFailureResponse(response)) {
        throw const SportAuthExpiredException();
      }
      return response;
    } on DioException catch (e) {
      if (allowRetry && _isAuthFailureDioException(e)) {
        return _retryAfterReAuth(subWebsite: subWebsite, body: body);
      }
      rethrow;
    } on SportAuthExpiredException {
      if (allowRetry) {
        return _retryAfterReAuth(subWebsite: subWebsite, body: body);
      }
      throw const SportCredentialInvalidException();
    }
  }

  Future<Map<String, dynamic>> _retryAfterReAuth({
    required String subWebsite,
    required Map<String, dynamic> body,
  }) async {
    log.warning(
      "[SportSession][_retryAfterReAuth] "
      "Auth state expired, trying to login again.",
    );

    /// Clear Auth State
    userId = '';
    token = '';
    await sportCookieJar.deleteAll();

    await _ensureAuthenticated(force: true);

    try {
      final response = await require(
        subWebsite: subWebsite,
        body: Map<String, dynamic>.from(body),
      );
      if (_isAuthFailureResponse(response)) {
        throw const SportCredentialInvalidException();
      }
      return response;
    } on DioException catch (e) {
      if (_isAuthFailureDioException(e)) {
        throw const SportCredentialInvalidException();
      }
      rethrow;
    }
  }

  /// Get base64 encoded data. Which is rsa encrypted [toEnc] using [pubKey].
  static String _rsaEncrypt(String toEnc, String pubKey) {
    dynamic publicKey = RSAKeyParser().parse(pubKey);
    return Encrypter(RSA(publicKey: publicKey)).encrypt(toEnc).base64;
  }

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
    Dio toReturn = Dio(
      BaseOptions(
        baseUrl: baseURL,
        contentType: Headers.formUrlEncodedContentType,
      ),
    );
    toReturn.interceptors.add(CookieManager(sportCookieJar));
    toReturn.interceptors.add(logDioAdapter);
    return toReturn;
  }

  Future<Map<String, dynamic>> require({
    required String subWebsite,
    required Map<String, dynamic> body,
    bool isForce = false,
  }) async {
    var response = await _dio.post(
      subWebsite,
      data: body,
      options: Options(headers: _getHead(body)),
    );
    return response.data;
  }

  Future<void> login({bool force = false}) async {
    if (preference.getString(preference.Preference.idsAccount).isEmpty ||
        preference.getString(preference.Preference.sportPassword).isEmpty) {
      throw NoPasswordException(type: PasswordType.sport);
    }
    if (!force && userId.isNotEmpty && token.isNotEmpty) {
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
          "pwd": _rsaEncrypt(
            preference.getString(preference.Preference.sportPassword),
            rsaKey,
          ),
          "openid": "",
        },
      );
      if (response["returnCode"] != "200" && response["returnCode"] != 200) {
        final returnMsg = response["returnMsg"]?.toString() ?? "";
        if (_isWrongPasswordMessage(returnMsg)) {
          throw const WrongPasswordException(type: PasswordType.sport);
        }
        throw LoginFailedException(msg: returnMsg);
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
    var response = await require(
      subWebsite: "/stuTermPunchRecord/findList",
      body: {'userId': userId},
    );
    if (response["returnCode"] == "200") {
      return response["data"][0]["sysTermId"].toString();
    } else {
      throw SemesterFailedException(msg: response["returnMsg"]);
    }
  }
}

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

class SportAuthExpiredException implements Exception {
  const SportAuthExpiredException();

  @override
  String toString() => SportSession._authExpiredMessageKey;
}

class SportCredentialMissingException implements Exception {
  const SportCredentialMissingException();

  @override
  String toString() => SportSession._credentialMissingMessageKey;
}

class SportCredentialInvalidException implements Exception {
  const SportCredentialInvalidException();

  @override
  String toString() => SportSession._credentialInvalidMessageKey;
}
