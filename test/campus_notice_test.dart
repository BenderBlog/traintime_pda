// SPDX-License-Identifier: MPL-2.0

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:watermeter/generated/translations.g.dart';
import 'package:watermeter/page/toolbox/toolbox_page.dart';
import 'package:watermeter/repository/campus_notice.dart';
import 'package:watermeter/repository/notice_channels.dart';

void main() {
  testWidgets('opens campus notice search from the toolbox', (tester) async {
    await tester.pumpWidget(
      TranslationProvider(child: const MaterialApp(home: ToolBoxPage())),
    );
    await tester.tap(find.text(t.toolbox.noticeSearch));
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text(t.toolbox.noticeHint), findsOneWidget);
  });
  const primary = NoticeChannel('教务处', 'https://jwc.xidian.edu.cn/list', 'li');
  const broken = NoticeChannel('学院', 'https://example.edu.cn/list', 'li');

  test(
    'search spans pages, preserves partial results, and uses China dates',
    () async {
      final dio = Dio();
      final pages = {
        primary.url: '''
        <ul><li><a href="/pinned">转专业旧通知</a><span>2021-01-01</span></li>
        <li><a href="/recent">转 专业通知</a><span>2026-11-05</span></li>
        <li><a href="/other">十月教学安排</a><span>2026-10-15</span><p>转专业</p></li></ul>
        <a href="archive">下页</a>''',
        'https://jwc.xidian.edu.cn/archive': '''
        <ul><li><a href="/recent">转 专业通知</a><span>2026-11-05</span></li>
        <li><a href="/boundary">转专业公示</a><span>2026-10-07</span></li>
        <li><a href="/expired">转专业安排</a><span>2026-10-06</span></li>
        <li><a href="/future">转专业报名</a><span>2026-11-06</span></li></ul>''',
        broken.url: '<html>Maintenance</html>',
      };
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            handler.resolve(
              Response(
                requestOptions: options,
                data: pages[options.uri.toString()],
              ),
            );
          },
        ),
      );
      final search = CampusNoticeSearch(
        client: dio,
        channels: [primary, broken],
      );
      addTearDown(search.close);
      final hits = <CampusNotice>[], failures = <String>[];
      await search.search(
        '转专业',
        CancelToken(),
        now: DateTime.utc(2026, 11, 4, 16),
        onChannel: (items, source) {
          hits.addAll(items);
          if (source != null) failures.add(source);
        },
      );
      expect(hits.map((e) => e.url.path), ['/recent', '/boundary']);
      expect(failures, ['学院']);
    },
  );

  test('uses display date and heading separately on split-date cards', () {
    final list = parseNoticeList(
      '''
      <ul><li><a href="info/1"><div><b>05</b><i>2026.11</i></div>
      <h5>报名通知</h5><p>截止日期 2026-12-01</p></a></li></ul>''',
      Uri.parse(primary.url),
      primary,
    );
    expect(list.items.single.date, DateTime.utc(2026, 11, 5));
    expect(list.items.single.title, '报名通知');
  });
}
