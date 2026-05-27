// Copyright 2026 BenderBlog Rodriguez and Contributors.
// SPDX-License-Identifier: BSD-3-Clause

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:signals/signals_flutter.dart';
import 'package:watermeter/page/public_widget/context_extension.dart';

import '../controller/ruisi_controller.dart';
import '../widgets/topic_list_item.dart';
import 'topic_detail_page.dart';
import 'login_page.dart';

/// 论坛网络收藏
class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final c = RuisiController.i;
      if (!c.isLoggedIn) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
        );
        return;
      }
      c.loadFavorites(refresh: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Watch((context) {
      final c = RuisiController.i;

      return Scaffold(
        appBar: AppBar(
          title: Text(FlutterI18n.translate(context, 'ruisi.favorites.title')),
        ),
        body: c.favoritesLoading.value && c.favorites.value.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : c.favorites.value.isEmpty
            ? Center(
                child: Text(
                  FlutterI18n.translate(context, 'ruisi.favorites.empty'),
                ),
              )
            : RefreshIndicator(
                onRefresh: () async => c.loadFavorites(refresh: true),
                child: ListView.separated(
                  itemCount: c.favorites.value.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (_, i) {
                    final topic = c.favorites.value[i];
                    return TopicListItem(
                      topic: topic,
                      onTap: () =>
                          context.push(TopicDetailPage(tid: topic.tid)),
                    );
                  },
                ),
              ),
      );
    });
  }
}
