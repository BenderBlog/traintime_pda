// Copyright 2026 BenderBlog Rodriguez and Contributors.
// SPDX-License-Identifier: BSD-3-Clause

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:get_it/get_it.dart';
import 'package:watermeter/external/ruisi_flutter/lib/constants/forum_id.dart';
import 'package:watermeter/external/ruisi_flutter/lib/pages/search_page.dart';

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
            tooltip: FlutterI18n.translate(context, 'ruisi.home.my_profile'),
            onPressed: () => context.pushRuisiBranch(const UserPage()),
          ),
        ],
        bottom: TabBar(
          isScrollable: true,
          controller: _tabCtrl,
          tabs: [
            Tab(
              text: FlutterI18n.translate(context, 'ruisi.home.tab_new_post'),
            ),
            Tab(
              text: FlutterI18n.translate(context, 'ruisi.home.tab_new_reply'),
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
              text: FlutterI18n.translate(context, 'ruisi.home.tab_employment'),
            ),
            Tab(
              text: FlutterI18n.translate(context, 'ruisi.home.tab_lost_found'),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: [
          TopicListPage(
            getTopicList: (int page) => c.api.getNewTopics(page: page),
          ),
          TopicListPage(
            getTopicList: (int page) => c.api.getNewReplyTopics(page: page),
          ),
          TopicListPage(
            getTopicList: (int page) =>
                c.api.getTopicList(ForumId.randomChat, page: page),
          ),
          TopicListPage(
            getTopicList: (int page) =>
                c.api.getTopicList(ForumId.photograph, page: page),
          ),
          TopicListPage(
            getTopicList: (int page) =>
                c.api.getTopicList(ForumId.secondHand, page: page),
          ),
          TopicListPage(
            getTopicList: (int page) =>
                c.api.getTopicList(ForumId.employment, page: page),
          ),
          TopicListPage(
            getTopicList: (int page) =>
                c.api.getTopicList(ForumId.lostAndFound, page: page),
          ),
        ],
      ),
    );
  }
}
