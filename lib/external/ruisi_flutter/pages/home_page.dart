// Copyright 2026 BenderBlog Rodriguez and Contributors.
// SPDX-License-Identifier: BSD-3-Clause

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:signals/signals_flutter.dart';
import 'package:watermeter/external/ruisi_flutter/pages/search_page.dart';
import 'package:watermeter/page/public_widget/context_extension.dart';

import '../controller/ruisi_controller.dart';
import '../utils/branch_navigation.dart';
import '../widgets/topic_list_item.dart';
import 'topic_detail_page.dart';
import '../constants/urls.dart';
import 'forum_list_page.dart';
import 'login_page.dart';
import 'user_page.dart';
import 'new_post_page.dart';

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
    _tabCtrl = TabController(length: 7, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final c = RuisiController.i;
      c.loadNewTopics(refresh: true);
      c.loadNewReplyTopics(refresh: true);
      c.loadWater(refresh: true);
      c.loadPhotography(refresh: true);
      c.loadTrade(refresh: true);
      c.loadEmployment(refresh: true);
      c.loadLostFound(refresh: true);
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
              icon: const Icon(Icons.search),
              tooltip: FlutterI18n.translate(context, 'ruisi.home.search'),
              onPressed: () => context.pushRuisiBranch(const SearchPage()),
            ),
            IconButton(
              icon: const Icon(Icons.edit_note),
              tooltip: FlutterI18n.translate(context, 'ruisi.home.new_post'),
              onPressed: () => context.pushRuisiBranch(const NewPostPage()),
            ),
            IconButton(
              icon: const Icon(Icons.forum),
              tooltip: FlutterI18n.translate(context, 'ruisi.home.forum_list'),
              onPressed: () => context.pushRuisiBranch(const ForumListPage()),
            ),
            _buildUserButton(context, c),
          ],
          bottom: TabBar(
            isScrollable: true,
            controller: _tabCtrl,
            tabs: [
              Tab(
                text: FlutterI18n.translate(context, 'ruisi.home.tab_new_post'),
              ),
              Tab(
                text: FlutterI18n.translate(
                  context,
                  'ruisi.home.tab_new_reply',
                ),
              ),
              Tab(text: FlutterI18n.translate(context, 'ruisi.home.tab_water')),
              Tab(
                text: FlutterI18n.translate(
                  context,
                  'ruisi.home.tab_photography',
                ),
              ),
              Tab(text: FlutterI18n.translate(context, 'ruisi.home.tab_trade')),
              Tab(
                text: FlutterI18n.translate(
                  context,
                  'ruisi.home.tab_employment',
                ),
              ),
              Tab(
                text: FlutterI18n.translate(
                  context,
                  'ruisi.home.tab_lost_found',
                ),
              ),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabCtrl,
          children: [
            _buildTopicList(
              context,
              topics: c.newTopics.value,
              isLoading: c.newLoading.value,
              onRefresh: () => c.loadNewTopics(refresh: true),
              onLoadMore: c.hasMoreNew ? () => c.loadNewTopics() : null,
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
              topics: c.waterTopics.value,
              isLoading: c.waterLoading.value,
              onRefresh: () => c.loadWater(refresh: true),
              onLoadMore: c.hasMoreWater ? () => c.loadWater() : null,
            ),
            _buildTopicList(
              context,
              topics: c.photographyTopics.value,
              isLoading: c.photographyLoading.value,
              onRefresh: () => c.loadPhotography(refresh: true),
              onLoadMore: c.hasMorePhoto ? () => c.loadPhotography() : null,
            ),
            _buildTopicList(
              context,
              topics: c.tradeTopics.value,
              isLoading: c.tradeLoading.value,
              onRefresh: () => c.loadTrade(refresh: true),
              onLoadMore: c.hasMoreTrade ? () => c.loadTrade() : null,
            ),
            _buildTopicList(
              context,
              topics: c.employmentTopics.value,
              isLoading: c.employmentLoading.value,
              onRefresh: () => c.loadEmployment(refresh: true),
              onLoadMore: c.hasMoreEmployment ? () => c.loadEmployment() : null,
            ),
            _buildTopicList(
              context,
              topics: c.lostFoundTopics.value,
              isLoading: c.lostFoundLoading.value,
              onRefresh: () => c.loadLostFound(refresh: true),
              onLoadMore: c.hasMoreLost ? () => c.loadLostFound() : null,
            ),
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
                context.pushRuisiBranch(TopicDetailPage(tid: topic.tid)),
          );
        },
      ),
    );
  }

  Widget _buildUserButton(BuildContext context, RuisiController c) {
    if (!c.isLoggedIn) {
      return IconButton(
        icon: const Icon(Icons.person_outline),
        tooltip: FlutterI18n.translate(context, 'ruisi.common.login'),
        onPressed: () => context.pushRuisiBranch(const LoginPage()),
      );
    }

    return IconButton(
      icon: ClipOval(
        child: Image.network(
          Urls.getAvaterUrl(c.settings.uid, size: 0),
          width: 28,
          height: 28,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => const Icon(Icons.person, size: 24),
        ),
      ),
      tooltip: FlutterI18n.translate(context, 'ruisi.home.my_profile'),
      onPressed: () => context.pushRuisiBranch(const UserPage()),
    );
  }
}
