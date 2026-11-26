// Copyright 2026 Traintime PDA authors, originally by Hazuki Keatsu
// SPDX-License-Identifier: MPL-2.0

import 'package:dio/dio.dart';
import 'package:talker_flutter/talker_flutter.dart';

Dio createLoggedDio(Talker talker, {BaseOptions? options}) {
  final dio = Dio(options);
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (request, handler) {
        talker.debug('HTTP ${request.method} ${request.uri.host}');
        handler.next(request);
      },
      onResponse: (response, handler) {
        final request = response.requestOptions;
        talker.debug(
          'HTTP ${request.method} ${request.uri.host} ${response.statusCode}',
        );
        handler.next(response);
      },
      onError: (error, handler) {
        final request = error.requestOptions;
        talker.error(
          'HTTP ${request.method} ${request.uri.host} ${error.response?.statusCode ?? error.type.name}',
        );
        handler.next(error);
      },
    ),
  );
  return dio;
}
