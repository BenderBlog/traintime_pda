// Copyright 2025 BenderBlog Rodriguez and contributors.
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:watermeter/model/xidian_ids/class_attendance.dart';
import 'package:watermeter/page/public_widget/empty_list_view.dart';
import 'package:watermeter/page/public_widget/public_widget.dart';
import 'package:watermeter/page/public_widget/re_x_card.dart';
import 'package:watermeter/repository/xidian_ids/learning_session.dart';

class ClassAttendanceDetailView extends StatefulWidget {
  final ClassAttendance classAttendance;
  final bool showAppBar;

  const ClassAttendanceDetailView({
    super.key,
    required this.classAttendance,
    this.showAppBar = true,
  });

  @override
  State<ClassAttendanceDetailView> createState() =>
      _ClassAttendanceDetailViewState();
}

class _ClassAttendanceDetailViewState extends State<ClassAttendanceDetailView> {
  late final _pagingController = PagingController<int, ClassAttendanceDetail>(
    getNextPageKey: (state) =>
        state.lastPageIsEmpty ? null : state.nextIntPageKey,
    fetchPage: (pageKey) => LearningSession().getAttendanceRecordDetail(
      widget.classAttendance,
      pageKey,
      10,
    ),
  );

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _pagingController.addListener(_showError);
  }

  /// This method listens to notifications from the [_pagingController] and
  /// shows a [SnackBar] when an error occurs.
  Future<void> _showError() async {
    if (_pagingController.value.status == PagingStatus.subsequentPageError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Something went wrong while fetching a new page.',
          ),
          action: SnackBarAction(
            label: 'Retry',
            onPressed: () => _pagingController.fetchNextPage(),
          ),
        ),
      );
    }
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 16),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final listView = PagedListView<int, ClassAttendanceDetail>.separated(
      state: PagingState(),
      fetchNextPage: () {},
      builderDelegate: PagedChildBuilderDelegate(
        firstPageProgressIndicatorBuilder: (context) =>
            const Center(child: CircularProgressIndicator()),
        firstPageErrorIndicatorBuilder: (context) => ReloadWidget(
          function: () async => _pagingController.refresh(),
          errorStatus: _pagingController.error,
        ),
        newPageProgressIndicatorBuilder: (context) {
          return Row(
            children: [
              CircularProgressIndicator(),
              Text("More to come"),
            ],
          );
        },
        noItemsFoundIndicatorBuilder: (context) => EmptyListView(
          text: FlutterI18n.translate(
            context,
            "class_attndance.no_attendance_record",
          ),
          type: EmptyListViewType.rolling,
        ),
        noMoreItemsIndicatorBuilder: (context) =>
            [
                  Icon(Icons.sentiment_very_satisfied, size: 32),
                  SizedBox(width: 8),
                  Text(
                    "That's all folks!",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ]
                .toRow(mainAxisAlignment: MainAxisAlignment.center)
                .center()
                .padding(vertical: 12),

        itemBuilder: (context, item, index) => ReXCard(
          title: Text(FlutterI18n.translate(context, item.signName)),
          remaining: [
            ReXCardRemaining(
              FlutterI18n.translate(context, item.signStatus),
            ),
          ],
          bottomRow: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoRow(
                FlutterI18n.translate(
                  context,
                  "class_attendance.detail_card.creator_name",
                ),
                item.creatorName,
              ),
              _buildInfoRow(
                FlutterI18n.translate(
                  context,
                  "class_attendance.detail_card.start_time",
                ),
                item.starttime,
              ),
              if (item.submittime != null)
                _buildInfoRow(
                  FlutterI18n.translate(
                    context,
                    "class_attendance.detail_card.summit_time",
                  ),
                  item.submittime!,
                ),
            ],
          ),
        ).constrained(maxWidth: sheetMaxWidth).center(),
      ),
      separatorBuilder: (BuildContext context, int index) {
        return const SizedBox(height: 4);
      },
      padding: const EdgeInsets.symmetric(
        horizontal: 12.5,
        vertical: 9.0,
      ),
    );

    final body = RefreshIndicator(
      onRefresh: () async => _pagingController.refresh(),
      child: PagingListener(
        controller: _pagingController,
        builder: (context, state, fetchNextPage) =>
            PagedListView<int, ClassAttendanceDetail>.separated(
              state: state,
              fetchNextPage: fetchNextPage,
              builderDelegate: PagedChildBuilderDelegate(
                firstPageProgressIndicatorBuilder: (context) =>
                    const Center(child: CircularProgressIndicator()),
                firstPageErrorIndicatorBuilder: (context) => ReloadWidget(
                  function: () async => _pagingController.refresh(),
                  errorStatus: _pagingController.error,
                ),
                newPageProgressIndicatorBuilder: (context) {
                  return Row(
                    children: [
                      CircularProgressIndicator(),
                      Text("More to come"),
                    ],
                  );
                },
                noItemsFoundIndicatorBuilder: (context) => EmptyListView(
                  text: FlutterI18n.translate(
                    context,
                    "class_attndance.no_attendance_record",
                  ),
                  type: EmptyListViewType.rolling,
                ),
                noMoreItemsIndicatorBuilder: (context) =>
                    [
                          Icon(Icons.sentiment_very_satisfied, size: 32),
                          SizedBox(width: 8),
                          Text(
                            "That's all folks!",
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ]
                        .toRow(mainAxisAlignment: MainAxisAlignment.center)
                        .center()
                        .padding(vertical: 12),

                itemBuilder: (context, item, index) => ReXCard(
                  title: Text(FlutterI18n.translate(context, item.signName)),
                  remaining: [
                    ReXCardRemaining(
                      FlutterI18n.translate(context, item.signStatus),
                    ),
                  ],
                  bottomRow: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow(
                        FlutterI18n.translate(
                          context,
                          "class_attendance.detail_card.creator_name",
                        ),
                        item.creatorName,
                      ),
                      _buildInfoRow(
                        FlutterI18n.translate(
                          context,
                          "class_attendance.detail_card.start_time",
                        ),
                        item.starttime,
                      ),
                      if (item.submittime != null)
                        _buildInfoRow(
                          FlutterI18n.translate(
                            context,
                            "class_attendance.detail_card.summit_time",
                          ),
                          item.submittime!,
                        ),
                    ],
                  ),
                ).constrained(maxWidth: sheetMaxWidth).center(),
              ),
              separatorBuilder: (BuildContext context, int index) {
                return const SizedBox(height: 4);
              },
              padding: const EdgeInsets.symmetric(
                horizontal: 12.5,
                vertical: 9.0,
              ),
            ),
      ),
    );

    if (!widget.showAppBar) {
      return SafeArea(
        top: true,
        bottom: false,
        left: false,
        right: false,
        child: body,
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          FlutterI18n.translate(
            context,
            "class_attendance.detail_title",
            translationParams: {
              "courseName": widget.classAttendance.courseName,
            },
          ),
        ),
      ),
      body: body,
    );
  }
}
