// Copyright 2026 BenderBlog Rodriguez and Contributors.
// SPDX-License-Identifier: BSD-3-Clause

import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:watermeter/page/public_widget/context_extension.dart';

import '../controller/ruisi_controller.dart';
import '../widgets/topic_list_item.dart';
import 'topic_detail_page.dart';
import 'favorites_page.dart';
import 'settings_page.dart';
import 'about_page.dart';
import 'login_page.dart';

/// 用户页面（我的帖子、我的资料）
class UserPage extends StatefulWidget {
  final int initialTab;

  const UserPage({super.key, this.initialTab = 0});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTab,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final c = RuisiController.i;
      if (!c.isLoggedIn) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
        );
        return;
      }
      c.loadMyTopics(refresh: true);
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
          title: Text(FlutterI18n.translate(context, 'ruisi.user.title')),
          bottom: TabBar(
            controller: _tabCtrl,
            tabs: [
              Tab(text: FlutterI18n.translate(context, 'ruisi.home.my_posts')),
              Tab(
                text: FlutterI18n.translate(context, 'ruisi.user.tab_profile'),
              ),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabCtrl,
          children: [
            // 我的帖子
            c.myTopicsLoading.value && c.myTopics.value.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : c.myTopics.value.isEmpty
                ? Center(
                    child: Text(
                      FlutterI18n.translate(context, 'ruisi.common.no_topics'),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: () async => c.loadMyTopics(refresh: true),
                    child: ListView.separated(
                      itemCount: c.myTopics.value.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (_, i) {
                        final topic = c.myTopics.value[i];
                        return TopicListItem(
                          topic: topic,
                          onTap: () =>
                              context.push(TopicDetailPage(tid: topic.tid)),
                        );
                      },
                    ),
                  ),

            // 资料 + 功能入口
            ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Icon(Icons.person, size: 64),
                        const SizedBox(height: 12),
                        Text(
                          c.username ??
                              FlutterI18n.translate(
                                context,
                                'ruisi.user.unknown',
                              ),
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'uid: ${c.settings.uid ?? ""}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                ListTile(
                  leading: const Icon(Icons.bookmark),
                  title: Text(
                    FlutterI18n.translate(context, 'ruisi.home.my_favorites'),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push(const FavoritesPage()),
                ),
                ListTile(
                  leading: const Icon(Icons.check_circle_outline),
                  title: Text(
                    FlutterI18n.translate(context, 'ruisi.home.daily_checkin'),
                  ),
                  trailing: c.signLoading.value
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.chevron_right),
                  onTap: c.signLoading.value
                      ? null
                      : () async {
                          await c.sign();
                          if (!context.mounted) return;
                          final msg = c.signResult.value?.message ?? '签到完成';
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(msg)),
                          );
                        },
                ),
                ListTile(
                  leading: const Icon(Icons.settings),
                  title: Text(
                    FlutterI18n.translate(context, 'ruisi.home.settings'),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () =>
                      context.push(SettingsPage(talker: c.talker)),
                ),
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: Text(
                    FlutterI18n.translate(context, 'ruisi.home.about'),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push(const AboutPage()),
                ),
                const Divider(),
                ListTile(
                  leading: Icon(
                    Icons.logout,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  title: Text(
                    FlutterI18n.translate(context, 'ruisi.common.logout'),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  onTap: () async {
                    await c.logout();
                    if (!context.mounted) return;
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          FlutterI18n.translate(
                            context,
                            'ruisi.common.logged_out',
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}
