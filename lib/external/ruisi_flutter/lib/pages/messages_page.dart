// Copyright 2026 BenderBlog Rodriguez and Contributors.
// SPDX-License-Identifier: BSD-3-Clause
/*

import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:watermeter/page/public_widget/context_extension.dart';

import '../controller/ruisi_controller.dart';
import 'topic_detail_page.dart';
import 'login_page.dart';

/// 消息通知页面

class MessagesPage extends StatefulWidget {
  const MessagesPage({super.key});

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final c = RuisiController.i;
      if (!c.isLoggedIn) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
        );
        return;
      }
      c.loadMessages();
    });
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SignalBuilder(builder: (context) {
      final c = RuisiController.i;

      return Scaffold(
        appBar: AppBar(
          title: Text(FlutterI18n.translate(context, 'ruisi.messages.title')),
          bottom: TabBar(
            controller: _tabCtrl,
            tabs: [
              Tab(text: FlutterI18n.translate(context, 'ruisi.common.reply')),
              Tab(text: FlutterI18n.translate(context, 'ruisi.messages.tab_at')),
            ],
          ),
        ),
        body: c.messageLoading.value
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                controller: _tabCtrl,
                children: [
                  c.replyNotifications.value.isEmpty
                      ? Center(child: Text(FlutterI18n.translate(context, 'ruisi.messages.no_reply')))
                      : _buildReplyList(c),
                  c.atNotifications.value.isEmpty
                      ? Center(child: Text(FlutterI18n.translate(context, 'ruisi.messages.no_at')))
                      : _buildAtList(c),
                ],
              ),
      );
    });
  }

  Widget _buildReplyList(RuisiController c) {
    return RefreshIndicator(
      onRefresh: () async => c.loadMessages(),
      child: ListView.separated(
        itemCount: c.replyNotifications.value.length,
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (_, i) {
          final item = c.replyNotifications.value[i];
          return ListTile(
            leading: CircleAvatar(
              child: Text(item.author.isNotEmpty ? item.author[0] : '?'),
            ),
            title: Text(item.title),
            subtitle: Text(
              '${item.author}: ${item.snippet}',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Text(
              item.time,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            onTap: () => context.push(TopicDetailPage(tid: item.tid)),
          );
        },
      ),
    );
  }

  Widget _buildAtList(RuisiController c) {
    return RefreshIndicator(
      onRefresh: () async => c.loadMessages(),
      child: ListView.separated(
        itemCount: c.atNotifications.value.length,
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (_, i) {
          final item = c.atNotifications.value[i];
          return ListTile(
            leading: CircleAvatar(
              child: Text(item.author.isNotEmpty ? item.author[0] : '?'),
            ),
            title: Text(item.title),
            subtitle: Text(
              '${item.author}: ${item.snippet}',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Text(
              item.time,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            onTap: () => context.push(TopicDetailPage(tid: item.tid)),
          );
        },
      ),
    );
  }
}
*/
