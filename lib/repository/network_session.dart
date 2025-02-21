// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

// General network class.

import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter/widgets.dart';
import 'package:watermeter/repository/logger.dart';

late Directory supportPath;

enum SessionState {
  fetching,
  fetched,
  error,
  none,
}

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
                "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) "
                    "AppleWebKit/537.36 (KHTML, like Gecko) "
                    "Chrome/130.0.0.0 Safari/537.36",
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
}

class NotSchoolNetworkException implements Exception {
  final msg = "没有在校园网环境";

  @override
  String toString() => msg;
}
