// Copyright 2026 Traintime PDA authors, originally by Hazuki Keatsu
// SPDX-License-Identifier: MPL-2.0

import 'package:dio/dio.dart';
import 'package:pda_network/pda_network.dart';
import 'package:pda_repository/pda_repository.dart';
import 'package:test/test.dart';

void main() {
  test(
    'fetches the legacy update response through the network package',
    () async {
      final dio = Dio();
      final response = <String, Object>{
        'code': '1.3.0',
        'update': <String>['New timetable'],
        'ioslink': 'https://example.org/ios',
        'fdroid': 'https://example.org/android',
        'github': 'https://example.org/releases',
      };
      String? requestedUrl;
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            requestedUrl = options.uri.toString();
            handler.resolve(Response(requestOptions: options, data: response));
          },
        ),
      );
      final UpdateRepository repository = DioUpdateRepository(dio: dio);

      final release = await repository.fetchLatest();
      expect(release.code, '1.3.0');
      expect(release.changes, ['New timetable']);
      expect(release.androidUrl, 'https://example.org/android');
      expect(
        requestedUrl,
        'https://legacy.superbart.top/traintime_pda_backend/version.json',
      );
      response['fdroid'] = 'javascript:alert(1)';
      await expectLater(repository.fetchLatest(), throwsFormatException);
      response['fdroid'] = 'https://example.org/android';
      response['code'] = 'invalid';
      await expectLater(repository.fetchLatest(), throwsFormatException);
      (repository as DioUpdateRepository).close();
    },
  );
}
