// Copyright 2026 xichen778
// SPDX-License-Identifier: MPL-2.0

import 'package:dio/dio.dart';
import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:watermeter/generated/translations.g.dart';
import 'package:watermeter/page/public_widget/public_widget.dart';

import 'campus_notice_search.dart';
import 'notice_channels.dart';

class CampusNoticePage extends StatefulWidget {
  const CampusNoticePage({super.key, required this.dio});

  final Dio dio;

  @override
  State<CampusNoticePage> createState() => _CampusNoticePageState();
}

class _CampusNoticePageState extends State<CampusNoticePage> {
  final _input = TextEditingController();
  CancelToken? _token;
  final _byUrl = <Uri, CampusNotice>{};
  final _failed = <String>{};
  int _checked = 0;
  String? _lastKeyword;

  @override
  void dispose() {
    _token?.cancel();
    _input.dispose();
    super.dispose();
  }

  Future<void> _submit({String? keyword}) async {
    final query = (keyword ?? _input.text).trim();
    if (query.isEmpty) return;
    if (keyword != null) _input.text = query;
    FocusScope.of(context).unfocus();
    _token?.cancel();
    final token = CancelToken();
    setState(() {
      _token = token;
      _lastKeyword = query;
      _checked = 0;
      _byUrl.clear();
      _failed.clear();
    });
    await CampusNoticeSearch(client: widget.dio).search(
      query,
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
                        onPressed: () => _submit(),
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
            if (_token != null &&
                !running &&
                notices.isEmpty &&
                _failed.isEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(t.noticeEmpty),
              ),
            Expanded(
              child:
                  _token != null &&
                      !running &&
                      notices.isEmpty &&
                      _failed.isNotEmpty
                  ? ReloadWidget(function: () => _submit(keyword: _lastKeyword))
                  : ListView.builder(
                      itemCount: notices.length,
                      itemBuilder: (context, i) {
                        final n = notices[i];
                        return ListTile(
                          title: Text(n.title),
                          subtitle: Text(
                            '${n.source} · ${n.date.toIso8601String().substring(0, 10)}',
                          ),
                          onTap: () async {
                            bool result = await launchUrl(
                              n.url,
                              mode: LaunchMode.externalApplication,
                            );
                            if (!result && context.mounted) {
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
