// Copyright 2024 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:html/dom.dart';
import 'package:watermeter/model/xidian_ids/network_usage.dart';
import 'package:watermeter/repository/network_session.dart';
import 'package:html/parser.dart';
import 'package:encrypt/encrypt.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'package:watermeter/repository/preference.dart' as prefs;

class SchoolnetSession extends NetworkSession {
  Dio get _dio => super.dio
    ..options.baseUrl = "https://zfw.xidian.edu.cn"
    ..options.headers = {"Host": "zfw.xidian.edu.cn"}
    ..options.contentType = Headers.formUrlEncodedContentType
    ..options.followRedirects = true;

  String _getPostStringBody(Map<String, dynamic> toPost) {
    String toPostStr = "";
    for (var i in toPost.keys) {
      toPostStr +=
          "${Uri.encodeQueryComponent(i)}=${Uri.encodeQueryComponent(toPost[i]!)}";
      if (i != toPost.keys.last) {
        toPostStr += "&";
      }
    }
    return toPostStr;
  }

  NetworkUsage _getNetworkUsage(String page) {
    List<(String, String, String)> ipList = [];
    String used = "";
    String rest = "";
    String charged = "";
    parse(page).getElementsByTagName("tr").forEach((value) {
      var tdList = value.getElementsByTagName("td");
      if (tdList.length == 4) {
        // TODO: Bug detect here...
        String usedT = tdList[2].innerHtml;
        if (usedT.isNotEmpty) {
          ipList.add((tdList[0].innerHtml, tdList[1].innerHtml, usedT));
        }
      } else if (tdList.length == 6) {
        used = tdList[1].innerHtml;
        rest = tdList[2].innerHtml;
        charged = tdList[3].innerHtml;
      }
    });

    //for (var ip_info in ipList) {
    //  print(ip_info);
    //}

    return NetworkUsage(
      ipList: ipList,
      used: used,
      rest: rest,
      charged: charged,
    );
  }

  Future<NetworkUsage> getNetworkUsage({
    required Future<String?> Function(Uint8List pictureData) captcha,
  }) async {
    if (!await NetworkSession.isInSchool) {
      throw NotSchoolNetworkException;
    }

    // Get username and password
    String password = prefs.getString(prefs.Preference.schoolNetQueryPassword);
    if (password.isEmpty) {
      throw EmptyPasswordException;
    }
    String username = prefs.getString(prefs.Preference.idsAccount);

    // Check whether fetch directly
    var page = await _dio.get("/home");
    if (!page.isRedirect) {
      return await _dio
          .get("/home")
          .then((value) => _getNetworkUsage(value.data));
    }

    //clearCookieJarSpecific("https://zfw.xidian.edu.cn");

    // Get login page
    page = await _dio.get("/login");

    // Get csrf and key
    List<Element> inputs =
        parse(page.data.toString()).getElementsByTagName("input");
    String csrf = "";
    String key = "";
    for (var i in inputs) {
      if (i.attributes["name"]?.contains("csrf") ?? false) {
        csrf = i.attributes["value"] ?? "";
      }
      if (i.attributes["id"]?.contains("public") ?? false) {
        key = i.attributes["value"] ?? "";
      }
      if (csrf.isNotEmpty && key.isNotEmpty) break;
    }
    if (csrf.isEmpty || key.isEmpty) throw ConnectionException;

    // Get verifycode
    String imgPath = parse(page.data.toString())
            .getElementById("loginform-verifycode-image")
            ?.attributes["src"] ??
        "";
    String? verifycode = await captcha(await _dio
        .get(imgPath, options: Options(responseType: ResponseType.bytes))
        .then((value) => value.data));
    if (verifycode == null) throw NoCaptchaException;

    // Encrypt the password
    var rsaKey = RSAKeyParser().parse(key);
    String encryptedPassword = Encrypter(RSA(
      publicKey: RSAPublicKey(
        rsaKey.modulus!,
        rsaKey.exponent!,
      ),
    )).encrypt(password).base64;

    // Pre-login post
    page = await _dio.post(
      "/site/validate-user",
      data: _getPostStringBody({
        "LoginForm[username]": username, //prefs.getString("idsAccount"),
        "LoginForm[password]": encryptedPassword,
        "LoginForm[verifyCode]": verifycode,
      }),
      options: Options(headers: {
        "X-CSRF-Token": csrf,
        "Accept": "*/*",
        "Accept-Encoding": "gzip, deflate, br, zstd",
        "X-Requested-With": "XMLHttpRequest",
      }),
    );
    if (!jsonDecode(page.data)["success"]) {
      throw ConnectionException()
        ..msg = jsonDecode(page.data)["message"] ?? "未知错误";
    }

    // Login post
    page = await _dio.post(
      "/",
      data: _getPostStringBody({
        "_csrf-8800": csrf,
        "LoginForm[username]": username, //prefs.getString("idsAccount"),
        "LoginForm[password]": encryptedPassword,
        "LoginForm[smsCode]": "",
        "LoginForm[verifyCode]": verifycode,
      }),
      options: Options(headers: {
        "X-CSRF-Token": csrf,
        "Accept": "*/*",
        "Accept-Encoding": "gzip, deflate, br, zstd",
        "X-Requested-With": "XMLHttpRequest",
      }),
    );

    // Return data
    page = await _dio.get("/home");
    return _getNetworkUsage(page.data);
  }
}

class ConnectionException implements Exception {
  String? msg;
}

class EmptyPasswordException implements Exception {}

class NoCaptchaException implements Exception {}
