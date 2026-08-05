// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

// General network class.

import 'dart:io';
import 'dart:math';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:encrypter_plus/encrypter_plus.dart' as encrypt;
import 'package:watermeter/repository/logger.dart';

late Directory supportPath;

/// Process-wide cookie stores. A persistent store must have exactly one live
/// instance for a given directory, otherwise the in-memory caches of multiple
/// [PersistCookieJar]s can overwrite each other.
class NetworkCookieJars {
  static PersistCookieJar? _ids;
  static PersistCookieJar? _schoolnet;
  static PersistCookieJar? _sport;

  /// Keep the legacy directory so existing IDS trusted-device cookies survive
  /// this client refactor.
  static PersistCookieJar get ids => _ids ??= PersistCookieJar(
    persistSession: true,
    storage: FileStorage('${supportPath.path}/cookie/general'),
  );

  static PersistCookieJar get schoolnet => _schoolnet ??= PersistCookieJar(
    persistSession: true,
    storage: FileStorage('${supportPath.path}/cookie/schoolnet'),
  );

  static PersistCookieJar get sport => _sport ??= PersistCookieJar(
    persistSession: true,
    storage: FileStorage('${supportPath.path}/cookie/sport/'),
  );
}

/// Shared Dio instances grouped by protocol and authentication policy.
class NetworkClients {
  static const defaultUserAgent =
      'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) '
      'AppleWebKit/537.36 (KHTML, like Gecko) '
      'Chrome/130.0.0.0 Safari/537.36 XDYou/2.0.0';

  static const _ehallHost = 'ehall.xidian.edu.cn';

  static const Map<String, String> _ehallHeaders = {
    HttpHeaders.refererHeader: 'http://ehall.xidian.edu.cn/new/index_xd.html',
    HttpHeaders.acceptHeader:
        'text/html,application/xhtml+xml,application/xml;q=0.9,'
        'image/webp,image/apng,*/*;q=0.8,'
        'application/signed-exchange;v=b3;q=0.9',
    HttpHeaders.acceptLanguageHeader:
        'zh-CN,zh;q=0.9,en;q=0.8,en-GB;q=0.7,en-US;q=0.6',
    HttpHeaders.acceptEncodingHeader: 'identity',
    HttpHeaders.connectionHeader: 'Keep-Alive',
    HttpHeaders.contentTypeHeader:
        'application/x-www-form-urlencoded; charset=UTF-8',
  };

  static Dio? _idsDio;
  static Dio? _ehallDio;
  static Dio? _schoolnetDio;
  static Dio? _sportDio;
  static Dio? _otherDio;

  static PersistCookieJar get idsCookieJar => NetworkCookieJars.ids;
  static PersistCookieJar get schoolnetCookieJar => NetworkCookieJars.schoolnet;
  static PersistCookieJar get sportCookieJar => NetworkCookieJars.sport;

  /// Generic SSO client. It intentionally has no fixed Host, Referer or
  /// business-domain base URL, so it can safely follow cross-domain CAS hops.
  static Dio get idsDio =>
      _idsDio ??= _createDio(cookieJar: idsCookieJar, followRedirects: false);

  /// eHall business client. It shares only the IDS cookie store; its Dio
  /// options and interceptors are independent from [idsDio].
  static Dio get ehallDio => _ehallDio ??= _createEhallDio();

  static Dio get schoolnetDio => _schoolnetDio ??= _createDio(
    cookieJar: schoolnetCookieJar,
    baseUrl: 'https://zfw.xidian.edu.cn',
    followRedirects: true,
  );

  static Dio get sportDio => _sportDio ??= _createDio(
    cookieJar: sportCookieJar,
    baseUrl: 'http://tybjxgl.xidian.edu.cn/app/',
    followRedirects: true,
  );

  /// Public/stateless requests. It has neither CookieManager nor auth headers.
  static Dio get otherDio => _otherDio ??= _createDio();

  static Dio _createEhallDio() {
    final client = _createDio(cookieJar: idsCookieJar, followRedirects: false);
    client.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (options.uri.host == _ehallHost) {
            options.headers.addAll(_ehallHeaders);
          }
          handler.next(options);
        },
      ),
    );
    return client;
  }

  static Dio _createDio({
    CookieJar? cookieJar,
    String baseUrl = '',
    bool followRedirects = false,
  }) {
    final client = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        contentType: Headers.formUrlEncodedContentType,
        headers: {HttpHeaders.userAgentHeader: defaultUserAgent},
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 30),
        followRedirects: followRedirects,
        validateStatus: (status) =>
            status != null && status >= 200 && status < 400,
      ),
    );
    if (cookieJar != null) {
      client.interceptors.add(
        CookieManager(cookieJar, ignoreInvalidCookies: true),
      );
    }
    client.interceptors.add(logDioAdapter);
    return client;
  }
}

/// AES-CBC encryption with Pkcs7 padding
/// used for IDS CAPTCHA payload & password encryption
String aesEncrypt(String text, Uint8List keyBytes) {
  final rng = Random();
  const int blockSize = 16;
  const String aesChars = "ABCDEFGHJKMNPQRSTWXYZabcdefhijkmnprstwxyz2345678";
  final randstr = [
    for (int i = 0; i < blockSize * 5; i++)
      aesChars[rng.nextInt(aesChars.length)],
  ].join();
  final plain = randstr.substring(0, 64) + text; // prepend 64B nonce
  final key = encrypt.Key(keyBytes);
  final iv = encrypt.IV.fromUtf8(randstr.substring(64, 80)); // 16B iv
  return encrypt.Encrypter(
    encrypt.AES(key, mode: encrypt.AESMode.cbc),
  ).encrypt(plain, iv: iv).base64;
}

/// Check whether access in schoolnet
Future<bool> isInSchool() async {
  return await NetworkClients.otherDio
      .get(
        "https://notice.xidian.edu.cn",
        options: Options(followRedirects: true),
      )
      .then((value) => !value.data.toString().contains("校外访问"))
      .onError((error, stackTrace) {
        log.warning(
          "[isSchoolNet] Unable to fetch, treat as not schoolnet.",
          error,
          stackTrace,
        );
        return false;
      });
}
