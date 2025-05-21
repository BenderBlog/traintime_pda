// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

// IDS (统一认证服务) login class.
// Thanks xidian-script and libxdauth!

import 'dart:io';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:html/parser.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:synchronized/synchronized.dart';
import 'package:watermeter/page/login/jc_captcha.dart';
import 'package:watermeter/repository/logger.dart';
import 'package:watermeter/repository/network_session.dart';
import 'package:watermeter/repository/preference.dart' as preference;

enum IDSLoginState {
  none,
  requesting,
  success,
  fail,
  passwordWrong,

  /// Indicate that the user will login via LoginWindow
  manual,
}

IDSLoginState loginState = IDSLoginState.none;

bool get offline =>
    loginState != IDSLoginState.success && loginState != IDSLoginState.manual;

class IDSSession extends NetworkSession {
  static final _idslock = Lock();

  @override
  Dio get dio => super.dio
    ..interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          log.info(
            "[IDSSession][OfflineCheckInspector]"
            "Offline status: $offline",
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
    var form = parse(html).getElementsByClassName("span")
      ..removeWhere((element) => element.id != "showErrorTip");
    var msg = form.firstOrNull?.children[0].innerHtml ?? "登录遇到问题";

    // Simplify the error message because there is no '找回密码' button here XD.
    // "用户名或密码有误，用户名为工号/学号，如果确认用户名无误，请点‘找回密码’自助重置密码。"
    if (msg.contains(RegExp(r"(用户名|密码).*误", unicode: true, dotAll: true))) {
      msg = "用户名或密码有误。";
    }
    return msg;
  }

  Future<String> checkAndLogin({
    required String target,
    required Future<void> Function(String) sliderCaptcha,
  }) async {
    return await _idslock.synchronized(() async {
      log.info(
        "[IDSSession][checkAndLogin] "
        "Ready to get $target.",
      );
      var data = await dioNoOfflineCheck.get(
        "https://ids.xidian.edu.cn/authserver/login",
        queryParameters: {'service': target},
      );
      log.info(
        "[IDSSession][checkAndLogin] "
        "Received: $data.",
      );
      if (data.statusCode == 401) {
        throw PasswordWrongException(msg: _parsePasswordWrongMsg(data.data));
      } else if (data.statusCode == 301 || data.statusCode == 302) {
        /// Post login progress, due to something wrong, return the location here...
        return data.headers[HttpHeaders.locationHeader]![0];
      } else {
        var page = parse(data.data ?? "");
        var form = page.getElementsByTagName("form")
          ..removeWhere((element) => element.id != "continue");
        log.info(
          "[IDSSession][login] "
          "form: $form.",
        );
        if (form.isNotEmpty) {
          var inputSearch = form[0].getElementsByTagName("input");
          Map<String, String> toPostAgain = {};
          for (var i in inputSearch) {
            toPostAgain[i.attributes["name"]!] = i.attributes["value"]!;
          }
          var data = await dioNoOfflineCheck.post(
            "https://ids.xidian.edu.cn/authserver/login",
            data: toPostAgain,
            options: Options(
              validateStatus: (status) =>
                  status != null && status >= 200 && status < 400,
            ),
          );
          if (data.statusCode == 301 || data.statusCode == 302) {
            return data.headers[HttpHeaders.locationHeader]![0];
          }
        }
        return await login(
          username: preference.getString(preference.Preference.idsAccount),
          password: preference.getString(preference.Preference.idsPassword),
          sliderCaptcha: sliderCaptcha,
          target: target,
        );
      }
    });
  }

