// Copyright 2026 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:watermeter/repository/ids_session/ids_auth_protocol.dart';

typedef IDSReAuthHandler = Future<Uri> Function(IDSReAuthClient client);

/// Set by the signed-in UI so a service refresh can resume an IDS MFA
/// challenge without restarting the primary password login.
IDSReAuthHandler? activeIDSReAuthHandler;

class IDSReAuthClient {
  IDSReAuthClient({
    required Dio dio,
    required this.challengeUri,
    required this.username,
    required this.service,
    this.registerBrowserFingerprint,
  }) : _dio = dio;

  final Dio _dio;
  final Uri challengeUri;
  final String username;
  final String? service;
  final Future<void> Function()? registerBrowserFingerprint;

  String? recipientDescription;
  bool _prepared = false;

  String get _isMultifactor =>
      challengeUri.queryParameters['isMultifactor'] ?? 'true';

  Future<void> prepare() async {
    if (_prepared) return;

    final challengeResponse = await _dio.getUri(challengeUri);
    if (challengeResponse.statusCode != HttpStatus.ok) {
      throw const IDSReAuthExpiredException('二次认证已失效，请重新登录');
    }
    await registerBrowserFingerprint?.call();
    final response = await _dio.post(
      'https://ids.xidian.edu.cn/authserver/reAuthCheck/changeReAuthType.do',
      data: {
        'isMultifactor': _isMultifactor,
        'reAuthType': '3',
        'service': service ?? '',
      },
    );
    final json = _responseJson(response.data);
    if (json['code']?.toString() != '1') {
      throw IDSProtocolException(json['message']?.toString() ?? '无法切换到短信二次认证');
    }

    final data = json['data'];
    if (data is Map) {
      recipientDescription = data['reAuthUserNameInput']?.toString();
    }
    _prepared = true;
  }

  Future<IDSSmsDelivery> sendSms() async {
    await prepare();
    final response = await _dio.post(
      'https://ids.xidian.edu.cn/authserver/dynamicCode/'
      'getDynamicCodeByReauth.do',
      data: {'userName': username, 'authCodeTypeName': 'reAuthDynamicCodeType'},
    );
    return parseIDSSmsDelivery(_responseJson(response.data));
  }

  Future<Uri> submitSms({
    required String code,
    required bool trustDevice,
  }) async {
    await prepare();
    final normalizedCode = code.trim();
    if (normalizedCode.isEmpty) {
      throw const IDSReAuthCodeRejectedException('请输入短信验证码');
    }

    final response = await _dio.post(
      'https://ids.xidian.edu.cn/authserver/reAuthCheck/reAuthSubmit.do',
      data: {
        'service': service ?? '',
        'reAuthType': '3',
        'isMultifactor': _isMultifactor,
        'password': '',
        'dynamicCode': normalizedCode,
        'uuid': '',
        'answer1': '',
        'answer2': '',
        'otpCode': '',
        'skipTmpReAuth': trustDevice.toString(),
      },
    );
    final result = parseIDSReAuthSubmit(_responseJson(response.data));
    switch (result.status) {
      case IDSReAuthSubmitStatus.failed:
        throw IDSReAuthCodeRejectedException(result.message);
      case IDSReAuthSubmitStatus.unauthorized:
        throw IDSReAuthExpiredException(result.message);
      case IDSReAuthSubmitStatus.success:
        break;
    }

    final loginResponse = await _dio.get(
      'https://ids.xidian.edu.cn/authserver/login',
      queryParameters: service == null ? null : {'service': service},
    );
    final location = loginResponse.headers.value(HttpHeaders.locationHeader);
    if ((loginResponse.statusCode != HttpStatus.movedPermanently &&
            loginResponse.statusCode != HttpStatus.found) ||
        location == null) {
      throw const IDSProtocolException('二次认证成功，但没有收到业务系统登录票据');
    }
    if (isIDSReAuthLocation(location, baseUri: loginResponse.realUri)) {
      throw const IDSReAuthExpiredException('二次认证未完成，请重新登录');
    }
    return loginResponse.realUri.resolve(location);
  }
}

Map<dynamic, dynamic> _responseJson(dynamic data) {
  if (data is Map) return data;
  if (data is String) {
    try {
      final decoded = jsonDecode(data);
      if (decoded is Map) return decoded;
    } on FormatException {
      // Fall through to the sanitized protocol exception below.
    }
  }
  throw const IDSProtocolException('统一认证返回了非 JSON 响应');
}

class IDSReAuthRequiredException implements Exception {
  const IDSReAuthRequiredException();

  @override
  String toString() => '登录需要短信二次认证，请打开应用后重试';
}

class IDSReAuthCodeRejectedException implements Exception {
  const IDSReAuthCodeRejectedException(this.message);

  final String message;

  @override
  String toString() => message;
}

class IDSReAuthExpiredException implements Exception {
  const IDSReAuthExpiredException(this.message);

  final String message;

  @override
  String toString() => message;
}

class IDSReAuthCancelledException implements Exception {
  const IDSReAuthCancelledException();

  @override
  String toString() => '已取消短信二次认证';
}
