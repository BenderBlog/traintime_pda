// Copyright 2025 BenderBlog Rodriguez and contributors.
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:watermeter/model/xidian_ids/class_attendance.dart';
import 'package:watermeter/page/public_widget/empty_list_view.dart';
import 'package:watermeter/page/public_widget/public_widget.dart';
import 'package:watermeter/page/public_widget/re_x_card.dart';
import 'package:watermeter/repository/xidian_ids/learning_session.dart';
import 'package:watermeter/generated/translations.g.dart';

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

String attendanceSignName(BuildContext context, SignInType type, {String? customName}) {
  if (customName != null) return customName;
  return switch (type) {
    SignInType.qrCode => context.t.classAttendance.signType.qrCode,
    SignInType.gesture => context.t.classAttendance.signType.gesture,
    SignInType.position => context.t.classAttendance.signType.position,
    SignInType.unknown => context.t.classAttendance.signType.kDefault,
    SignInType.customName => context.t.classAttendance.signType.kDefault,
  };
}

String attendanceSignStatus(BuildContext context, SignStatus type) {
  return switch (type) {
    SignStatus.absenceNotParticipating =>
      context.t.classAttendance.signStatus.absenceNotParticipating,
    SignStatus.signed => context.t.classAttendance.signStatus.signed,
    SignStatus.signedByTeacher =>
      context.t.classAttendance.signStatus.signedByTeacher,
    SignStatus.personalLeave2 =>
      context.t.classAttendance.signStatus.personalLeave2,
    SignStatus.absence => context.t.classAttendance.signStatus.absence,
    SignStatus.sickLeave => 
    context.t.classAttendance.signStatus.sickLeave  ,
    SignStatus.personalLeave =>
    context.t.classAttendance.signStatus.personalLeave,
    SignStatus.later => context.t.classAttendance.signStatus.late,
    SignStatus.leaveEarly => 
    context.t.classAttendance.signStatus.leaveEarly,
    SignStatus.signExpiredy =>
      context.t.classAttendance.signStatus.signExpiredy,
    SignStatus.publicLeave =>
      context.t.classAttendance.signStatus.publicLeave,
  };
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
                      const CircularProgressIndicator(),
                      const Text("More to come"),
                    ],
                  );
                },
                noItemsFoundIndicatorBuilder: (context) => EmptyListView(
                  text: context.t.classAttendance.noAttendanceRecord,
                  type: EmptyListViewType.rolling,
                ),
                noMoreItemsIndicatorBuilder: (context) =>
                    [
                          const Icon(Icons.sentiment_very_satisfied, size: 32),
                          const SizedBox(width: 8),
                          Text(
                            "That's all folks!",
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ]
                        .toRow(mainAxisAlignment: MainAxisAlignment.center)
                        .center()
                        .padding(vertical: 12),

                itemBuilder: (context, item, index) => ReXCard(
                  title: Text(
                    attendanceSignName(
                      context,
                      item.signType,
                      customName: item.name,
                    ),
                  ),
                  remaining: [
                    ReXCardRemaining(
                      attendanceSignStatus(context, item.signStatusType),
                    ),
                  ],
                  bottomRow: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow(
                        context.t.classAttendance.detailCard.creatorName,
                        item.creatorName,
                      ),
                      _buildInfoRow(
                        context.t.classAttendance.detailCard.startTime,
                        item.starttime,
                      ),
                      if (item.submittime != null)
                        _buildInfoRow(
                          context.t.classAttendance.detailCard.summitTime,
                          item.submittime!,
                        ),
                    ],
                  ),
                ),
              ),
              separatorBuilder: (BuildContext context, int index) {
                return const SizedBox(height: 4);
              },
              padding: const EdgeInsets.symmetric(vertical: 9.0),
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
          context.t.classAttendance.detailTitle(course_name: widget.classAttendance.courseName),
        ),
      ),
      body: body,
    );
  }
}
