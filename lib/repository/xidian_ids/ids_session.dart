// ignore_for_file: prefer_final_fields

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
import 'dart:io';
import 'dart:developer' as developer;
import 'package:beautiful_soup_dart/beautiful_soup.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter/material.dart';
import 'package:watermeter/repository/general.dart';

/// Get base64 encoded data. Which is aes encrypted [toEnc] encoded string using [key].
/// Padding part is copied from libxduauth's idea.
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

class IDSSession {
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

  @protected
  Dio get dio {
    Dio toReturn = Dio(BaseOptions(
      contentType: Headers.formUrlEncodedContentType,
      headers: {
        HttpHeaders.userAgentHeader:
            "Mozilla/5.0 (Linux; Android 11; KB2000 Build/RP1A.201005.001; wv)"
                "AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/86.0.4240.99"
                "XWEB/3263 MMWEBSDK/20211001 Mobile Safari/537.36 MMWEBID/3667"
                "MicroMessenger/8.0.16.2040(0x28001037) Process/toolsmp WeChat/arm64"
                "Weixin NetType/WIFI Language/zh_CN ABI/arm64"
      },
    ));
    toReturn.interceptors.add(CookieManager(IDSCookieJar));
    return toReturn;
  }

  Future<bool> isLoggedIn() async {
    var response =
        await dio.post("http://ids.xidian.edu.cn/authserver/index.do",
            options: Options(
              followRedirects: false,
              validateStatus: (status) => status! < 500,
            ));
    developer.log(
        "isLoggedIn result: ${response.statusCode == 302 ? true : false}",
        name: "ids isLoggedIn");
    return response.statusCode == 302 ? false : true;
  }

  Future<void> login({
    required String username,
    required String password,
    required String target,
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
      "http://ids.xidian.edu.cn/authserver/login",
      queryParameters: {'service': target, 'type': 'userNameLogin'},
    ).then((value) => value.data);

    /// Start getting data from webpage.
    var page = BeautifulSoup(response);
    var form = page.findAll("input", attrs: {"type": "hidden"});

    /// Check whether it need CAPTCHA or not:-P
    if (onResponse != null) {
      onResponse(20, "查询是否需要验证码");
    }
    var checkCAPTCHA = await dio.get(
      "http://ids.xidian.edu.cn/authserver/checkNeedCaptcha.htl",
      queryParameters: {
        'username': username,
        '_': DateTime.now().millisecondsSinceEpoch.toString()
      },
    ).then((value) => value.data);
    bool isNeed = checkCAPTCHA.contains("true");
    developer.log("isNeedCAPTCHA: $isNeed.", name: "ids login");
    String? captcha;
    if (isNeed && getCaptcha != null) {
      var cookie = await IDSCookieJar.loadForRequest(
          Uri.parse("http://ids.xidian.edu.cn/authserver"));
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
      "http://ids.xidian.edu.cn/authserver/login",
      queryParameters: {'service': target},
      options: Options(
        followRedirects: false,
        validateStatus: (status) {
          return status! < 500;
        },
      ),
      data: head,
    );
    developer.log("Received: $data.", name: "ids login");
    if (data.statusCode == 401) {
      throw PasswordWrongException();
    } else if (data.statusCode == 301 || data.statusCode == 302) {
      /// Post login progress.
      if (onResponse != null) {
        onResponse(80, "登录后处理");
      }
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
}

class NeedCaptchaException implements Exception {}

class PasswordWrongException implements Exception {}

class LoginFailedException implements Exception {
  final String msg;
  const LoginFailedException({required this.msg});
  @override
  String toString() => msg;
}
