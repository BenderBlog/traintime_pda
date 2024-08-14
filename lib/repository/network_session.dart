// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

// General network class.

import 'dart:io';
import 'package:alice_dio/alice_dio_adapter.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter/widgets.dart';
import 'package:alice/alice.dart';
import 'package:watermeter/repository/preference.dart';

AliceDioAdapter aliceDioAdapter = AliceDioAdapter();
Alice alice = Alice(
  showNotification: false,
  navigatorKey: debuggerKey,
)..addAdapter(aliceDioAdapter);

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
  Future<void> clearCookieJarSpecific(String url) =>
      cookieJar.delete(Uri.parse(url));

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
        ..interceptors.add(aliceDioAdapter)
        ..options.connectTimeout = const Duration(seconds: 10)
        ..options.receiveTimeout = const Duration(seconds: 30)
        ..options.followRedirects = false
        ..options.validateStatus =
            (status) => status != null && status >= 200 && status < 400;

  static Future<bool> get isInSchool async {
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
