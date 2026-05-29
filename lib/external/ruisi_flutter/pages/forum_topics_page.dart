// Copyright 2026 BenderBlog Rodriguez and Contributors.
// SPDX-License-Identifier: BSD-3-Clause

import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:watermeter/external/ruisi_flutter/utils/branch_navigation.dart';
import 'package:watermeter/page/public_widget/context_extension.dart';

import '../controller/ruisi_controller.dart';
import '../widgets/topic_list_item.dart';
import 'topic_detail_page.dart';

/// 板块帖子列表页
class ForumTopicsPage extends StatefulWidget {
  final int fid;
  final String name;

  const ForumTopicsPage({super.key, required this.fid, required this.name});

  @override
  State<ForumTopicsPage> createState() => _ForumTopicsPageState();
}

class _ForumTopicsPageState extends State<ForumTopicsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      RuisiController.i.loadTopics(widget.fid, refresh: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Watch((context) {
      final c = RuisiController.i;

      return Scaffold(
        appBar: AppBar(title: Text(widget.name)),
        body: _buildBody(context, c),
      );
    });
  }

  Widget _buildBody(BuildContext context, RuisiController c) {
    if (c.topicLoading.value && c.topics.value.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (c.topics.value.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(FlutterI18n.translate(context, 'ruisi.common.no_topics')),
            const SizedBox(height: 8),
            FilledButton.tonal(
              onPressed: () => c.loadTopics(widget.fid, refresh: true),
              child: Text(
                FlutterI18n.translate(context, 'ruisi.common.refresh'),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => c.loadTopics(widget.fid, refresh: true),
      child: ListView.separated(
        itemCount: c.topics.value.length + (c.hasMoreTopics ? 1 : 0),
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (_, i) {
          if (i == c.topics.value.length) {
            c.loadTopics(widget.fid);
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          final topic = c.topics.value[i];
          return TopicListItem(
            topic: topic,
            onTap: () => context.push(TopicDetailPage(tid: topic.tid)),
          );
        },
      ),
    );
  }
}
