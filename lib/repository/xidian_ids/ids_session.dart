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

import 'package:beautiful_soup_dart/beautiful_soup.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:encrypt/encrypt.dart';
import 'package:flutter/foundation.dart' hide Key;
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
  @protected
  Dio get dio {
    Dio toReturn = Dio(BaseOptions(
      contentType: Headers.formUrlEncodedContentType,
      headers: {
        HttpHeaders.userAgentHeader:
            "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/109.0.0.0 Safari/537.36"
      },
    ));
    toReturn.interceptors.add(CookieManager(IDSCookieJar));
    /*(toReturn.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate = (client) {
      client.badCertificateCallback = (X509Certificate cert, String host, int port) {
        //return Platform.isAndroid;
        return true;
      };
      client.findProxy = (uri) {
        return "PROXY 127.0.0.1:8888";
      };
    };*/
    return toReturn;
  }

  Future<void> isLoggedIn() async {
    var response =
        await dio.post("http://ids.xidian.edu.cn/authserver/index.do",
            options: Options(
              followRedirects: false,
              validateStatus: (status) {
                return status! < 500;
              },
            ));
    //print("登录回复信息：${response.headers}");
    if (response.statusCode == 302) {
      throw "没有登录";
    }
  }

  Future<void> login({
    required String username,
    required String password,
    required String target,
    bool forceReLogin = false,
    void Function(int, String)? onResponse,
  }) async {
    /// Get the login webpage.
    if (onResponse != null) {
      onResponse(10, "准备获取登录网页");
    }
    var response = await dio.get(
      "http://ids.xidian.edu.cn/authserver/login",
      queryParameters: {'service': target, 'type': 'userNameLogin'},
    ).then((value) => value.data);

    /// Start getting data from webpage.
    var page = BeautifulSoup(response);
    var form = page.find("form", attrs: {'id': 'pwdFromId'});

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
    if (isNeed) {
      throw "需要验证码，请去浏览器登陆";
    }

    /// Get AES encrypt key.
    if (onResponse != null) {
      onResponse(30, "获取密码加密密钥");
    }
    String keys =
        form!.find("input", id: 'pwdEncryptSalt')!.getAttrValue("value")!;

    /// Prepare for login.
    if (onResponse != null) {
      onResponse(40, "准备登录");
    }
    Map<String, dynamic> head = {
      'username': username,
      'password': aesEncrypt(password, keys),
      'rememberMe': 'true',
    };
    for (var i in form.findAll("input", attrs: {"type": "hidden"})) {
      head[i["id"]!] = i["value"] ?? "";
    }

    /// Post login request.
    if (onResponse != null) {
      onResponse(50, "准备登录");
    }
    var data = await dio.post("http://ids.xidian.edu.cn/authserver/login",
        queryParameters: {'service': target},
        data: head,
        options: Options(
          followRedirects: false,
          validateStatus: (status) {
            return status! < 500;
          },
        ));
    print(data.statusCode);
    if (data.statusCode == 401) {
      throw "用户名或密码错误";
    } else if (data.statusCode == 301 ||
        data.statusCode == 302 ||
        data.statusCode == 200) {
      /// Post login progress.
      if (onResponse != null) {
        onResponse(80, "登录后处理");
      }
      var whatever = await dio.get(data.headers['location']![0],
          options: Options(
            followRedirects: false,
            validateStatus: (status) {
              return status! < 500;
            },
          ));
      if (whatever.data.contains("验证码错误")) {
        throw "不知为啥还是说让输验证码";
      }
      return;
    } else {
      throw "登陆失败了，原因不明\n返回值代码：${data.statusCode}\n";
    }
  }
}

var ids = IDSSession();
