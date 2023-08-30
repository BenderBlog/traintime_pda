// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

// IDS (统一认证服务) login class.
// Thanks xidian-script and libxdauth!

import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';
import 'package:beautiful_soup_dart/beautiful_soup.dart';
import 'package:dio/dio.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:watermeter/repository/network_session.dart';
import 'package:watermeter/repository/preference.dart' as preference;

class IDSSession extends NetworkSession {
  @override
  Dio get dio => super.dio
    ..interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          developer.log("Offline status: $offline",
              name: "OfflineCheckInspector");
          if (offline) {
            handler.reject(
              DioException.requestCancelled(
                reason: "Offline mode, all ids function unuseable.",
                requestOptions: options,
              ),
            );
          } else {
            handler.next(options);
          }
        },
      ),
    );

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

  Future<Response> checkAndLogin({
    required String target,
  }) async {
    developer.log("Ready to get $target.", name: "ids checkAndLogin");
    var data = await dio.get(
      "https://ids.xidian.edu.cn/authserver/login",
      queryParameters: {
        'service': target,
      },
    );
    developer.log("Received: $data.", name: "ids checkAndLogin");
    if (data.statusCode == 401) {
      throw PasswordWrongException();
    } else if (data.statusCode == 301 || data.statusCode == 302) {
      /// Post login progress.
      while (data.headers[HttpHeaders.locationHeader] != null) {
        String location = data.headers[HttpHeaders.locationHeader]![0];
        developer.log("Received: $location.", name: "ids checkAndLogin");
        data = await dio.get(location);
      }
      return data;
    } else {
      return await login(
        username: preference.getString(preference.Preference.idsAccount),
        password: preference.getString(preference.Preference.idsPassword),
      );
    }
  }

  Future<Response> login({
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
    var response = await dio
        .get("https://ids.xidian.edu.cn/authserver/login")
        .then((value) => value.data);

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
      if (captcha == null) {
        throw NeedCaptchaException;
      }
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
      data: head,
    );
    if (data.statusCode == 401) {
      throw PasswordWrongException();
    } else if (data.statusCode == 301 || data.statusCode == 302) {
      /// Post login progress.
      if (onResponse != null) {
        onResponse(80, "登录后处理");
      }
      while (data.headers[HttpHeaders.locationHeader] != null) {
        String location = data.headers[HttpHeaders.locationHeader]![0];
        developer.log("Received: $location.", name: "ids login");
        data = await dio.get(location);
      }
      return data;
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
