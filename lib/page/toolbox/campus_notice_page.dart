// SPDX-License-Identifier: MPL-2.0

import 'package:dio/dio.dart';
import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:watermeter/generated/translations.g.dart';
import 'package:watermeter/repository/campus_notice.dart';
import 'package:watermeter/repository/notice_channels.dart';

class CampusNoticePage extends StatefulWidget {
  const CampusNoticePage({super.key});

  @override
  State<CampusNoticePage> createState() => _CampusNoticePageState();
}

class _CampusNoticePageState extends State<CampusNoticePage> {
  final _search = CampusNoticeSearch();
  final _input = TextEditingController();
  CancelToken? _token;
  final _byUrl = <Uri, CampusNotice>{};
  final _failed = <String>{};
  int _checked = 0;

  @override
  void dispose() {
    _token?.cancel();
    _search.close();
    _input.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final keyword = _input.text.trim();
    if (keyword.isEmpty) return;
    FocusScope.of(context).unfocus();
    _token?.cancel();
    final token = CancelToken();
    setState(() {
      _token = token;
      _checked = 0;
      _byUrl.clear();
      _failed.clear();
    });
    await _search.search(
      keyword,
      token,
      onChannel: (hits, failed) {
        if (!mounted || token != _token) return;
        setState(() {
          _checked++;
          for (final hit in hits) {
            _byUrl[hit.url] = hit;
          }
          if (failed != null) _failed.add(failed);
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t.toolbox;
    final running = _token != null && _checked < noticeChannels.length;
    final notices = _byUrl.values.toList()
      ..sort((a, b) {
        final order = b.date.compareTo(a.date);
        return order != 0 ? order : a.title.compareTo(b.title);
      });
    return Scaffold(
      appBar: AppBar(title: Text(t.noticeSearch)),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t.noticeHint,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _input,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => _submit(),
                    decoration: InputDecoration(
                      hintText: t.noticePlaceholder,
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.search),
                        tooltip: t.noticeSearch,
                        onPressed: _submit,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (running)
              LinearProgressIndicator(value: _checked / noticeChannels.length),
            if (_failed.isNotEmpty)
              ExpansionTile(
                title: Text(t.noticeIncomplete),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text((_failed.toList()..sort()).join('、')),
                  ),
                ],
              ),
            if (_token != null && !running && notices.isEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(t.noticeEmpty),
              ),
            Expanded(
              child: ListView.builder(
                itemCount: notices.length,
                itemBuilder: (context, i) {
                  final n = notices[i];
                  final day = n.date.toIso8601String().substring(0, 10);
                  return ListTile(
                    title: Text(n.title),
                    subtitle: Text('${n.source} · $day'),
                    onTap: () async {
                      if (!await launchUrl(
                            n.url,
                            mode: LaunchMode.externalApplication,
                          ) &&
                          context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(t.noticeOpenError)),
                        );
                      }
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
