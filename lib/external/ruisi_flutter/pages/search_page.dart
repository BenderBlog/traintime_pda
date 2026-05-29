// Copyright 2026 BenderBlog Rodriguez and Contributors.
// SPDX-License-Identifier: BSD-3-Clause

import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:watermeter/page/public_widget/context_extension.dart';

import '../controller/ruisi_controller.dart';
import '../widgets/topic_list_item.dart';
import 'topic_detail_page.dart';

/// 搜索页面
class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _searchCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    final c = RuisiController.i;
    if (c.searchKeyword.value.isNotEmpty) {
      _searchCtrl.text = c.searchKeyword.value;
    }
    _scrollCtrl.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollCtrl.removeListener(_onScroll);
    _scrollCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onScroll() {
    final c = RuisiController.i;
    if (_scrollCtrl.position.pixels >=
            _scrollCtrl.position.maxScrollExtent - 200 &&
        c.hasMoreSearch &&
        !c.searchLoading.value) {
      c.searchMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Watch((context) {
      final c = RuisiController.i;

      return Scaffold(
        appBar: AppBar(
          title: TextField(
            controller: _searchCtrl,
            autofocus: true,
            decoration: InputDecoration(
              hintText: FlutterI18n.translate(context, 'ruisi.search.hint'),
              border: InputBorder.none,
            ),
            onSubmitted: (v) {
              if (v.trim().isNotEmpty) {
                c.search(v.trim());
              }
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                final q = _searchCtrl.text.trim();
                if (q.isNotEmpty) c.search(q);
              },
            ),
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _searchCtrl.clear();
                c.clearSearch();
              },
            ),
          ],
        ),
        body: c.searchLoading.value
            ? const Center(child: CircularProgressIndicator())
            : c.searchError.value != null
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    c.searchError.value!,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              )
            : c.searchResults.value.isEmpty
            ? Center(
                child: Text(
                  c.searchKeyword.value.isEmpty
                      ? FlutterI18n.translate(
                          context,
                          'ruisi.search.input_hint',
                        )
                      : FlutterI18n.translate(
                          context,
                          'ruisi.search.no_results',
                        ),
                ),
              )
            : ListView.separated(
                controller: _scrollCtrl,
                itemCount: c.searchResults.value.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (_, i) {
                  final topic = c.searchResults.value[i];
                  // 最后一项后显示加载更多指示器
                  final isLast = i == c.searchResults.value.length - 1;
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TopicListItem(
                        topic: topic,
                        onTap: () =>
                            context.push(TopicDetailPage(tid: topic.tid)),
                      ),
                      if (isLast && c.hasMoreSearch)
                        const Padding(
                          padding: EdgeInsets.all(16),
                          child: CircularProgressIndicator(),
                        ),
                    ],
                  );
                },
              ),
      );
    });
  }
}
