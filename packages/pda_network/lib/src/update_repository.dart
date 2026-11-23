// Copyright 2026 Hazuki Keatsu
// SPDX-License-Identifier: MPL-2.0

import 'package:dio/dio.dart';
import 'package:pda_repository/pda_repository.dart';

final class DioUpdateRepository implements UpdateRepository {
  DioUpdateRepository({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 10),
            ),
          );

  static const updateEndpoint =
      'https://legacy.superbart.top/traintime_pda_backend/version.json';

  final Dio _dio;

  @override
  Future<UpdateReleaseData> fetchLatest() async {
    final data = (await _dio.get<Object?>(updateEndpoint)).data;
    if (data is! Map<String, dynamic>) {
      throw const FormatException('Invalid update response');
    }
    final code = data['code'];
    final changes = data['update'];
    final ios = data['ioslink'];
    final android = data['fdroid'];
    final github = data['github'];
    if (code is! String ||
        !RegExp(r'^\d+(?:\.\d+)*$').hasMatch(code) ||
        changes is! List ||
        !changes.every((item) => item is String) ||
        ios is! String ||
        android is! String ||
        github is! String ||
        !_isHttps(ios) ||
        !_isHttps(android) ||
        !_isHttps(github)) {
      throw const FormatException('Invalid update response');
    }
    return (
      code: code,
      changes: List<String>.unmodifiable(changes),
      iosUrl: ios,
      androidUrl: android,
      githubUrl: github,
    );
  }

  bool _isHttps(String value) {
    final uri = Uri.tryParse(value);
    return uri?.scheme == 'https' && uri!.host.isNotEmpty;
  }

  void close() => _dio.close();
}
