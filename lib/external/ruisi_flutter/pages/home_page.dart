// Copyright 2026 BenderBlog Rodriguez and Contributors.
// SPDX-License-Identifier: BSD-3-Clause

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:signals/signals_flutter.dart';
import 'package:watermeter/page/public_widget/context_extension.dart';

import '../controller/ruisi_controller.dart';
import '../widgets/topic_list_item.dart';
import 'topic_detail_page.dart';
import 'forum_list_page.dart';
import 'login_page.dart';
import 'user_page.dart';
import 'favorites_page.dart';
import 'new_post_page.dart';
import 'settings_page.dart';
import 'about_page.dart';

/// 首页
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final c = RuisiController.i;
      c.loadHotTopics();
      c.loadNewReplyTopics(refresh: true);
      c.loadNewTopics(refresh: true);
    });
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Watch((context) {
      final c = RuisiController.i;

      return Scaffold(
        appBar: AppBar(
          title: Text(FlutterI18n.translate(context, 'ruisi.home.title')),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit_note),
              tooltip: FlutterI18n.translate(context, 'ruisi.home.new_post'),
              onPressed: () => context.push(const NewPostPage()),
            ),
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      FlutterI18n.translate(
                        context,
                        'ruisi.common.not_implemented',
                      ),
                    ),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.forum),
              tooltip: FlutterI18n.translate(context, 'ruisi.home.forum_list'),
              onPressed: () => context.push(const ForumListPage()),
            ),
          ],
          bottom: TabBar(
            controller: _tabCtrl,
            tabs: [
              Tab(text: FlutterI18n.translate(context, 'ruisi.home.tab_hot')),
              Tab(
                text: FlutterI18n.translate(
                  context,
                  'ruisi.home.tab_new_reply',
                ),
              ),
              Tab(
                text: FlutterI18n.translate(context, 'ruisi.home.tab_new_post'),
              ),
              Tab(text: FlutterI18n.translate(context, 'ruisi.home.tab_my')),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabCtrl,
          children: [
            _buildTopicList(
              context,
              topics: c.hotTopics.value,
              isLoading: c.hotLoading.value,
              onRefresh: () => c.loadHotTopics(),
            ),
            _buildTopicList(
              context,
              topics: c.newReplyTopics.value,
              isLoading: c.newReplyLoading.value,
              onRefresh: () => c.loadNewReplyTopics(refresh: true),
              onLoadMore: c.hasMoreNewReply
                  ? () => c.loadNewReplyTopics()
                  : null,
            ),
            _buildTopicList(
              context,
              topics: c.newTopics.value,
              isLoading: c.newLoading.value,
              onRefresh: () => c.loadNewTopics(refresh: true),
              onLoadMore: c.hasMoreNew ? () => c.loadNewTopics() : null,
            ),
            _buildMyTab(context, c),
          ],
        ),
      );
    });
  }

  Widget _buildTopicList(
    BuildContext context, {
    required List topics,
    required bool isLoading,
    VoidCallback? onRefresh,
    VoidCallback? onLoadMore,
  }) {
    if (isLoading && topics.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (topics.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(FlutterI18n.translate(context, 'ruisi.common.no_content')),
            const SizedBox(height: 8),
            FilledButton.tonal(
              onPressed: onRefresh,
              child: Text(
                FlutterI18n.translate(context, 'ruisi.common.refresh'),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => onRefresh?.call(),
      child: ListView.separated(
        itemCount: topics.length + (onLoadMore != null ? 1 : 0),
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (_, i) {
          if (i == topics.length) {
            onLoadMore?.call();
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          final topic = topics[i];
          return TopicListItem(
            topic: topic,
            onTap: () =>
                context.pushReplacement(TopicDetailPage(tid: topic.tid)),
          );
        },
      ),
    );
  }

  Widget _buildMyTab(BuildContext context, RuisiController c) {
    if (!c.isLoggedIn) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.person_outline, size: 64),
            const SizedBox(height: 16),
            Text(FlutterI18n.translate(context, 'ruisi.home.please_login')),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                );
              },
              child: Text(FlutterI18n.translate(context, 'ruisi.common.login')),
            ),
          ],
        ),
      );
    }

    return ListView(
      children: [
        ListTile(
          leading: const Icon(Icons.person),
          title: Text(FlutterI18n.translate(context, 'ruisi.home.my_profile')),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => context.pushReplacement(const UserPage(initialTab: 1)),
        ),
        ListTile(
          leading: const Icon(Icons.article),
          title: Text(FlutterI18n.translate(context, 'ruisi.home.my_posts')),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => context.pushReplacement(const UserPage()),
        ),
        ListTile(
          leading: const Icon(Icons.bookmark),
          title: Text(
            FlutterI18n.translate(context, 'ruisi.home.my_favorites'),
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => context.pushReplacement(const FavoritesPage()),
        ),
        ListTile(
          leading: const Icon(Icons.notifications),
          title: Text(
            FlutterI18n.translate(context, 'ruisi.home.message_center'),
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  FlutterI18n.translate(
                    context,
                    'ruisi.common.not_implemented',
                  ),
                ),
              ),
            );
          },
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.edit_calendar),
          title: Text(
            FlutterI18n.translate(context, 'ruisi.home.daily_checkin'),
          ),
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  FlutterI18n.translate(
                    context,
                    'ruisi.common.not_implemented',
                  ),
                ),
              ),
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.settings),
          title: Text(FlutterI18n.translate(context, 'ruisi.home.settings')),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => context.pushReplacement(SettingsPage(talker: c.talker)),
        ),
        ListTile(
          leading: const Icon(Icons.info_outline),
          title: Text(FlutterI18n.translate(context, 'ruisi.home.about')),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => context.pushReplacement(const AboutPage()),
        ),
        const Divider(),
        ListTile(
          leading: Icon(
            Icons.logout,
            color: Theme.of(context).colorScheme.error,
          ),
          title: Text(
            FlutterI18n.translate(context, 'ruisi.common.logout'),
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
          onTap: () async {
            await c.logout();
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  FlutterI18n.translate(context, 'ruisi.common.logged_out'),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
