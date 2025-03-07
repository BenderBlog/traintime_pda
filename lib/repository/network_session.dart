// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

// General network class.

import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:watermeter/repository/logger.dart';

late Directory supportPath;

enum SessionState {
  fetching,
  fetched,
  error,
  none,
}

Rx<SessionState> isInit = SessionState.none.obs;

class NetworkSession {
  //@protected
  final PersistCookieJar cookieJar = PersistCookieJar(
    persistSession: true,
    storage: FileStorage("${supportPath.path}/cookie/general"),
  );

  Future<void> clearCookieJar() => cookieJar.deleteAll();

  @protected
  Dio get dio => Dio(
        BaseOptions(
          contentType: Headers.formUrlEncodedContentType,
          headers: {
            HttpHeaders.userAgentHeader:
                "Mozilla/5.0 (Windows NT 10.0; Win64; x64) "
                    "AppleWebKit/537.36 (KHTML, like Gecko) "
                    "Chrome/120.0.0.0 Safari/537.36 Edg/120.0.0.0",
          },
        ),
      )
        ..interceptors.add(CookieManager(cookieJar))
        ..interceptors.add(logDioAdapter)
        ..options.connectTimeout = const Duration(seconds: 10)
        ..options.receiveTimeout = const Duration(seconds: 30)
        ..options.followRedirects = false
        ..options.validateStatus =
            (status) => status != null && status >= 200 && status < 400;

  static Future<bool> isInSchool() async {
    bool isInSchool = false;
    Dio dio = Dio()..options.connectTimeout = const Duration(seconds: 5);
    await dio
        .get("http://linux.xidian.edu.cn")
        .then((value) => isInSchool = true)
        .onError((error, stackTrace) => isInSchool = false);
    return isInSchool;
  }

  NetworkSession() {
    if (isInit.value == SessionState.none) {
      initSession();
    }
  }

  Future<void> initSession() async {
    log.info(
      "[NetworkSession][initSession] "
      "Current State: ${isInit.value}",
    );
    if (isInit.value == SessionState.fetching) {
      return;
    }
    try {
      isInit.value = SessionState.fetching;
      log.info(
        "[NetworkSession][initSession] "
        "Fetching...",
      );
      var response = await dio.get(
        "http://linux.xidian.edu.cn",
      );
      if (response.statusCode == 200) {
        isInit.value = SessionState.fetched;
        log.info(
          "[NetworkSession][initSession] "
          "Fetched",
        );
      } else {
        isInit.value = SessionState.error;
        log.error(
          "[NetworkSession][initSession] "
          "Error",
        );
      }
    } catch (e) {
      isInit.value = SessionState.error;
      log.error(
        "[NetworkSession][initSession] "
        "Error: $e",
      );
    }
  }
}

class NotSchoolNetworkException implements Exception {
  final msg = "没有在校园网环境";

  @override
  String toString() => msg;
}
