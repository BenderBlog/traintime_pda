// Copyright 2026 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:watermeter/repository/network_client.dart';

void main() {
  late Directory testSupportPath;

  setUpAll(() async {
    testSupportPath = await Directory.systemTemp.createTemp(
      'traintime_network_clients_test_',
    );
    supportPath = testSupportPath;
  });

  tearDownAll(() async {
    await testSupportPath.delete(recursive: true);
  });

  test('IDS and eHall use distinct Dio instances with one cookie jar', () {
    final idsDio = NetworkClients.idsDio;
    final ehallDio = NetworkClients.ehallDio;

    expect(identical(idsDio, ehallDio), isFalse);
    expect(
      identical(
        _cookieManager(idsDio).cookieJar,
        _cookieManager(ehallDio).cookieJar,
      ),
      isTrue,
    );
  });

  test('eHall headers are scoped to the eHall host', () async {
    final adapter = _RecordingAdapter();
    final dio = NetworkClients.ehallDio..httpClientAdapter = adapter;

    await dio.get('https://ehall.xidian.edu.cn/probe');
    await dio.get('https://ids.xidian.edu.cn/authserver/login');

    final ehallRequest = adapter.requests[0];
    final idsRequest = adapter.requests[1];
    expect(
      ehallRequest.headers[HttpHeaders.refererHeader],
      'http://ehall.xidian.edu.cn/new/index_xd.html',
    );
    expect(ehallRequest.headers, isNot(contains(HttpHeaders.hostHeader)));
    expect(idsRequest.headers, isNot(contains(HttpHeaders.refererHeader)));
    expect(idsRequest.headers, isNot(contains(HttpHeaders.hostHeader)));
  });

  test('other client is stateless', () {
    expect(
      NetworkClients.otherDio.interceptors.whereType<CookieManager>(),
      isEmpty,
    );
  });
}

CookieManager _cookieManager(Dio dio) =>
    dio.interceptors.whereType<CookieManager>().single;

class _RecordingAdapter implements HttpClientAdapter {
  final List<RequestOptions> requests = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    return ResponseBody.fromString(
      '{}',
      HttpStatus.ok,
      headers: {
        HttpHeaders.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
