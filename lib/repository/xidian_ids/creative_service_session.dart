// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

// Creative School Service Session, related to Jichuang Studio
// Remove the useless func, but session will be saved...
/*
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:watermeter/page/login/jc_captcha.dart';
import 'package:watermeter/repository/logger.dart';
import 'package:watermeter/model/xidian_ids/creative.dart';
import 'package:watermeter/repository/xidian_ids/ids_session.dart';

class CreativeServiceSession extends IDSSession {
  static const url = "https://scjspt.xidian.edu.cn";
  static var authorization = "";

  Future<void> initSession() async {
    try {
      String location = await checkAndLogin(
        target: "$url/login/ids",
        sliderCaptcha: (String cookieStr) =>
            SliderCaptchaClientProvider(cookie: cookieStr).solve(null),
      );
      var response = await dio.get(location);
      while (response.headers[HttpHeaders.locationHeader] != null) {
        location = response.headers[HttpHeaders.locationHeader]![0];
        log.info(
          "[CreativeServiceSession][initSession] "
          "Received location: $location.",
        );
        response = await dio.get(location);
      }
      String urlReceived = "${response.realUri}";
      String ticket = RegExp(r'ST\S+').firstMatch(urlReceived)![0]!;
      log.info(
        "[CreativeServiceSession][initSession] "
        "Received ticket: $ticket.",
      );
      bool isLogin = await dio
          .post(
        "$url/api/v1/auth/ids",
        data: {"ticket": ticket},
        options: Options(contentType: ContentType.json.toString()),
      )
          .then(
        (value) {
          if (value.data["code"] == 200) {
            authorization = value.headers.value("Authorization")!;
          }
          return value.data["code"] == 200;
        },
      );

      log.info(
        "[CreativeServiceSession][initSession] "
        "Received isLogin: $isLogin.",
      );

      if (!isLogin) {
        throw NotLoginException();
      } else {
        return;
      }
    } on DioException {
      rethrow;
    }
  }

  Future<List<Job>> getJob({required Map searchParameter}) async {
    if (authorization.isEmpty) {
      await initSession();
    }

    var data = await dio
        .post(
          "$url/api/v1/job/query",
          data: searchParameter,
          options: Options(
            contentType: ContentType.json.toString(),
            headers: {
              "Authorization": authorization,
            },
          ),
        )
        .then(
          (value) => value.data,
        );

    if (data["code"] != 200) {
      throw NotFetchJobException(msg: data["message"]);
    } else {
      return List<Job>.generate(
        data["data"].length ?? 0,
        (index) => Job.fromJson(data["data"][index]),
      );
    }
  }
}

class NotLoginException implements Exception {}

class NotFetchJobException implements Exception {
  final String msg;
  const NotFetchJobException({required this.msg});

  @override
  String toString() => msg;
}
*/