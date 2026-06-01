// Copyright 2026 BenderBlog Rodriguez and Contributors.
// SPDX-License-Identifier: BSD-3-Clause

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:get_it/get_it.dart';

import '../controller/ruisi_controller.dart';
import 'topic_list_page.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(FlutterI18n.translate(context, 'ruisi.favorites.title')),
      ),
      body: TopicListPage(
        getTopicList: (int page) =>
            GetIt.instance<RuisiService>().api.getFavorites(page: page),
      ),
    );
  }
}
