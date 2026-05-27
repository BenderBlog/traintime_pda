// Copyright 2026 BenderBlog Rodriguez and Contributors.
// SPDX-License-Identifier: BSD-3-Clause

import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';
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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      RuisiController.i.loadForums();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Watch((context) {
      final c = RuisiController.i;

      if (c.forumLoading.value && c.forumGroups.value.isEmpty) {
        return Scaffold(
          appBar: AppBar(title: Text(FlutterI18n.translate(context, 'ruisi.forum_list.title'))),
          body: const Center(child: CircularProgressIndicator()),
        );
      }

      return Scaffold(
        appBar: AppBar(title: Text(FlutterI18n.translate(context, 'ruisi.forum_list.title'))),
        body: RefreshIndicator(
          onRefresh: () => c.loadForums(),
          child: ListView.builder(
            itemCount: c.forumGroups.value.length,
            itemBuilder: (_, i) {
              final group = c.forumGroups.value[i];
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
        ),
      );
    });
  }
}
