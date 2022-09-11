/*
IDS login class.
Copyright 2022 SuperBart

This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.

Please refer to ADDITIONAL TERMS APPLIED TO WATERMETER SOURCE CODE
if you want to use.
*/

import 'dart:io';

import 'package:beautiful_soup_dart/beautiful_soup.dart';
import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' hide Key;
import 'dart:convert';
import 'package:encrypt/encrypt.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:watermeter/dataStruct/user.dart';
import 'package:watermeter/communicate/general.dart';

/// Get base64 encoded data. Which is aes encrypted [toEnc] encoded string using [key].
/// Padding part is copied from libxduauth's idea.
String aesEncrypt(String toEnc, String key) {
  dynamic k = Key.fromUtf8(key);
  var crypt = AES(k, mode: AESMode.cbc, padding: null);
  /// Start padding
  int blockSize = 16;
  List<int> dataToPad = [];
  dataToPad.addAll(utf8.encode("xidianscriptsxduxidianscriptsxduxidianscriptsxduxidianscriptsxdu$toEnc"));
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
  Dio get dio{
    Dio toReturn = Dio(BaseOptions(
      contentType: Headers.formUrlEncodedContentType,
      headers: {
        HttpHeaders.userAgentHeader: "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/105.0.0.0 Safari/537.36"
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
    var response = await dio.post(
      "http://ids.xidian.edu.cn/authserver/index.do",
      options: Options(
        followRedirects: false,
        validateStatus: (status) { return status! < 500; },
      )
    );
    //print("登录回复信息：${response.headers}");
    if (response.statusCode == 302) {
      throw "没有登录";
    }
  }

  Future<void> login({
    required String username,
    required String password,
    required String target,
    bool forceReLogin = false
  }) async {
    /// Get the login webpage.
    var response = await dio.get(
      "http://ids.xidian.edu.cn/authserver/login",
      queryParameters: {'service': target, 'type': 'userNameLogin'},
    ).then((value) => value.data);
    /// Start getting data from webpage.
    var page = BeautifulSoup(response);
    var form = page.find("form",attrs: {'id': 'pwdFromId'});
    /// Check whether it need CAPTCHA or not:-P
    var checkCAPTCHA = await dio.get(
      "http://ids.xidian.edu.cn/authserver/checkNeedCaptcha.htl",
      queryParameters: {'username': username, '_': DateTime.now().millisecondsSinceEpoch.toString()},
    ).then((value) => value.data);
    bool isNeed = checkCAPTCHA.contains("true");
    if (isNeed) {
      throw "需要验证码，请去浏览器登陆";
    }
    /// Get AES encrypt key.
    String keys = form!.find("input",id: 'pwdEncryptSalt')!.getAttrValue("value")!;
    Map<String,dynamic> head = {
      'username': username,
      'password': aesEncrypt(password, keys),
      'rememberMe': 'true',
    };
    for (var i in form.findAll("input",attrs: {"type":"hidden"})){
      head[i["id"]!] = i["value"] ?? "";
    }
    var data = await dio.post(
      "http://ids.xidian.edu.cn/authserver/login",
      queryParameters: {'service': target},
      data: head,
      options: Options(
        followRedirects: false,
        validateStatus: (status) { return status! < 500; },
      )
    );
    print(data.statusCode);
    if (data.statusCode == 401) {
      throw "用户名或密码错误";
    } else if (data.statusCode == 301 || data.statusCode == 302) {
      var whatever = await dio.get(
        data.headers['location']![0],
          options: Options(
            followRedirects: false,
            validateStatus: (status) { return status! < 500; },
          )
      );
      if (whatever.data.contains("验证码错误")){
        throw "不知为啥还是说让输验证码";
      }
      return;
    } else {
      throw "登陆失败了，原因不明";
    }
  }
}

var ids = IDSSession();