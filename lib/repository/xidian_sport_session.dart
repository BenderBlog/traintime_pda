/*
Get data from Xidian Sport.
Copyright 2022 SuperBart

This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.

Please refer to ADDITIONAL TERMS APPLIED TO WATERMETER SOURCE CODE
if you want to use.
*/

import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:encrypt/encrypt.dart';
import 'package:get/get.dart';
import 'package:jiffy/jiffy.dart';
import 'package:watermeter/repository/preference.dart' as preference;
import 'package:watermeter/model/xidian_sport/punch.dart';
import 'package:watermeter/model/xidian_sport/score.dart';
import 'package:watermeter/repository/network_session.dart';
import 'dart:developer' as developer;

var punchData = PunchDataList().obs;
var sportScore = SportScore().obs;

class SportSession extends NetworkSession {
  /// Get base64 encoded data. Which is rsa encrypted [toEnc] using [pubKey].
  String rsaEncrypt(String toEnc, String pubKey) {
    dynamic publicKey = RSAKeyParser().parse(pubKey);
    return Encrypter(RSA(publicKey: publicKey)).encrypt(toEnc).base64;
  }

  var userId = '';

  final baseURL = 'https://xd.5itsn.com/app/';

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

  final commonSignParams = {
    'appId': '3685bc028aaf4e64ad6b5d2349d24ba8',
    'appSecret': 'e8167ef026cbc5e456ab837d9d6d9254'
  };

  String getSign(Map<String, dynamic> params) {
    var toCalculate = '';
    // Map in dart is not sorted by keys:-O
    for (var i in params.keys.toList()..sort()) {
      toCalculate += "&$i=${params[i]}";
    }
    // sure it is hexString.
    return md5.convert(utf8.encode(toCalculate.substring(1))).toString();
  }

  Map<String, dynamic> _getHead(Map<String, dynamic> payload) {
    Map<String, dynamic> toReturn = commonHeader;
    toReturn["timestamp"] = DateTime.now().millisecondsSinceEpoch.toString();
    Map<String, dynamic> forSign = payload;
    forSign["timestamp"] = toReturn["timestamp"];
    toReturn['sign'] = getSign(forSign);
    return toReturn;
  }

  Future<Map<String, dynamic>> require({
    required String subWebsite,
    required Map<String, dynamic> body,
    bool isForce = false,
  }) async {
    body.addAll(commonSignParams);
    var response = await dio.post(subWebsite,
        data: body, options: Options(headers: _getHead(body)));
    return response.data;
  }

  Future<void> login() async {
    if (preference.getString(preference.Preference.idsAccount).isEmpty ||
        preference.getString(preference.Preference.sportPassword).isEmpty) {
      throw NoPasswordException();
    }
    if (userId != "") {
      developer.log("已经登录成功", name: "SportSession");
      return;
    }
    var response = await require(
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
      commonHeader["token"] = response["data"]["token"];
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

  Future<void> getScore() async {
    sportScore.value.situation = "正在获取";
    developer.log("开始获取打卡信息", name: "GetPunchSession");
    SportScore toReturn = SportScore();
    try {
      if (userId == "") {
        await login();
      }
      var response = await require(
        subWebsite: "measure/getStuTotalScore",
        body: {"userId": userId},
      );
      for (var i in response["data"]) {
        if (i.keys.contains("graduationStatus")) {
          toReturn.total = i["totalScore"];
          toReturn.detail = i["gradeType"];
        } else {
          SportScoreOfYear toAdd = SportScoreOfYear(
              year: i["year"],
              totalScore: i["totalScore"],
              rank: i["rank"],
              gradeType: i["gradeType"]);
          var anotherResponse = await require(
            subWebsite: "measure/getStuScoreDetail",
            body: {"meaScoreId": i["meaScoreId"]},
          );
          for (var i in anotherResponse["data"]) {
            toAdd.details.add(SportItems(
                examName: i["examName"],
                examunit: i["examunit"],
                actualScore: i["actualScore"] ?? "0",
                score: i["score"] ?? 0.0,
                rank: i["rank"] ?? "不及格"));
          }
          toReturn.list.add(toAdd);
        }
      }
    } on NoPasswordException {
      toReturn.situation = "无密码信息";
    } on LoginFailedException catch (e) {
      developer.log("登录失败：$e", name: "GetPunchSession");
      toReturn.situation = "登录失败";
    } on SemesterFailedException catch (e) {
      developer.log("未获取学期值：$e", name: "GetPunchSession");
      toReturn.situation = "未获取学期值";
    } on DioException catch (e) {
      developer.log("网络故障：$e", name: "GetPunchSession");
      toReturn.situation = "网络故障";
    } catch (e) {
      developer.log("未知故障：$e", name: "GetPunchSession");
      toReturn.situation = "未知故障";
    } finally {
      sportScore.value = toReturn;
    }
  }

  Future<void> getPunch() async {
    punchData.value.situation = "正在获取";
    PunchDataList toReturn = PunchDataList();
    try {
      if (userId == "") {
        await login();
      }
      var getStore = await require(
        subWebsite: "stuTermPunchRecord/findList",
        body: {'userId': userId},
      );
      toReturn.score = getStore["data"][0]["score"];
      var response = await require(
        subWebsite: "stuPunchRecord/findPager",
        body: {
          'userNum': preference.getString(preference.Preference.idsAccount),
          'sysTermId': await getTermID(),
          'pageSize': 999,
          'pageIndex': 1
        },
      );
      for (var i in response["data"]) {
        toReturn.allTime++;
        if (i["state"].toString().contains("恭喜你本次打卡成功")) {
          toReturn.valid++;
        }
        toReturn.all.add(PunchData(
          i["machineName"],
          i["weekNum"],
          Jiffy.parse(i["punchDay"] + " " + i["punchTime"]),
          i["state"],
        ));
      }
      toReturn.all.sort((a, b) => a.time.diff(b.time).toInt());
      toReturn.allTime++;
      toReturn.valid++;
    } on NoPasswordException {
      toReturn.situation = "无密码信息";
    } on LoginFailedException catch (e) {
      developer.log("登录失败：$e", name: "GetPunchSession");
      toReturn.situation = "登录失败";
    } on SemesterFailedException catch (e) {
      developer.log("未获取学期值：$e", name: "GetPunchSession");
      toReturn.situation = "未获取学期值";
    } on DioException catch (e) {
      developer.log("网络故障：$e", name: "GetPunchSession");
      toReturn.situation = "网络故障";
    } catch (e) {
      developer.log("未知故障：$e", name: "GetPunchSession");
      toReturn.situation = "未知故障";
    } finally {
      punchData.value = toReturn;
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
