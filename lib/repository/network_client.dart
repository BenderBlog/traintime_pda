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

/// A General Network Client which provides
///  - An AES encrypt function [aesEncrypt]
///  - A network client [dio]
///  - A method to check schoolnet environment [isInSchool]
mixin NetworkClient {
  /// AES-CBC encryption with Pkcs7 padding
  /// used for IDS CAPTCHA payload & password encryption
  static String aesEncrypt(String text, Uint8List keyBytes) {
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

  /// General Cookie Storage
  PersistCookieJar cookieJar = PersistCookieJar(
    persistSession: true,
    storage: FileStorage("${supportPath.path}/cookie/general"),
  );
  Future<void> clearCookieJar() => cookieJar.deleteAll();

  /// General Dio Session
  @protected
  late Dio dio =
      Dio(
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
        ..interceptors.add(CookieManager(cookieJar, ignoreInvalidCookies: true))
        ..interceptors.add(logDioAdapter)
        ..options.connectTimeout = const Duration(seconds: 10)
        ..options.receiveTimeout = const Duration(seconds: 30)
        ..options.followRedirects = false
        ..options.validateStatus = (status) =>
            status != null && status >= 200 && status < 400;

  /// Check whether access in schoolnet
  Future<bool> isInSchool() async {
    Dio dio = Dio()
      ..interceptors.add(logDioAdapter)
      ..options.connectTimeout = const Duration(seconds: 30);
    return await dio
        .get("https://notice.xidian.edu.cn")
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
}
