// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

// E-hall class, which get lots of useful data here.
// Thanks xidian-script and libxdauth!

import 'package:dio/dio.dart';
import 'package:synchronized/synchronized.dart';
import 'package:watermeter/repository/network_client.dart';
import 'package:watermeter/repository/ids_session/slider_captcha_client.dart';
import 'package:watermeter/repository/logger.dart';
import 'package:watermeter/repository/ids_session/ids_session.dart';
import 'package:watermeter/repository/ids_session/ids_reauth_client.dart';

class EhallSession extends IDSSession {
  static final _ehallLock = Lock();

  /// A distinct Dio from IDS. It shares only the process-wide IDS cookie jar;
  /// eHall-specific headers are scoped by request host in NetworkClients.
  Dio get dioEhall => NetworkClients.ehallDio;

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
    IDSReAuthHandler? reAuthHandler,
  }) async {
    const target =
        "https://ehall.xidian.edu.cn/login?"
        "service=https://ehall.xidian.edu.cn/new/index.html";
    final location = await super.login(
      target: target,
      username: username,
      password: password,
      sliderCaptcha: sliderCaptcha,
      onResponse: onResponse,
      reAuthHandler: reAuthHandler,
    );
    await followIDSRedirects(
      initialLocation: location,
      service: target,
      username: username,
      reAuthHandler: reAuthHandler,
    );
    if (!await isLoggedIn()) {
      throw const LoginFailedException(msg: '统一认证成功，但一站式大厅登录状态校验失败');
    }
  }

  Future<String> useApp(String appID) async {
    return await _ehallLock.synchronized(() async {
      log.info(
        "[ehall_session][useApp] "
        "Ready to use the app $appID. Try to Login.",
      );
      if (!await isLoggedIn()) {
        const target =
            "https://ehall.xidian.edu.cn/login?"
            "service=https://ehall.xidian.edu.cn/new/index.html";
        final location = await super.checkAndLogin(
          target: target,
          sliderCaptcha: (String cookieStr) =>
              SliderCaptchaClientProvider(cookie: cookieStr).solve(),
        );
        await followIDSRedirects(initialLocation: location, service: target);
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
        "Received app transfer address.",
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
