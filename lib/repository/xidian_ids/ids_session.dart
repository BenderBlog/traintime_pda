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
import 'package:encrypt/encrypt.dart';
import 'package:flutter/foundation.dart' hide Key;
import 'package:watermeter/main.dart';
import 'package:watermeter/repository/general.dart';

/// Get base64 encoded data. Which is aes encrypted [toEnc] encoded string using [key].
/// Padding part is copied from libxduauth's idea.
String aesEncrypt(String toEnc, String key) {
  dynamic k = Key.fromUtf8(key);
  var crypt = AES(k, mode: AESMode.cbc, padding: null);

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
  return Encrypter(crypt)
      .encrypt(readyToEnc, iv: IV.fromUtf8('xidianscriptsxdu'))
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

  String _keys = "";
  String _target = "";
  List<Bs4Element> _form = [];

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
    toReturn.interceptors.add(alice.getDioInterceptor());
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

  Future<bool> captchaCheck({required String username}) async {
    var checkCAPTCHA = await dio.get(
      "https://ids.xidian.edu.cn/authserver/checkNeedCaptcha.htl",
      queryParameters: {
        'username': username,
        '_': DateTime.now().millisecondsSinceEpoch.toString()
      },
    ).then((value) => value.data);
    return checkCAPTCHA.contains("true");
  }

  Future<void> initLogin({required String target}) async {
    if (_form.isEmpty || _keys == "" || _target == "") {
      _target = target;

      /// Get the login webpage.
      developer.log("Ready to get the login webpage.", name: "ids login");
      String loginaddress = await dio
          .get(_target,
              options: Options(
                  followRedirects: false,
                  validateStatus: (status) => status! < 500))
          .then((value) => value.headers["location"]![0]);
      developer.log(loginaddress, name: "ids login");
      var response = await dio.get(loginaddress).then((value) => value.data);

      /// Start getting data from webpage.
      var page = BeautifulSoup(response);
      _form = page.findAll("input", attrs: {"type": "hidden"});
      _keys = _form
          .firstWhere((element) => element["id"] == "pwdEncryptSalt")["value"]!;
      developer.log("encrypt key: $_keys.", name: "ids login");
    }
  }

  Future<void> login({
    required String username,
    required String password,
    required String target,
    bool forceReLogin = false,
    String? captcha,
    void Function(int, String)? onResponse,
  }) async {
    initLogin(target: target);

    /// Prepare for login.
    if (onResponse != null) {
      onResponse(40, "准备登录");
    }
    Map<String, dynamic> head = {
      'username': username,
      'password': aesEncrypt(password, _keys),
      'rememberMe': 'true',
      'cllt': 'userNameLogin',
      'dllt': 'generalLogin',
      '_eventId': 'submit',
    };

    if (captcha != null) {
      head['captcha'] = captcha;
    }

    for (var i in _header) {
      head[i] = _form.firstWhere(
          (element) => element["name"] == i || element.id == i)["value"]!;
    }

    /// Post login request.
    if (onResponse != null) {
      onResponse(50, "准备登录");
    }
    var data = await dio.post(
      "https://ids.xidian.edu.cn/authserver/login",
      queryParameters: {'service': _target},
      options: Options(
        followRedirects: false,
        validateStatus: (status) => status! < 500,
      ),
      data: head,
    );
    developer.log("Received: $data.", name: "ids login");
    if (data.statusCode == 401) {
      throw "用户名或密码错误，或验证码错误";
    } else if (data.statusCode == 301 || data.statusCode == 302) {
      /// Post login progress.
      if (onResponse != null) {
        onResponse(80, "登录后处理");
      }
      developer.log("Post deal...", name: "ids login");
      String refUrl = data.headers['location']![0].split("?")[1];
      List<String> option = refUrl.split("&");
      var whatever = await dio.get(
        data.headers['location']![0],
        queryParameters: {
          option[1].split("=")[0]: option[1].split("=")[1],
        },
        options: Options(
          followRedirects: false,
          validateStatus: (status) {
            return status! < 500;
          },
        ),
      );
      return;
    } else {
      throw "登陆失败了，原因不明\n返回值代码：${data.statusCode}\n";
    }
  }
}
