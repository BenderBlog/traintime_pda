// Copyright 2026 Traintime PDA authors, originally by Hazuki Keatsu
// SPDX-License-Identifier: MPL-2.0

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'package:watermeter/integration/setup/network_logging.dart';

void main() {
  test(
    'network logs include status without retaining request secrets',
    () async {
      final talker = Talker(logger: TalkerLogger(output: (_) {}));
      final dio = createLoggedDio(talker);
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            handler.resolve(
              Response(requestOptions: options, statusCode: 200),
              true,
            );
          },
        ),
      );

      await dio.post<void>(
        'https://ids.xidian.edu.cn/login?ticket=secret-ticket',
        data: {'password': 'secret-password'},
        options: Options(headers: {'Cookie': 'secret-cookie'}),
      );

      final messages = talker.history.map((entry) => entry.message).join('\n');
      expect(messages, contains('POST'));
      expect(messages, contains('ids.xidian.edu.cn'));
      expect(messages, contains('200'));
      expect(messages, isNot(contains('secret')));
      dio.close();
    },
  );

  test('network failures are recorded without exception details', () async {
    final talker = Talker(logger: TalkerLogger(output: (_) {}));
    final dio = createLoggedDio(talker);
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          handler.reject(
            DioException(requestOptions: options, message: 'secret'),
            true,
          );
        },
      ),
    );

    await expectLater(
      dio.get<void>('https://example.org/'),
      throwsA(isA<DioException>()),
    );
    final messages = talker.history.map((entry) => entry.message).join('\n');
    expect(messages, contains('unknown'));
    expect(messages, isNot(contains('secret')));
    dio.close();
  });
}
