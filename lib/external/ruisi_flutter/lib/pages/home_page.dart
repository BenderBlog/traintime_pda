// Copyright 2026 BenderBlog Rodriguez and Contributors.
// SPDX-License-Identifier: BSD-3-Clause

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:watermeter/external/ruisi_flutter/lib/constants/forum_id.dart';
import 'package:watermeter/external/ruisi_flutter/lib/pages/search_page.dart';
import 'package:watermeter/generated/translations.g.dart';

import '../controller/ruisi_controller.dart';
import '../utils/branch_navigation.dart';
import '../constants/urls.dart';
import 'forum_list_page.dart';
import 'topic_list_page.dart';
import 'user_page.dart';
import 'new_post_page.dart';

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
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = GetIt.instance<RuisiService>();

    return Scaffold(
      appBar: AppBar(
        title: Text(context.t.ruisi.home.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: context.t.ruisi.home.search,
            onPressed: () => context.pushRuisiBranch(const SearchPage()),
          ),
          IconButton(
            icon: const Icon(Icons.edit_note),
            tooltip: context.t.ruisi.home.newPost,
            onPressed: () => context.pushRuisiBranch(const NewPostPage()),
          ),
          IconButton(
            icon: const Icon(Icons.forum),
            tooltip: context.t.ruisi.home.forumList,
            onPressed: () => context.pushRuisiBranch(const ForumListPage()),
          ),
          IconButton(
            icon: ClipOval(
              child: Image.network(
                Urls.getAvaterUrl(c.settings.uid, size: 0),
                width: 28,
                height: 28,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const Icon(Icons.person, size: 24),
              ),
            ),
            tooltip: context.t.ruisi.home.myProfile,
            onPressed: () => context.pushRuisiBranch(const UserPage()),
          ),
        ],
        bottom: TabBar(
          isScrollable: true,
          controller: _tabCtrl,
          tabs: [
            Tab(
              text: context.t.ruisi.home.tabNewPost,
            ),
            Tab(
              text: context.t.ruisi.home.tabNewReply,
            ),
            Tab(text: context.t.ruisi.home.tabWater),
            Tab(
              text: context.t.ruisi.home.tabPhotography,
            ),
            Tab(text: context.t.ruisi.home.tabTrade),
            Tab(
              text: context.t.ruisi.home.tabEmployment,
            ),
            Tab(
              text: context.t.ruisi.home.tabLostFound,
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: [
          // 首页帖子列表使用预览语义，避免分屏误触后直接丢失原详情链。
          TopicListPage(
            getTopicList: (int page) => c.api.getNewTopics(page: page),
            useHomeTopicPreviewNavigation: true,
          ),
          TopicListPage(
            getTopicList: (int page) => c.api.getNewReplyTopics(page: page),
            useHomeTopicPreviewNavigation: true,
          ),
          TopicListPage(
            getTopicList: (int page) =>
                c.api.getTopicList(ForumId.randomChat, page: page),
            useHomeTopicPreviewNavigation: true,
          ),
          TopicListPage(
            getTopicList: (int page) =>
                c.api.getTopicList(ForumId.photograph, page: page),
            useHomeTopicPreviewNavigation: true,
          ),
          TopicListPage(
            getTopicList: (int page) =>
                c.api.getTopicList(ForumId.secondHand, page: page),
            useHomeTopicPreviewNavigation: true,
          ),
          TopicListPage(
            getTopicList: (int page) =>
                c.api.getTopicList(ForumId.employment, page: page),
            useHomeTopicPreviewNavigation: true,
          ),
          TopicListPage(
            getTopicList: (int page) =>
                c.api.getTopicList(ForumId.lostAndFound, page: page),
            useHomeTopicPreviewNavigation: true,
          ),
        ],
      ),
    );
  }
}
