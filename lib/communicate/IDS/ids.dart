/*
IDS login class.
Copyright 2022 SuperBart

This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.

Please refer to ADDITIONAL TERMS APPLIED TO WATERMETER SOURCE CODE
if you want to use.
*/

import 'package:beautiful_soup_dart/beautiful_soup.dart';
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
  String reallyToEnc = utf8.decode(dataToPad);
  /// Start encrypt.
  return Encrypter(crypt)
      .encrypt(reallyToEnc, iv: IV.fromUtf8('xidianscriptsxdu'))
      .base64;
}

class IDSSession {

  @protected
  Dio get dio{
    Dio toReturn = Dio(BaseOptions(
      contentType: Headers.formUrlEncodedContentType,
    ));
    toReturn.interceptors.add(CookieManager(IDSCookieJar));
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
    print("登录回复信息：${response.headers}");
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
    print("登陆前返回：${response.runtimeType}");
    var page = BeautifulSoup(response);
    var form = page.find("form",attrs: {'id': 'pwdFromId'});
    /// Check whether it need CAPTCHA or not:-P
    var checkCAPTCHA = await dio.get(
      "http://ids.xidian.edu.cn/authserver/checkNeedCaptcha.htl",
      queryParameters: {'username': username, '_': DateTime.now().millisecondsSinceEpoch.toString()},
    ).then((value) => value.data);
    print(checkCAPTCHA);
    bool isNeed = checkCAPTCHA.contains("true");
    if (isNeed) {
      throw "Need captcha, but I donno how to write it! Go to e";
    }
    /// Get AES encrypt key.
    String keys = form!.find("input",id: 'pwdEncryptSalt')!.getAttrValue("value")!;
    // print(form);
    print(keys);
    Map<String,dynamic> head = {
      'username': username,
      'password': aesEncrypt(password, keys),
      'rememberMe': 'true',
    };
    // print(head["password"]);
    for (var i in form.findAll("input",attrs: {"type":"hidden"})){
      head[i["id"]!] = i["value"] ?? "";
      // print(head);
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
    print(data);
    print(data.headers['location']![0]);
    if (data.statusCode == 301 || data.statusCode == 302) {
      var whatever = await dio.get(
        data.headers['location']![0],
        options: Options(
          followRedirects: false,
          validateStatus: (status) { return status! < 500; },
        )
      );
      print(whatever.data);
    }
  }
}

var ids = IDSSession();