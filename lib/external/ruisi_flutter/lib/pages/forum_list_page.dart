// Copyright 2026 BenderBlog Rodriguez and Contributors.
// SPDX-License-Identifier: BSD-3-Clause

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:watermeter/page/public_widget/context_extension.dart';

import '../controller/ruisi_controller.dart';
import 'forum_topics_page.dart';

/// 板块列表页面
class ForumListPage extends StatefulWidget {
  const ForumListPage({super.key});

  @override
  State<ForumListPage> createState() => _ForumListPageState();
}

class _ForumListPageState extends State<ForumListPage> {
  final c = GetIt.instance<RuisiService>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      c.loadForums();
    });
  }

  @override
  Widget build(BuildContext context) {
    final title = FlutterI18n.translate(context, 'ruisi.forum_list.title');

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      // 使用 ValueListenableBuilder 统一监听单一状态
      body: ValueListenableBuilder<ForumState>(
        valueListenable: c.forumState,
        builder: (context, state, child) {
          // 1. 错误状态处理 (当发生错误且当前没有缓存数据时)
          if (state.hasError && state.groups.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    state.errorMessage ?? "加载失败",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => c.loadForums(),
                    icon: const Icon(Icons.refresh),
                    label: const Text("点击重试"),
                  ),
                ],
              ),
            );
          }

          // 2. 纯加载状态处理 (第一次打开页面，没有数据时的转圈)
          if (state.isLoading && state.groups.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          // 3. 空数据状态处理
          if (state.groups.isEmpty) {
            return Center(
              child: Text(
                FlutterI18n.translate(context, 'ruisi.forum_list.empty'),
              ),
            );
          }

          // 4. 正常数据展示 (支持下拉刷新)
          return RefreshIndicator(
            onRefresh: () => c.loadForums(),
            child: ListView.builder(
              itemCount: state.groups.length,
              itemBuilder: (_, i) {
                final group = state.groups[i];
                return ExpansionTile(
                  title: Text(
                    group.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  initiallyExpanded: i == 0,
                  children: group.forums.map((forum) {
                    return ListTile(
                      leading: const Icon(Icons.forum_outlined),
                      title: Text(forum.name),
                      subtitle: (forum.description ?? "").isNotEmpty
                          ? Text(
                              forum.description ?? "",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            )
                          : null,
                      onTap: () => context.push(
                        ForumTopicsPage(fid: forum.fid, name: forum.name),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
