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

enum IDSLoginState {
  none,
  requesting,
  success,
  fail,

  /// Indicate that the user will login via LoginWindow
  manual,
}

IDSLoginState loginState = IDSLoginState.none;

bool get offline =>
    loginState != IDSLoginState.success && loginState != IDSLoginState.manual;

class IDSSession extends NetworkSession {
  @override
  Dio get dio => super.dio
    ..interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          developer.log(
            "Offline status: $offline",
            name: "OfflineCheckInspector",
          );
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

  Dio get dioNoOfflineCheck => super.dio;

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

  String _parsePasswordWrongMsg(String html) {
    var page = BeautifulSoup(html);
    var form = page.findAll("span", attrs: {
      "id": "showErrorTip",
    })[0];
    var msg = form.children[0].string;

    // Simplify the error message because there is no '找回密码' button here XD.
    // "用户名或密码有误，用户名为工号/学号，如果确认用户名无误，请点‘找回密码’自助重置密码。"
    if (msg.contains(RegExp(r"(用户名|密码).*误", unicode: true, dotAll: true))) {
      msg = "用户名或密码有误。";
    }
    return msg;
  }

  Future<String> checkAndLogin({
    required String target,
    Future<void> Function(String)? sliderCaptcha,
  }) async {
    developer.log("Ready to get $target.", name: "ids checkAndLogin");
    var data = await dioNoOfflineCheck.get(
      "https://ids.xidian.edu.cn/authserver/login",
      queryParameters: {'service': target},
    );
    developer.log("Received: $data.", name: "ids checkAndLogin");
    if (data.statusCode == 401) {
      throw PasswordWrongException(msg: _parsePasswordWrongMsg(data.data));
    } else if (data.statusCode == 301 || data.statusCode == 302) {
      /// Post login progress, due to something wrong, return the location here...
      return data.headers[HttpHeaders.locationHeader]![0];
    } else {
      return await login(
        username: preference.getString(preference.Preference.idsAccount),
        password: preference.getString(preference.Preference.idsPassword),
        sliderCaptcha: sliderCaptcha,
        target: target,
      );
    }
  }

  Future<String> login({
    required String username,
    required String password,

    /// TODO: remove this goddame ?.
    Future<void> Function(String)? sliderCaptcha,
    bool forceReLogin = false,
    void Function(int, String)? onResponse,
    String? target,
  }) async {
    /// Get the login webpage.
    if (onResponse != null) {
      onResponse(10, "准备获取登录网页");
      developer.log("Ready to get the login webpage.", name: "ids login");
    }
    var response = await dioNoOfflineCheck
        .get(
          "https://ids.xidian.edu.cn/authserver/login",
          queryParameters: target != null ? {'service': target} : null,
        )
        .then((value) => value.data);

    /// Start getting data from webpage.
    var page = BeautifulSoup(response);
    var form = page.findAll("input", attrs: {"type": "hidden"});

    /// Check whether it need CAPTCHA or not:-P
    /// Used in two captcha.
    String cookieStr = "";
    var cookie = await cookieJar
        .loadForRequest(Uri.parse("https://ids.xidian.edu.cn/authserver"));
    for (var i in cookie) {
      cookieStr += "${i.name}=${i.value}; ";
    }
    developer.log("cookie: $cookieStr.", name: "ids login");

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

    for (var i in _header) {
      head[i] = form.firstWhere(
          (element) => element["name"] == i || element.id == i)["value"]!;
    }

    if (onResponse != null) {
      onResponse(45, "滑块验证");
    }

    await dioNoOfflineCheck.get(
      "https://ids.xidian.edu.cn/authserver/common/openSliderCaptcha.htl",
      queryParameters: {'_': DateTime.now().millisecondsSinceEpoch.toString()},
    );

    await sliderCaptcha!(cookieStr);

    /// Post login request.
    if (onResponse != null) {
      onResponse(50, "准备登录");
    }
    try {
      var data = await dioNoOfflineCheck.post(
        "https://ids.xidian.edu.cn/authserver/login",
        data: head,
        options: Options(
          validateStatus: (status) =>
              status != null && status >= 200 && status < 400,
        ),
      );
      if (data.statusCode == 301 || data.statusCode == 302) {
        /// Post login progress.
        if (onResponse != null) {
          onResponse(80, "登录后处理");
        }
        return data.headers[HttpHeaders.locationHeader]![0];
      } else {
        throw LoginFailedException(msg: "登录失败，响应状态码：${data.statusCode}。");
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw PasswordWrongException(msg: _parsePasswordWrongMsg(e.response!.data));
      }
      rethrow;
    }
  }
}

class NeedCaptchaException implements Exception {}

class PasswordWrongException implements Exception {
  final String msg;
  const PasswordWrongException({required this.msg});
  @override
  String toString() => msg;
}

class LoginFailedException implements Exception {
  final String msg;
  const LoginFailedException({required this.msg});
  @override
  String toString() => msg;
}
