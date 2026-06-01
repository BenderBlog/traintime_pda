// Copyright 2026 BenderBlog Rodriguez and Contributors.
// SPDX-License-Identifier: BSD-3-Clause

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../controller/ruisi_controller.dart';
import 'topic_list_page.dart';

/// 板块帖子列表页
class ForumTopicsPage extends StatelessWidget {
  final int fid;
  final String name;

  const ForumTopicsPage({super.key, required this.fid, required this.name});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(name)),
      body: TopicListPage(
        getTopicList: (int page) =>
            GetIt.instance<RuisiService>().api.getTopicList(fid, page: page),
      ),
    );
  }
}
