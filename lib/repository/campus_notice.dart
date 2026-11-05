// SPDX-License-Identifier: MPL-2.0

import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart' as html;
import 'package:pool/pool.dart';
import 'package:watermeter/repository/notice_channels.dart';

typedef CampusNotice = ({String title, DateTime date, Uri url, String source});
typedef ListedNotice = ({String title, DateTime? date, Uri url});

final _spaces = RegExp(r'[\s\u200b]+');
String _normalize(String s) => s.replaceAll(_spaces, '').toLowerCase();

final _fullDate = RegExp(
  r'^(20\d\d)[./年-](\d{1,2})[./月-](\d{1,2})(?:日|\s+\d\d:\d\d(?::\d\d)?)?$',
);

DateTime? _date(String raw) {
  final m = _fullDate.firstMatch(raw.trim());
  if (m == null) return null;
  final month = int.parse(m[2]!);
  final date = DateTime.utc(int.parse(m[1]!), month, int.parse(m[3]!));
  return date.month == month ? date : null;
}

DateTime? _published(Element row) {
  // Read isolated list metadata. A deadline in a heading or summary is
  // ambiguous and must never become the publication date.
  final parts = [
    for (final el in [row, ...row.querySelectorAll('*')])
      for (final node in el.nodes.whereType<Text>())
        if (node.text.trim().isNotEmpty) node.text.trim(),
  ];
  for (final part in parts) {
    final date = _date(part.replaceAll(RegExp(r'^[【\[(]|[】\])]$'), ''));
    if (date != null) return date;
  }
  for (var i = 1; i < parts.length; i++) {
    final a = parts[i - 1], b = parts[i];
    final date = _date('$b-$a') ?? _date('$a-$b');
    if (date != null) return date;
  }
  return null;
}

Uri? _link(Uri base, String? href) {
  if (href == null || href.trim().isEmpty || href.startsWith('#')) return null;
  final target = Uri.tryParse(href.trim());
  if (target == null) return null;
  final url = base.resolveUri(target);
  return url.hasAuthority && (url.scheme == 'https' || url.scheme == 'http')
      ? url.removeFragment()
      : null;
}

Document _document(String body, Uri url) {
  if (url.host == 'job.xidian.edu.cn') {
    // The publisher wraps the list in base64 and zlib with per-page offsets.
    final encoded = RegExp(
      r'unzip\("([A-Za-z0-9+/=]+)"\)\.substr\((\d+)\)\)\.substr\((\d+)\)',
    ).firstMatch(body);
    if (encoded != null) {
      final inflated = ascii.decode(zlib.decode(base64.decode(encoded[1]!)));
      final prefix = int.tryParse(encoded[2]!);
      final offset = int.tryParse(encoded[3]!);
      if (prefix == null || prefix > inflated.length || offset == null) {
        throw const FormatException('Invalid employment notice payload');
      }
      final decoded = utf8.decode(base64.decode(inflated.substring(prefix)));
      if (offset > decoded.length) {
        throw const FormatException('Invalid notice offset');
      }
      body = decoded.substring(offset);
    }
  }
  return html.parse(body);
}

({List<ListedNotice> items, Uri? next}) parseNoticeList(
  String body,
  Uri page,
  NoticeChannel channel,
) {
  final doc = _document(body, page);
  final items = <ListedNotice>[];
  for (var row in doc.querySelectorAll(channel.rows)) {
    if (channel.rows == 'td.gk3 a.c5') {
      while (row.localName != 'tr' && row.parent != null) {
        row = row.parent!;
      }
    }
    final anchors = row.localName == 'a'
        ? [row]
        : row.querySelectorAll('a[href]');
    for (final a in anchors) {
      final url = _link(page, a.attributes['href']);
      if (url == null || url == page) continue;
      final heading = a.querySelector(
        'h2,h3,h4,h5,.headline,.tit,p:not(.time)',
      );
      final title =
          (a.attributes['title'] ??
          heading?.text ??
          a.nodes.whereType<Text>().map((n) => n.text).join(' ').trim());
      var value = title.isEmpty ? a.text.trim() : title.trim();
      // Some templates put the date and then the heading in the same anchor.
      value = value
          .replaceFirst(RegExp(r'^20\d\d[-./]\d{1,2}[-./]\d{1,2}\s*'), '')
          .trim();
      if (value.isEmpty || value == '[详细]' || value == '查看详情') continue;
      items.add((title: value, date: _published(row), url: url));
      break;
    }
  }
  if (items.isEmpty) throw const FormatException('Unrecognized notice list');
  Uri? next;
  for (final a in doc.querySelectorAll('a[href]')) {
    if (const {'下一页', '下页', '下一頁'}.contains(a.text.trim()) ||
        a.attributes['rel'] == 'next' ||
        a.parent?.classes.contains('next') == true) {
      next = _link(page, a.attributes['href']);
      break;
    }
  }
  return (items: items, next: next);
}

