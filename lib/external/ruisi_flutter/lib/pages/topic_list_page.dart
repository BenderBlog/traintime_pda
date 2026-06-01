// Copyright 2026 BenderBlog Rodriguez and Contributors.
// SPDX-License-Identifier: BSD-3-Clause

import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:watermeter/page/public_widget/context_extension.dart';

import '../models/topic.dart';
import 'topic_detail_page.dart';
import '../utils/branch_navigation.dart';
import '../widgets/topic_list_item.dart';

class TopicListPage extends StatefulWidget {
  final Future<List<Topic>> Function(int) getTopicList;
  /// 首页列表使用预览语义，普通帖子列表保持常规详情链路。
  final bool useHomeTopicPreviewNavigation;

  const TopicListPage({
    super.key,
    required this.getTopicList,
    this.useHomeTopicPreviewNavigation = false,
  });

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
                // 首页误触需要保留当前详情链，其他列表继续使用普通 push。
                onTap: () => widget.useHomeTopicPreviewNavigation
                    ? context.pushRuisiHomeTopicPreview(
                        TopicDetailPage(tid: item.tid),
                      )
                    : context.push(TopicDetailPage(tid: item.tid)),
              ),
            ),
            separatorBuilder: (_, _) => const Divider(height: 1),
          ),
    );
  }
}
