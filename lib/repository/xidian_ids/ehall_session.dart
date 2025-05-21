// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

// E-hall class, which get lots of useful data here.
// Thanks xidian-script and libxdauth!

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:synchronized/synchronized.dart';
import 'package:watermeter/page/login/jc_captcha.dart';
import 'package:watermeter/repository/logger.dart';
import 'package:watermeter/repository/xidian_ids/ids_session.dart';

class EhallSession extends IDSSession {
  static final _ehallLock = Lock();

  /// This header shall only be used in the ehall related stuff...
  Map<String, String> refererHeader = {
    HttpHeaders.refererHeader: "http://ehall.xidian.edu.cn/new/index_xd.html",
    HttpHeaders.hostHeader: "ehall.xidian.edu.cn",
    HttpHeaders.acceptHeader:
        "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9",
    HttpHeaders.acceptLanguageHeader:
        'zh-CN,zh;q=0.9,en;q=0.8,en-GB;q=0.7,en-US;q=0.6',
    HttpHeaders.acceptEncodingHeader: 'identity',
    HttpHeaders.connectionHeader: 'Keep-Alive',
    HttpHeaders.contentTypeHeader:
        "application/x-www-form-urlencoded; charset=UTF-8",
  };

  Dio get dioEhall => super.dio..options = BaseOptions(headers: refererHeader);

  Future<bool> isLoggedIn() async {
    var response = await dioEhall.get(
      "https://ehall.xidian.edu.cn/jsonp/getAppUsageMonitor.json?type=uv",
    );
    log.info(
      "[ehall_session][isLoggedIn] "
      "Ehall isLoggedin: ${response.data["hasLogin"]}",
    );
    return response.data["hasLogin"];
  }

  Future<void> loginEhall({
    required String username,
    required String password,
    required Future<void> Function(String) sliderCaptcha,
    required void Function(int, String) onResponse,
  }) async {
    String location = await super.login(
      target:
          "https://ehall.xidian.edu.cn/login?service=https://ehall.xidian.edu.cn/new/index.html",
      username: username,
      password: password,
      sliderCaptcha: sliderCaptcha,
      onResponse: onResponse,
    );
    var response = await dio.get(location);
    while (response.headers[HttpHeaders.locationHeader] != null) {
      location = response.headers[HttpHeaders.locationHeader]![0];
      log.info(
        "[ehall_session][loginEhall] "
        "Received location: $location",
      );
      response = await dioEhall.get(location);
    }
    return;
  }

  Future<String> useApp(String appID) async {
    return await _ehallLock.synchronized(() async {
      log.info(
        "[ehall_session][useApp] "
        "Ready to use the app $appID. Try to Login.",
      );
      if (!await isLoggedIn()) {
        String location = await super.checkAndLogin(
          target: "https://ehall.xidian.edu.cn/login?"
              "service=https://ehall.xidian.edu.cn/new/index.html",
          sliderCaptcha: (String cookieStr) =>
              SliderCaptchaClientProvider(cookie: cookieStr).solve(null),
        );
        var response = await dio.get(location);
        while (response.headers[HttpHeaders.locationHeader] != null) {
          location = response.headers[HttpHeaders.locationHeader]![0];
          log.info(
            "[ehall_session][useApp] "
            "Received location: $location.",
          );
          response = await dioEhall.get(location);
        }
      }
      log.info(
        "[ehall_session][useApp] "
        "Try to use the $appID.",
      );
      var value = await dioEhall.get(
        "https://ehall.xidian.edu.cn/appShow?appId=$appID",
        options: Options(
          followRedirects: false,
          validateStatus: (status) {
            return status! < 500;
          },
        ),
      );
      log.info(
        "[ehall_session][useApp] "
        "Transfer address: ${value.headers['location']![0]}.",
      );

      return value.headers['location']![0].replaceAll(
        RegExp(r';jsessionid=(.*)\?'),
        "?",
      );
    });
  }
}

class GetInformationFailedException implements Exception {
  final String msg;
  const GetInformationFailedException(this.msg);

  @override
  String toString() => msg;
}