  Future<String> login({
    required String username,
    required String password,
    required Future<void> Function(String) sliderCaptcha,
    bool forceReLogin = false,
    void Function(int, String)? onResponse,
    String? target,
  }) async {
    /// Get the login webpage.
    if (onResponse != null) {
      onResponse(10, "login_process.ready_page");
      log.info(
        "[IDSSession][login] "
        "Ready to get the login webpage.",
      );
    }
    var response = await dioNoOfflineCheck
        .get(
          "https://ids.xidian.edu.cn/authserver/login",
          queryParameters: target != null ? {'service': target} : null,
        )
        .then((value) => value.data);

    /// Start getting data from webpage.
    var page = parse(response);
    var form = page.getElementsByTagName("input")
      ..removeWhere(
        (element) => element.attributes["type"] != "hidden",
      );

    /// Check whether it need CAPTCHA or not:-P
    /// Used in two captcha.
    String cookieStr = "";
    var cookie = await cookieJar
        .loadForRequest(Uri.parse("https://ids.xidian.edu.cn/authserver"));
    for (var i in cookie) {
      cookieStr += "${i.name}=${i.value}; ";
    }
    log.info(
      "[IDSSession][login] "
      "cookie: $cookieStr.",
    );

    /// Get AES encrypt key. There must be.
    if (onResponse != null) {
      onResponse(30, "login_process.get_encrypt");
    }
    String keys = form
        .firstWhere((element) => element.id == "pwdEncryptSalt")
        .attributes["value"]!;
    log.info(
      "[IDSSession][login] "
      "encrypt key: $keys.",
    );

    /// Prepare for login.
    if (onResponse != null) {
      onResponse(40, "login_process.ready_login");
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
      head[i] = form
          .firstWhere(
            (element) => element.attributes["name"] == i || element.id == i,
          )
          .attributes["value"]!;
    }

    if (onResponse != null) {
      onResponse(45, "login_process.slider");
    }

    await dioNoOfflineCheck.get(
      "https://ids.xidian.edu.cn/authserver/common/openSliderCaptcha.htl",
      queryParameters: {'_': DateTime.now().millisecondsSinceEpoch.toString()},
    );

    try {
      await sliderCaptcha(cookieStr);
    } on CaptchaSolveFailedException {
      throw const LoginFailedException(msg: "验证码校验失败");
    }

    /// Post login request.
    if (onResponse != null) {
      onResponse(50, "login_process.ready_login");
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
          onResponse(80, "login_process.after_process");
        }
        return data.headers[HttpHeaders.locationHeader]![0];
      } else {
        /// Check whether need continue.
        log.info(
          "[IDSSession][login] "
          "data: ${(data.data as String).length}.",
        );

        var page = parse(data.data ?? "");
        var form = page.getElementsByTagName("form")
          ..removeWhere(
            (element) => element.id != "continue",
          );
        log.info(
          "[IDSSession][login] "
          "form: $form.",
        );
        if (form.isNotEmpty) {
          var inputSearch = form[0].getElementsByTagName("input");
          Map<String, String> toPostAgain = {};
          for (var i in inputSearch) {
            toPostAgain[i.attributes["name"]!] = i.attributes["value"]!;
          }
          var data = await dioNoOfflineCheck.post(
            "https://ids.xidian.edu.cn/authserver/login",
            data: toPostAgain,
            options: Options(
              validateStatus: (status) =>
                  status != null && status >= 200 && status < 400,
            ),
          );
          if (data.statusCode == 301 || data.statusCode == 302) {
            /// Post login progress.
            if (onResponse != null) {
              onResponse(80, "login_process.after_process");
            }
            return data.headers[HttpHeaders.locationHeader]![0];
          }
        }
        throw LoginFailedException(msg: "登录失败，响应状态码：${data.statusCode}。");
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw PasswordWrongException(
          msg: _parsePasswordWrongMsg(e.response!.data),
        );
      } else {
        rethrow;
      }
    }
  }

  Future<bool> checkWhetherPostgraduate() async {
    String location = await checkAndLogin(
      target: "https://yjspt.xidian.edu.cn/gsapp"
          "/sys/yjsemaphome/portal/index.do",
      sliderCaptcha: (cookieStr) =>
          SliderCaptchaClientProvider(cookie: cookieStr).solve(null),
    );
    var response = await dio.get(location);
    while (response.headers[HttpHeaders.locationHeader] != null) {
      location = response.headers[HttpHeaders.locationHeader]![0];
      log.info(
        "[checkWhetherPostgraduate] Received location: $location",
      );
      response = await dio.get(location);
    }

    bool toReturn = await dio
        .post("https://yjspt.xidian.edu.cn/gsapp"
            "/sys/yjsemaphome/modules/pubWork/getCanVisitAppList.do")
        .then((value) => value.data["res"] != null);

    preference.setBool(
      preference.Preference.role,
      toReturn,
    );

    return toReturn;
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
