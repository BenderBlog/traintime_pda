// Copyright 2026 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:watermeter/repository/network_client.dart';
import 'package:watermeter/repository/xidian_ids/ids_auth_protocol.dart';
import 'package:watermeter/repository/xidian_ids/ids_reauth_client.dart';
import 'package:watermeter/repository/xidian_ids/ids_session.dart';

void main() {
  late Directory testSupportPath;

  setUpAll(() async {
    testSupportPath = await Directory.systemTemp.createTemp(
      'traintime_ids_redirect_test_',
    );
    supportPath = testSupportPath;
  });

  tearDownAll(() async {
    await testSupportPath.delete(recursive: true);
  });

  group('isIDSReAuthLocation', () {
    test('recognizes the exact IDS re-authentication endpoint', () {
      expect(
        isIDSReAuthLocation(
          'https://ids.xidian.edu.cn/authserver/'
          'reAuthCheck/reAuthLoginView.do?isMultifactor=true',
        ),
        isTrue,
      );
    });

    test('resolves a relative re-authentication location', () {
      expect(
        isIDSReAuthLocation(
          'reAuthCheck/reAuthLoginView.do',
          baseUri: Uri.parse('https://ids.xidian.edu.cn/authserver/login'),
        ),
        isTrue,
      );
    });

    test('passes through a nested authserver login', () {
      expect(
        isIDSReAuthLocation(
          'https://ids.xidian.edu.cn:443/authserver/login?'
          'service=http%3A%2F%2Fehall.xidian.edu.cn%2Fauthserver%2Flogin%3F'
          'service%3Dhttps%253A%252F%252Fyjspt.xidian.edu.cn%252Fgsapp%252F'
          'sys%252Fyjsemaphome%252Fportal%252Findex.do',
        ),
        isFalse,
      );
    });

    test('passes through service tickets and rejects lookalike hosts', () {
      expect(
        isIDSReAuthLocation(
          'https://ehall.xidian.edu.cn/login?ticket=ST-example',
        ),
        isFalse,
      );
      expect(
        isIDSReAuthLocation(
          'https://ids.xidian.edu.cn.example.com/authserver/'
          'reAuthCheck/reAuthLoginView.do',
        ),
        isFalse,
      );
    });
  });

  test('checks re-authentication on a later redirect hop', () async {
    const nestedService =
        'http://ehall.xidian.edu.cn/authserver/login?'
        'service=https%3A%2F%2Fyjspt.xidian.edu.cn%2Fportal';
    final adapter = _RouteAdapter((request) {
      switch (request.uri.path) {
        case '/start':
          return _redirect(
            'https://ids.xidian.edu.cn/authserver/login?'
            'service=${Uri.encodeQueryComponent(nestedService)}',
          );
        case '/authserver/login':
          return _redirect(
            '/authserver/reAuthCheck/reAuthLoginView.do?isMultifactor=true',
          );
        case '/after-mfa':
          return _redirect('/done');
        case '/done':
          return ResponseBody.fromString('done', HttpStatus.ok);
        default:
          throw StateError('Unexpected request: ${request.uri}');
      }
    });
    final dio = _testDio(adapter);
    final session = _RecordingIDSSession(
      resumedUri: Uri.parse('https://service.example/after-mfa'),
    );

    final response = await session.followIDSRedirects(
      initialLocation: 'https://service.example/start',
      client: dio,
    );

    expect(response.realUri, Uri.parse('https://service.example/done'));
    expect(session.reAuthLocations, hasLength(1));
    expect(session.reAuthServices, [nestedService]);
    expect(
      adapter.requestedUris,
      isNot(
        contains(
          Uri.parse(
            'https://ids.xidian.edu.cn/authserver/'
            'reAuthCheck/reAuthLoginView.do?isMultifactor=true',
          ),
        ),
      ),
    );
  });

  test('stops after more than 30 redirects', () async {
    final adapter = _RouteAdapter((request) {
      final current = int.tryParse(request.uri.pathSegments.last) ?? 0;
      return _redirect('/loop/${current + 1}');
    });
    final session = _RecordingIDSSession(
      resumedUri: Uri.parse('https://service.example/unused'),
    );

    await expectLater(
      session.followIDSRedirects(
        initialLocation: 'https://service.example/loop/0',
        client: _testDio(adapter),
      ),
      throwsA(
        isA<LoginFailedException>().having(
          (error) => error.msg,
          'message',
          contains('30'),
        ),
      ),
    );
    expect(adapter.requestedUris, hasLength(31));
  });
}

Dio _testDio(HttpClientAdapter adapter) {
  return Dio(
    BaseOptions(
      followRedirects: false,
      validateStatus: (status) => status != null && status < 400,
    ),
  )..httpClientAdapter = adapter;
}

ResponseBody _redirect(String location) {
  return ResponseBody.fromString(
    '',
    HttpStatus.found,
    isRedirect: true,
    headers: {
      HttpHeaders.locationHeader: [location],
    },
  );
}

class _RouteAdapter implements HttpClientAdapter {
  _RouteAdapter(this.route);

  final ResponseBody Function(RequestOptions request) route;
  final List<Uri> requestedUris = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requestedUris.add(options.uri);
    return route(options);
  }

  @override
  void close({bool force = false}) {}
}

class _RecordingIDSSession extends IDSSession {
  _RecordingIDSSession({required this.resumedUri});

  final Uri resumedUri;
  final List<Uri> reAuthLocations = [];
  final List<String?> reAuthServices = [];

  @override
  Future<Uri> resolveIDSReAuthIfNeeded(
    Uri uri, {
    String? service,
    String? username,
    IDSReAuthHandler? reAuthHandler,
    void Function(int, String)? onResponse,
  }) async {
    if (!isIDSReAuthLocation(uri.toString())) return uri;
    reAuthLocations.add(uri);
    reAuthServices.add(service);
    return resumedUri;
  }
}
