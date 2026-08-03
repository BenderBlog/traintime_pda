// Copyright 2026 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:watermeter/repository/xidian_ids/ids_auth_protocol.dart';
import 'package:watermeter/repository/xidian_ids/ids_fingerprint.dart';
import 'package:watermeter/repository/xidian_ids/ids_reauth_client.dart';

void main() {
  group('classifyIDSRedirect', () {
    test('recognizes the IDS re-authentication challenge', () {
      final result = classifyIDSRedirect(
        '/authserver/reAuthCheck/reAuthLoginView.do?service=https%3A%2F%2Fehall.xidian.edu.cn',
        serviceRequested: true,
      );

      expect(result.kind, IDSRedirectKind.reAuthentication);
      expect(result.uri.host, 'ids.xidian.edu.cn');
    });

    test('recognizes a service ticket callback', () {
      final result = classifyIDSRedirect(
        'https://ehall.xidian.edu.cn/login?ticket=ST-example',
        serviceRequested: true,
      );

      expect(result.kind, IDSRedirectKind.serviceTicket);
    });

    test('recognizes direct IDS success only without a service', () {
      final result = classifyIDSRedirect(
        '/authserver/index.do',
        serviceRequested: false,
      );

      expect(result.kind, IDSRedirectKind.directIDSHome);
      expect(
        () =>
            classifyIDSRedirect('/authserver/index.do', serviceRequested: true),
        throwsA(isA<IDSProtocolException>()),
      );
    });

    test('rejects an unknown redirect', () {
      expect(
        () => classifyIDSRedirect(
          'https://ids.xidian.edu.cn/authserver/unknown.do',
          serviceRequested: true,
        ),
        throwsA(isA<IDSProtocolException>()),
      );
    });
  });

  group('re-authentication responses', () {
    test('parses all known submit states', () {
      expect(
        parseIDSReAuthSubmit({'code': 'reAuth_success', 'msg': '认证成功'}).status,
        IDSReAuthSubmitStatus.success,
      );
      expect(
        parseIDSReAuthSubmit({'code': 'reAuth_failed', 'msg': '验证码错误'}).status,
        IDSReAuthSubmitStatus.failed,
      );
      expect(
        parseIDSReAuthSubmit({
          'code': 'reAuth_unauthorized',
          'msg': '认证已失效',
        }).status,
        IDSReAuthSubmitStatus.unauthorized,
      );
    });

    test('rejects unknown submit states', () {
      expect(
        () => parseIDSReAuthSubmit({'code': 'surprise'}),
        throwsA(isA<IDSProtocolException>()),
      );
    });

    test('parses an SMS delivery and masks the phone number', () {
      final result = parseIDSSmsDelivery({
        'res': 'success',
        'mobile': '15512345678',
        'returnMessage': '验证码已发送至手机',
        'codeTime': 120,
      });

      expect(result.maskedMobile, '155****5678');
      expect(result.retryAfter.inSeconds, 120);
      expect(result.wasAlreadySent, isFalse);
    });

    test('treats code_time_fail as a running cooldown', () {
      final result = parseIDSSmsDelivery({
        'res': 'code_time_fail',
        'returnMessage': '请稍后重试',
        'codeTime': '42',
      });

      expect(result.retryAfter.inSeconds, 42);
      expect(result.wasAlreadySent, isTrue);
    });
  });

  test('fingerprint is a stable-format 128-bit uppercase identifier', () {
    final fingerprint = generateIDSBrowserFingerprint(Random(7));

    expect(fingerprint, hasLength(32));
    expect(fingerprint, matches(RegExp(r'^[0-9A-F]{32}$')));
    expect(generateIDSBrowserFingerprint(Random(7)), fingerprint);
  });

  test(
    'SMS client retries a rejected code without repeating primary login',
    () async {
      final adapter = _QueuedAdapter([
        const _Reply('<html></html>', contentType: 'text/html'),
        const _Reply({
          'code': '1',
          'data': {'reAuthUserNameInput': '测试用户(155****5678)'},
        }),
        const _Reply({
          'res': 'success',
          'mobile': '15512345678',
          'returnMessage': '验证码已发送至手机',
          'codeTime': 120,
        }),
        const _Reply({'code': 'reAuth_failed', 'msg': '验证码错误'}),
        const _Reply({'code': 'reAuth_success', 'msg': '认证成功'}),
        const _Reply(
          '',
          statusCode: 302,
          contentType: 'text/plain',
          headers: {
            'location': ['https://ehall.xidian.edu.cn/login?ticket=ST-example'],
          },
        ),
      ]);
      final dio = Dio(
        BaseOptions(
          contentType: Headers.formUrlEncodedContentType,
          followRedirects: false,
          validateStatus: (status) => status != null && status < 400,
        ),
      )..httpClientAdapter = adapter;
      final client = IDSReAuthClient(
        dio: dio,
        challengeUri: Uri.parse(
          'https://ids.xidian.edu.cn/authserver/reAuthCheck/'
          'reAuthLoginView.do?isMultifactor=true',
        ),
        username: 'test-user',
        service: 'https://ehall.xidian.edu.cn/login',
      );

      final delivery = await client.sendSms();
      expect(delivery.maskedMobile, '155****5678');
      expect(adapter.requests[1].data['reAuthType'], '3');

      await expectLater(
        client.submitSms(code: '000000', trustDevice: false),
        throwsA(isA<IDSReAuthCodeRejectedException>()),
      );
      expect(adapter.requests[3].data['skipTmpReAuth'], 'false');
      final result = await client.submitSms(code: '123456', trustDevice: true);

      expect(result.queryParameters['ticket'], 'ST-example');
      expect(adapter.requests.length, 6);
      expect(adapter.requests[4].data['skipTmpReAuth'], 'true');
      expect(
        adapter.requests.where((request) => request.path.endsWith('/login')),
        hasLength(1),
      );
    },
  );
}

class _Reply {
  const _Reply(
    this.data, {
    this.statusCode = 200,
    this.contentType = 'application/json',
    this.headers = const {},
  });

  final Object data;
  final int statusCode;
  final String contentType;
  final Map<String, List<String>> headers;
}

class _QueuedAdapter implements HttpClientAdapter {
  _QueuedAdapter(this._replies);

  final List<_Reply> _replies;
  final List<RequestOptions> requests = [];
  var _index = 0;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    final reply = _replies[_index++];
    final text = reply.data is String
        ? reply.data as String
        : jsonEncode(reply.data);
    return ResponseBody.fromString(
      text,
      reply.statusCode,
      headers: {
        Headers.contentTypeHeader: [reply.contentType],
        ...reply.headers,
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
