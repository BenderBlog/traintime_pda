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
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:encrypt/encrypt.dart';
import 'package:watermeter/model/user.dart';
import 'package:watermeter/repository/general.dart';
import 'dart:developer' as developer;

/// Get base64 encoded data. Which is rsa encrypted [toEnc] using [pubKey].
String rsaEncrypt(String toEnc, String pubKey) {
  dynamic publicKey = RSAKeyParser().parse(pubKey);
  return Encrypter(RSA(publicKey: publicKey)).encrypt(toEnc).base64;
}

var userId = '';

const baseURL = 'http://xd.5itsn.com/app/';

const rsaKey = """-----BEGIN PUBLIC KEY-----
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

/// Maybe I wrote how to store the data is better.
Dio get _dio {
  Dio toReturn = Dio(BaseOptions(
    baseUrl: baseURL,
    contentType: Headers.formUrlEncodedContentType,
  ));
  toReturn.interceptors.add(CookieManager(SportCookieJar));
  return toReturn;
}

Future<Map<String, dynamic>> require({
  required String subWebsite,
  required Map<String, dynamic> body,
  bool isForce = false,
}) async {
  body.addAll(commonSignParams);
  var response = await _dio.post(subWebsite,
      data: body, options: Options(headers: _getHead(body)));
  return response.data;
}

Future<void> login() async {
  if (user["idsAccount"] == null ||
      user["sportPassword"] == "" ||
      user["sportPassword"] == null) {
    throw NoPasswordException();
  }
  if (userId != "") {
    developer.log("已经登录成功", name: "SportSession");
    return;
  }
  var response = await require(
    subWebsite: "/h5/login",
    body: {
      "uname": user["idsAccount"],
      "pwd": rsaEncrypt(user["sportPassword"]!, rsaKey),
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