class CampusNoticeSearch {
  final Dio _dio;
  final List<NoticeChannel> channels;
  CampusNoticeSearch({Dio? client, this.channels = noticeChannels})
    : _dio =
          client ??
          Dio(
            BaseOptions(
              connectTimeout: const Duration(seconds: 8),
              receiveTimeout: const Duration(seconds: 12),
              responseType: ResponseType.plain,
            ),
          );
  void close() => _dio.close(force: true);

  Future<String> _read(Uri uri, CancelToken token) async {
    final body = (await _dio.getUri<String>(uri, cancelToken: token)).data;
    if (body == null) throw const FormatException('Missing notice page');
    return body;
  }

  Future<void> search(
    String keyword,
    CancelToken token, {
    required void Function(List<CampusNotice> hits, String? failedSource)
    onChannel,
    DateTime? now,
  }) async {
    final query = _normalize(keyword);
    if (query.isEmpty) return;
    final china = (now ?? DateTime.now()).toUtc().add(const Duration(hours: 8));
    final today = DateTime.utc(china.year, china.month, china.day);
    final start = today.subtract(const Duration(days: 29));
    final pool = Pool(5);
    try {
      await Future.wait(
        channels.map(
          (channel) => pool.withResource(() async {
            if (token.isCancelled) return;
            final hits = <CampusNotice>[];
            var incomplete = false;
            final visited = <Uri>{};
            final seen = <Uri>{};
            final entry = Uri.parse(channel.url);
            final elapsed = Stopwatch()..start();
            Uri? page = entry;
            try {
              while (page != null && !token.isCancelled) {
                if (elapsed.elapsed.inSeconds >= 45 ||
                    page.origin != entry.origin ||
                    !visited.add(page) ||
                    visited.length > 15) {
                  incomplete = true;
                  break;
                }
                final list = parseNoticeList(
                  await _read(page, token),
                  page,
                  channel,
                );
                var hasNewer = false;
                var freshRows = 0;
                for (final item in list.items) {
                  if (token.isCancelled) return;
                  if (elapsed.elapsed.inSeconds >= 45) {
                    incomplete = true;
                    break;
                  }
                  if (!seen.add(item.url)) continue;
                  freshRows++;
                  var date = item.date;
                  var title = item.title;
                  if (date == null ||
                      (!date.isBefore(start) && title.endsWith('...'))) {
                    // Some VSB lists omit the year or truncate the heading.
                    if (item.url.host == entry.host) {
                      try {
                        final doc = html.parse(await _read(item.url, token));
                        final dateText = RegExp(
                          r'(?:发布日期|发布时间|日期|时间)\s*[:：]\s*(20\d\d[-./]\d{1,2}[-./]\d{1,2})',
                        ).firstMatch(doc.body?.text ?? '');
                        date ??= _date(dateText?[1] ?? '');
                        if (title.endsWith('...')) {
                          final full = doc.querySelector('title')?.text.trim();
                          if (full != null &&
                              full.startsWith(
                                title.substring(0, title.length - 3),
                              )) {
                            title = full
                                .split(RegExp(r'\s*[-_]\s*(?:西安电子科技大学|本科生院)'))
                                .first;
                          } else {
                            incomplete = true;
                          }
                        }
                      } on Exception {
                        incomplete = true;
                      }
                    }
                  }
                  if (date == null) {
                    incomplete = true;
                    hasNewer = true;
                    continue;
                  }
                  if (date.isBefore(start)) continue;
                  hasNewer = true;
                  if (!date.isAfter(today) &&
                      _normalize(title).contains(query)) {
                    hits.add((
                      title: title,
                      date: date,
                      url: item.url,
                      source: channel.source,
                    ));
                  }
                }
                if (freshRows == 0 && list.next != null) incomplete = true;
                page = hasNewer ? list.next : null;
              }
            } on Exception {
              incomplete = true;
            }
            if (!token.isCancelled) {
              onChannel(hits, incomplete ? channel.source : null);
            }
          }),
        ),
      );
    } finally {
      await pool.close();
    }
  }
}
