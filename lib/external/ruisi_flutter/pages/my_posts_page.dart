// Copyright 2026 Traintime PDA Authours, originally by BenderBlog Rodriguez.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:get_it/get_it.dart';
import 'package:watermeter/external/ruisi_flutter/pages/topic_list_page.dart';

import '../controller/ruisi_controller.dart';

class MyPostsPage extends StatelessWidget {
  const MyPostsPage({super.key});

  // TODO Fix

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(FlutterI18n.translate(context, 'ruisi.favorites.title')),
      ),
      body: TopicListPage(
        getTopicList: (int page) =>
            GetIt.instance<RuisiService>().api.getMyTopics(page: page),
      ),
    );
  }
}
