// Copyright 2026 Traintime PDA Authours, originally by BenderBlog Rodriguez.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../models/topic.dart';
import '../pages/topic_detail_page.dart';
import '../utils/branch_navigation.dart';
import '../widgets/topic_list_item.dart';

class TopicListPage extends StatefulWidget {
  final Future<List<Topic>> Function(int) getTopicList;

  const TopicListPage({super.key, required this.getTopicList});

  @override
  State<TopicListPage> createState() => _TopicListPageState();
}

class _TopicListPageState extends State<TopicListPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  late final PagingController<int, Topic> _pagingController =
      PagingController<int, Topic>(
        getNextPageKey: (state) =>
            state.lastPageIsEmpty ? null : state.nextIntPageKey,
        fetchPage: (pageKey) => widget.getTopicList(pageKey),
      );

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return PagingListener(
      controller: _pagingController,
      builder: (context, state, fetchNextPage) =>
          PagedListView<int, Topic>.separated(
            state: state,
            fetchNextPage: fetchNextPage,
            builderDelegate: PagedChildBuilderDelegate(
              itemBuilder: (context, item, index) => TopicListItem(
                topic: item,
                onTap: () =>
                    context.pushRuisiBranch(TopicDetailPage(tid: item.tid)),
              ),
            ),
            separatorBuilder: (_, _) => const Divider(height: 1),
          ),
    );
  }
}
