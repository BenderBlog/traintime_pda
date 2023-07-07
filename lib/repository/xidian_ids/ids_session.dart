/*
IDS login class.
Copyright 2022 SuperBart

This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.

Please refer to ADDITIONAL TERMS APPLIED TO WATERMETER SOURCE CODE
if you want to use.
*/

import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';
import 'package:beautiful_soup_dart/beautiful_soup.dart';
import 'package:dio/dio.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:watermeter/repository/network_session.dart';
import 'package:watermeter/repository/preference.dart';

class IDSSession extends NetworkSession {
  /// Get base64 encoded data. Which is aes encrypted [toEnc] encoded string using [key].
  /// Padding part is libxduauth's idea.
  String aesEncrypt(String toEnc, String key) {
    dynamic k = encrypt.Key.fromUtf8(key);
    var crypt = encrypt.AES(k, mode: encrypt.AESMode.cbc, padding: null);

    /// Start padding
    int blockSize = 16;
    List<int> dataToPad = [];
    dataToPad.addAll(utf8.encode(
        "xidianscriptsxduxidianscriptsxduxidianscriptsxduxidianscriptsxdu$toEnc"));
    int paddingLength = blockSize - dataToPad.length % blockSize;
    for (var i = 0; i < paddingLength; ++i) {
      dataToPad.add(paddingLength);
    }
    String readyToEnc = utf8.decode(dataToPad);

    /// Start encrypt.
    return encrypt.Encrypter(crypt)
        .encrypt(readyToEnc, iv: encrypt.IV.fromUtf8('xidianscriptsxdu'))
        .base64;
  }

  static const _header = [
    // "username",
    // "password",
    // "captcha",
    //"_eventId",
    "lt",
    //"cllt",
    //"dllt",
    "execution",
  ];

  Future<bool> isLoggedIn() async {
    var response =
        await dio.post("https://ids.xidian.edu.cn/authserver/index.do",
            options: Options(
              followRedirects: false,
              validateStatus: (status) => status! < 500,
            ));
    developer.log(
        "isLoggedIn result: ${response.headers[HttpHeaders.locationHeader]!.contains("personalInfo")}",
        name: "ids isLoggedIn");
    return response.headers[HttpHeaders.locationHeader]
            ?.contains("personalInfo") ??
        false;
  }

  Future<void> checkAndLogin({
    required String target,
  }) async {
    bool response = await dio
        .get("https://ids.xidian.edu.cn/authserver/index.do",
            options: Options(
              followRedirects: false,
              validateStatus: (status) => status! < 500,
            ))
        .then((value) =>
            value.headers["location"]?.contains("personalInfo") ?? false);

    if (!response) {
      login(
        username: getString(Preference.idsAccount),
        password: getString(Preference.idsPassword),
      );
    }

    var data = await dio.get(
      "https://ids.xidian.edu.cn/authserver/login",
      queryParameters: {
        'service': target,
      },
      options: Options(
        followRedirects: false,
        validateStatus: (status) {
          return status! < 500;
        },
      ),
    );
    developer.log("Received: $data.", name: "ids login");
    if (data.statusCode == 401) {
      throw PasswordWrongException();
    } else if (data.statusCode == 301 || data.statusCode == 302) {
      /// Post login progress.
      developer.log("Post deal...", name: "ids login");
      await dio.get(
        data.headers['location']![0],
        options: Options(
          followRedirects: false,
          validateStatus: (status) {
            return status! < 500;
          },
        ),
      );
      return;
    } else {
      throw LoginFailedException(msg: "未知失败，返回代码${data.statusCode}.");
    }
  }

