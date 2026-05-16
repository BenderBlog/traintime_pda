// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

// IDS recheck (二次验证) service.
// Handles secondary authentication for sensitive personalInfo operations
// (FIDO registration, password change, etc.).

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:watermeter/page/login/image_captcha.dart';
import 'package:watermeter/repository/xidian_ids/ids_crypto.dart';
import 'package:watermeter/repository/xidian_ids/ids_session.dart';

class IdsRecheck extends IDSSession {
  static const _personalInfoService =
      "https://ids.xidian.edu.cn/personalInfo/index.html";

  /// Ensure authenticated session for /personalInfo endpoints.
  ///
  /// The main IDS login may not cover /personalInfo service.
  /// This hits the login endpoint with the personalInfo service URL.
  /// If already logged in, the server returns 302 with a service ticket;
  /// we follow the redirect chain to redeem it.
  Future<void> ensurePersonalInfoSession() async {
    var response = await dioNoOfflineCheck.get(
      "https://ids.xidian.edu.cn/authserver/login",
      queryParameters: {
        'type': 'userNameLogin',
        'service': _personalInfoService,
      },
    );

    // Follow redirect chain to redeem service ticket
    while (response.statusCode == 301 || response.statusCode == 302) {
      final locations = response.headers[HttpHeaders.locationHeader];
      if (locations == null || locations.isEmpty) break;
      response = await dioNoOfflineCheck.get(locations.first);
    }
  }

  /// Check if secondary verification is required.
  ///
  /// Returns true if recheck is needed (either necessary=true or expired/missing).
  /// Returns false only when the server confirms recheck is NOT needed.
  Future<bool> isNecessary() async {
    final resp = await dioNoOfflineCheck.get(
      "https://ids.xidian.edu.cn/personalInfo/common/isUserRecheckNecessary",
      queryParameters: {"t": DateTime.now().millisecondsSinceEpoch.toString()},
    );
    final data = resp.data;
    if (data is Map) {
      final code = data["code"];
      // 2106010002 = "二次校验已失效" → recheck expired, need to redo
      if (code.toString() == "2106010002") return true;
      if (data["datas"] is Map) {
        return data["datas"]["necessary"] == true;
      }
    }
    return true;
  }

  /// Get available recheck approach.
  /// Returns: "password", "phone", "email", "otp"
  Future<String> getApproach() async {
    final resp = await dioNoOfflineCheck.post(
      "https://ids.xidian.edu.cn/personalInfo/common/recheckApproach",
      data: {"n": _randomN()},
      options: Options(contentType: "application/json"),
    );
    final data = resp.data;
    if (data is Map && data["datas"] is Map) {
      return data["datas"]["approachName"] ?? "password";
    }
    return "password";
  }

  /// Fetch captcha image bytes for recheck.
  Future<Uint8List> fetchCaptchaImage() async {
    final resp = await dioNoOfflineCheck.get(
      "https://ids.xidian.edu.cn/personalInfo/captcha/checkCode",
      queryParameters: {"data": DateTime.now().millisecondsSinceEpoch.toString()},
      options: Options(responseType: ResponseType.bytes),
    );
    return Uint8List.fromList(resp.data);
  }

  /// Perform password-based recheck.
  ///
  /// 1. Fetches captcha image
  /// 2. Shows ImageCaptchaWidget for user input
  /// 3. Reads WIS_PER_ENC cookie as AES key
  /// 4. Encrypts password with IdsCrypto
  /// 5. POSTs to /common/reCheckPwd
  ///
  /// Returns the sign value on success.
  Future<String> recheckByPassword({
    required BuildContext context,
    required String password,
  }) async {
    // 1. Fetch captcha
    final captchaImage = await fetchCaptchaImage();

    // 2. Show captcha widget
    if (!context.mounted) throw RecheckCancelledException();
    final captchaCode = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => ImageCaptchaWidget(
          initialImage: captchaImage,
          onRefresh: fetchCaptchaImage,
        ),
      ),
    );
    if (captchaCode == null) throw RecheckCancelledException();

    // 3. Read WIS_PER_ENC cookie
    final cookies = await cookieJar.loadForRequest(
      Uri.parse("https://ids.xidian.edu.cn/personalInfo"),
    );
    final wisPerEncCookie = cookies.where((c) => c.name == "WIS_PER_ENC").firstOrNull;
    if (wisPerEncCookie == null) {
      throw const RecheckFailedException("WIS_PER_ENC cookie not found");
    }
    final keyBytes = Uint8List.fromList(utf8.encode(wisPerEncCookie.value));

    // 4. Encrypt password
    final encryptedPwd = IdsCrypto.encryptPassword(password, keyBytes);

    // 5. Submit recheck
    final resp = await dioNoOfflineCheck.post(
      "https://ids.xidian.edu.cn/personalInfo/common/reCheckPwd",
      data: {"captcha": captchaCode, "password": encryptedPwd},
      options: Options(contentType: "application/json"),
    );

    final data = resp.data;
    if (data is! Map) {
      throw RecheckFailedException("Unexpected response format");
    }
    final code = data["code"];
    if (code.toString() != "0") {
      final msg = data["message"] ?? "Verification failed";
      throw RecheckFailedException(msg);
    }
    final datas = data["datas"];
    if (datas is! Map) {
      throw RecheckFailedException("Unexpected response data");
    }
    return datas["sign"];
  }

  String _randomN() {
    return (DateTime.now().millisecondsSinceEpoch / 1000).toStringAsFixed(17);
  }

  /// Delete a FIDO device credential from the server.
  ///
  /// Requires recheck (secondary verification) to have been completed.
  /// The REFERERCE_TOKEN cookie is used as the referertoken header.
  Future<void> deleteDevice({
    required String credentialId,
    required String username,
  }) async {
    // Read REFERERCE_TOKEN cookie for the referertoken header
    final cookies = await cookieJar.loadForRequest(
      Uri.parse("https://ids.xidian.edu.cn/personalInfo"),
    );
    final refToken = cookies
        .where((c) => c.name == "REFERERCE_TOKEN")
        .firstOrNull
        ?.value;

    final headers = <String, String>{
      "X-Requested-With": "XMLHttpRequest",
      "Origin": "https://ids.xidian.edu.cn",
      "Referer": "https://ids.xidian.edu.cn/personalInfo/personCenter/index.html",
    };
    if (refToken != null) {
      headers["referertoken"] = refToken;
    }

    final resp = await dioNoOfflineCheck.post(
      "https://ids.xidian.edu.cn/personalInfo/accountSecurity/deleteDevice",
      data: {
        "id": credentialId,
        "response": username,
        "n": _randomN(),
      },
      options: Options(
        contentType: "application/json",
        headers: headers,
      ),
    );

    final data = resp.data;
    if (data is! Map || data["code"].toString() != "0") {
      throw RecheckFailedException(
        "Delete device failed: ${data is Map ? data["message"] : "unexpected response format"}",
      );
    }
  }
}

class RecheckCancelledException implements Exception {}

class RecheckFailedException implements Exception {
  final String msg;
  const RecheckFailedException(this.msg);
  @override
  String toString() => msg;
}
