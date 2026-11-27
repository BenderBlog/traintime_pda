// SPDX-License-Identifier: MPL-2.0

// Live test: flutter test test/external/campus_notice/campus_notice_sources_test.dart
// Requires network access to the configured campus websites.

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:watermeter/external/campus_notice/lib/campus_notice_search.dart';
import 'package:watermeter/external/campus_notice/lib/notice_channels.dart';
import 'package:watermeter/repository/network_client.dart';

void main() {
  group('Campus notice sources (live)', () {
    for (final channel in noticeChannels) {
      test('${channel.source} (${channel.url})', () async {
        final url = Uri.parse(channel.url);
        final response = await NetworkClients.otherDio.getUri<String>(
          url,
          options: Options(
            connectTimeout: const Duration(seconds: 8),
            receiveTimeout: const Duration(seconds: 12),
            responseType: ResponseType.plain,
            followRedirects: true,
            validateStatus: (status) =>
                status != null && status >= 200 && status < 300,
          ),
        );

        final body = response.data;
        expect(body, isNotNull, reason: '${channel.source}: 响应内容为空');
        expect(body, isNotEmpty, reason: '${channel.source}: 响应内容为空');

        final parsed = parseNoticeList(body!, url, channel);
        expect(
          parsed.items,
          isNotEmpty,
          reason: '${channel.source}: 选择器 ${channel.rows} 未解析出通知',
        );
        for (final item in parsed.items) {
          expect(item.title.trim(), isNotEmpty, reason: channel.source);
          expect(
            item.url.scheme,
            anyOf('http', 'https'),
            reason: '${channel.source}: 无效链接 ${item.url}',
          );
          expect(item.url.host, isNotEmpty, reason: channel.source);
        }
      }, timeout: const Timeout(Duration(seconds: 40)));
    }
  });
}