  Future<void> login({
    required String username,
    required String password,
    Future<String?> Function(String)? getCaptcha,
    bool forceReLogin = false,
    void Function(int, String)? onResponse,
  }) async {
    /// Get the login webpage.
    if (onResponse != null) {
      onResponse(10, "准备获取登录网页");
      developer.log("Ready to get the login webpage.", name: "ids login");
    }
    var response = await dio.get(
      "https://ids.xidian.edu.cn/authserver/login",
      queryParameters: {
        'service':
            "https://ehall.xidian.edu.cn/login?service=https://ehall.xidian.edu.cn/new/index.html",
        'type': 'userNameLogin',
      },
    ).then((value) => value.data);

    /// Start getting data from webpage.
    var page = BeautifulSoup(response);
    var form = page.findAll("input", attrs: {"type": "hidden"});

    /// Check whether it need CAPTCHA or not:-P
    if (onResponse != null) {
      onResponse(20, "查询是否需要验证码");
    }
    var checkCAPTCHA = await dio.get(
      "https://ids.xidian.edu.cn/authserver/checkNeedCaptcha.htl",
      queryParameters: {
        'username': username,
        '_': DateTime.now().millisecondsSinceEpoch.toString()
      },
    ).then((value) => value.data);
    bool isNeed = checkCAPTCHA.contains("true");
    developer.log("isNeedCAPTCHA: $isNeed.", name: "ids login");
    String? captcha;
    if (isNeed && getCaptcha != null) {
      var cookie = await cookieJar
          .loadForRequest(Uri.parse("https://ids.xidian.edu.cn/authserver"));
      String cookieStr = "";
      for (var i in cookie) {
        cookieStr += "${i.name}=${i.value}; ";
      }
      developer.log("cookie: $cookieStr.", name: "ids login");
      captcha = await getCaptcha(cookieStr);
      developer.log("captcha: $captcha.", name: "ids login");
      if (captcha == null) return;
    } else if (isNeed && getCaptcha == null) {
      throw NeedCaptchaException();
    }

    /// Get AES encrypt key. There must be.
    if (onResponse != null) {
      onResponse(30, "获取密码加密密钥");
    }
    String keys = form
        .firstWhere((element) => element["id"] == "pwdEncryptSalt")["value"]!;
    developer.log("encrypt key: $keys.", name: "ids login");

    /// Prepare for login.
    if (onResponse != null) {
      onResponse(40, "准备登录");
    }
    Map<String, dynamic> head = {
      'username': username,
      'password': aesEncrypt(password, keys),
      'rememberMe': 'true',
      'cllt': 'userNameLogin',
      'dllt': 'generalLogin',
      '_eventId': 'submit',
    };

    if (captcha != null) {
      head["captcha"] = captcha;
    }

    for (var i in _header) {
      head[i] = form.firstWhere(
          (element) => element["name"] == i || element.id == i)["value"]!;
    }

    /// Post login request.
    if (onResponse != null) {
      onResponse(50, "准备登录");
    }
    var data = await dio.post(
      "https://ids.xidian.edu.cn/authserver/login",
      queryParameters: {
        'service':
            "https://ehall.xidian.edu.cn/login?service=https://ehall.xidian.edu.cn/new/index.html",
      },
      options: Options(
        followRedirects: false,
        validateStatus: (status) {
          return status! < 500;
        },
      ),
      data: head,
    );
    if (data.statusCode == 401) {
      throw PasswordWrongException();
    } else if (data.statusCode == 301 || data.statusCode == 302) {
      /// Post login progress.
      if (onResponse != null) {
        onResponse(80, "登录后处理");
      }
      String location = data.headers['location']![0];
      developer.log("Received: $location.", name: "ids login");
      location = await dio
          .get(
            location,
            options: Options(
              followRedirects: false,
              validateStatus: (status) {
                return status! < 500;
              },
            ),
          )
          .then((value) => data.headers['location']?[0] ?? "");
      developer.log("Received: $location.", name: "ids login");
      return;
    } else {
      throw LoginFailedException(msg: "未知失败，返回代码${data.statusCode}.");
    }
  }
}

class NeedCaptchaException implements Exception {}

class PasswordWrongException implements Exception {}

class LoginFailedException implements Exception {
  final String msg;
  const LoginFailedException({required this.msg});
  @override
  String toString() => msg;
}
