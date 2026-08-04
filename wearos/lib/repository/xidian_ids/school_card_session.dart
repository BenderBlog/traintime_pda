// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

// Get your school card money's info, unless you use wechat or alipay...

import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:html/parser.dart';
import 'package:watermeter/repository/logger.dart';
import 'package:watermeter/repository/preference.dart' as preference;
import 'package:watermeter/repository/xidian_ids/ids_session.dart';
import 'package:watermeter/wearos/wear_ids_reauth.dart';
import 'package:watermeter/wearos/slider_captcha.dart';

class SchoolCardSession extends IDSSession {
  static const _openOauthUrl =
      "https://v8scan.xidian.edu.cn/home/openXDOAuth2Page";
  static String openid = "";
  static DateTime? _openidFetchedAt;
  static const Duration _openidValidDuration = Duration(minutes: 5);

  static void resetOpenId() {
    openid = "";
    _openidFetchedAt = null;
  }

  bool get _isOpenIdValid =>
      openid.isNotEmpty &&
      _openidFetchedAt != null &&
      DateTime.now().difference(_openidFetchedAt!) < _openidValidDuration;

  Future<void> _ensureOpenId({bool forceRefresh = false}) async {
    if (!forceRefresh && _isOpenIdValid) return;

    resetOpenId();

    var response = await dio.get(_openOauthUrl);
    while (response.headers[HttpHeaders.locationHeader] != null) {
      String location = response.headers[HttpHeaders.locationHeader]![0];
      log.info(
        "[SchoolCardSession][_ensureOpenId] "
        "Received location: $location.",
      );
      response = await dio.get(location);
    }
    _captureOpenId(response.data);
  }

  void _captureOpenId(dynamic html) {
    final inputs = parse(html?.toString() ?? '').getElementsByTagName('input');
    for (final input in inputs) {
      if (input.id == 'openid' && input.attributes['type'] == 'hidden') {
        openid = input.attributes['value'] ?? '';
        break;
      }
    }
    if (openid.isEmpty) throw Exception('School card openid not found.');
    _openidFetchedAt = DateTime.now();
  }

  Future<String> _discoverIdsService() async {
    var currentUrl = _openOauthUrl;
    var response = await dioNoOfflineCheck.get(currentUrl);
    for (var redirect = 0; redirect < 10; redirect++) {
      final nextHeader =
          response.headers[HttpHeaders.locationHeader]?.firstOrNull;
      if (nextHeader == null) break;
      final nextUrl = Uri.parse(currentUrl).resolve(nextHeader).toString();
      final nextUri = Uri.parse(nextUrl);
      if (nextUri.host == 'ids.xidian.edu.cn' &&
          nextUri.path.endsWith('/authserver/login')) {
        final service = nextUri.queryParameters['service'];
        if (service != null && service.isNotEmpty) return service;
      }
      currentUrl = nextUrl;
      response = await dioNoOfflineCheck.get(currentUrl);
    }
    throw Exception('School card IDS service not found.');
  }

  /// Authenticates only the payment-card flow with credentials synced from the
  /// companion phone. Other Wear OS data remains cache-only.
  Future<void> authenticateWithStoredCredentials({
    WearIDSReAuthHandler? reAuthHandler,
  }) async {
    if (loginState == IDSLoginState.success) return;

    loginState = IDSLoginState.requesting;
    try {
      await clearCookieJar();
      final idsService = await _discoverIdsService();
      var location = await checkAndLogin(
        target: idsService,
        sliderCaptcha: (cookie) =>
            SliderCaptchaClientProvider(cookie: cookie).solveAutomatically(),
      );
      final redirectUri = Uri.parse(
        'https://ids.xidian.edu.cn',
      ).resolve(location);
      if (redirectUri.host == 'ids.xidian.edu.cn' &&
          redirectUri.path == '/authserver/reAuthCheck/reAuthLoginView.do') {
        final handler = reAuthHandler;
        if (handler == null) {
          throw const WearIDSReAuthExpiredException('需要短信二次认证');
        }
        location = (await handler(
          WearIDSReAuthClient(
            dio: dioNoOfflineCheck,
            challengeUri: redirectUri,
            username: preference.getString(preference.Preference.idsAccount),
            service: idsService,
          ),
        )).toString();
      }
      var response = await dioNoOfflineCheck.get(location);
      while (response.headers[HttpHeaders.locationHeader]?.isNotEmpty == true) {
        location = Uri.parse(location)
            .resolve(response.headers[HttpHeaders.locationHeader]!.first)
            .toString();
        response = await dioNoOfflineCheck.get(location);
      }
      _captureOpenId(response.data);
      loginState = IDSLoginState.success;
    } on PasswordWrongException {
      loginState = IDSLoginState.passwordWrong;
      rethrow;
    } catch (_) {
      loginState = IDSLoginState.fail;
      rethrow;
    }
  }

  Future<T> _withOpenIdRetry<T>(Future<T> Function() action) async {
    await _ensureOpenId();
    try {
      return await action();
    } catch (e, s) {
      log.warning(
        "[SchoolCardSession][_withOpenIdRetry] "
        "Request failed, retry with refreshed openid.",
        e,
        s,
      );
      await _ensureOpenId(forceRefresh: true);
      return await action();
    }
  }

  Future<Uint8List> getQRCode() async {
    log.info(
      "[SchoolCardSession][initSession] "
      "Try to get QR Code",
    );
    return _withOpenIdRetry(() async {
      final homeUrl =
          "https://v8scan.xidian.edu.cn/home/openHomePage?openid=$openid";
      final homeResp = await dio.get(homeUrl);
      final homeDoc = parse(homeResp.data);

      final aTags = homeDoc.getElementsByTagName('a');
      String? id;
      for (var a in aTags) {
        final href = a.attributes['href'] ?? '';
        if (href.contains('/virtualcard/openVirtualcard') &&
            href.contains('id=')) {
          final uri = Uri.parse(href.replaceAll('&amp;', '&'));
          id = uri.queryParameters['id'];
          if (id != null && id.isNotEmpty) break;
        }
      }
      if (id == null) {
        throw Exception("aTag id not found.");
      }

      final qrUrl =
          "https://v8scan.xidian.edu.cn"
          "/virtualcard/openVirtualcard?"
          "openid=$openid&"
          "displayflag=1&"
          "id=$id";
      final qrResp = await dio.get(qrUrl);
      final qrDoc = parse(qrResp.data);
      final img = qrDoc.getElementById("qrcode");
      if (img == null) {
        throw Exception("QR image not found.");
      }
      var src = img.attributes["src"] ?? "";
      // 提取 base64 数据
      var base64Data = src
          .replaceAll("data:image/png;base64,", "")
          .replaceAll("\n", "");
      if (base64Data.isEmpty) {
        throw Exception("QR data is empty.");
      }
      return base64Decode(base64Data);
    });
  }
}
