// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

// Exam Infomation Interface.

import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:watermeter/controller/exam_controller.dart';
import 'package:watermeter/page/exam/exam_info_card.dart';
import 'package:watermeter/page/public_widget/empty_list_view.dart';
import 'package:watermeter/page/public_widget/cache_alerter.dart';
import 'package:watermeter/page/public_widget/loading_alerter.dart';
import 'package:watermeter/page/public_widget/public_widget.dart';
import 'package:watermeter/page/public_widget/timeline_widget/timeline_title.dart';
import 'package:watermeter/page/exam/not_arranged_info.dart';
import 'package:watermeter/page/public_widget/timeline_widget/timeline_widget.dart';
import 'package:watermeter/generated/l10n.dart';
import 'package:watermeter/repository/xidian_ids/exam_session.dart';

class ExamInfoWindow extends StatefulWidget {
  const ExamInfoWindow({super.key});

  @override
  State<ExamInfoWindow> createState() => _ExamInfoWindowState();
}

class _ExamInfoWindowState extends State<ExamInfoWindow> {
  @override
  Widget build(BuildContext context) {
    final c = ExamController.i;

    return SignalBuilder(
      builder: (cache) {
        final state = c.examInfoStateSignal.value;
        final hasValidExamInfo = c.hasValidExamInfo.value;
        final isFromCache = c.isExamFromCache.value;
        final fetchTime = c.examFetchTime.value;
        final cacheHintKey = c.examCacheHintKey.value;
        final subjects = c.subjects.value;
        final isDisQualified = c.isDisQualified.value;
        final isFinished = c.isFinished.value;
        final isNotFinished = c.isNotFinished.value;
        final toBeArranged = c.toBeArranged.value;

        return Scaffold(
          appBar: AppBar(
            title: Text(I18n.of(context)!.examTitle),
            actions: [
              if (hasValidExamInfo)
                IconButton(
                  icon: const Icon(Icons.update),
                  onPressed: () => c.reloadExamInfo(),
                ),
              if (hasValidExamInfo)
                IconButton(
                  icon: const Icon(Icons.more_time),
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => NoArrangedInfo(list: toBeArranged),
                    ),
                  ),
                ),
            ],
          ),
          body: Builder(
            builder: (context) {
              if (hasValidExamInfo) {
                Widget content;
                if (subjects.isNotEmpty) {
                  content = TimelineWidget(
                    isTitle: [
                      true,
                      false,
                      true,
                      false,
                      if (isDisQualified.isNotEmpty) ...[true, false],
                    ],
                    children: [
                      if (isDisQualified.isNotEmpty) ...[
                        TimelineTitle(
                          title: I18n.of(context)!.examUnableToExam,
                        ),
                        isDisQualified
                            .map((e) => ExamInfoCard(toUse: e))
                            .toList()
                            .toColumn(),
                      ],
                      TimelineTitle(
                        title: I18n.of(context)!.examNotFinished,
                      ),
                      [
                        if (isNotFinished.isNotEmpty)
                          ...isNotFinished.map((e) => ExamInfoCard(toUse: e))
                        else
                          ExamInfoCard(
                            title: I18n.of(context)!.examAllFinished,
                          ),
                      ].toColumn(),
                      TimelineTitle(
                        title: I18n.of(context)!.examFinished,
                      ),
                      [
                        if (isFinished.isNotEmpty)
                          ...isFinished.map((e) => ExamInfoCard(toUse: e))
                        else
                          ExamInfoCard(
                            title: I18n.of(context)!.examNoneFinished,
                          ),
                      ].toColumn(),
                    ],
                  );
                } else {
                  content = EmptyListView(
                    type: EmptyListViewType.defaultimg,
                    text: I18n.of(context)!.examNoExamArrangement,
                  );
                }

                final body = Column(
                  children: [
                    if (isFromCache && fetchTime != null)
                      CacheAlerter(
                        dataType: I18n.of(context)!.examTitle,
                        hint: _examCacheHint(context, cacheHintKey),
                        placeOfCache: PlaceOfCache.device,
                        fetchTime: fetchTime,
                      ),
                    Expanded(child: content),
                  ],
                );

                if (!state.isLoading) return body;

                return Stack(
                  children: [
                    Column(
                      children: [
                        AnimatedContainer(
                          height: kTextTabBarHeight,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        ),
                        Expanded(child: body),
                      ],
                    ),
                    LoadingAlerter(
                      isLoading: true,
                      hint: I18n.of(context)!.examFetchingHint,
                      opacity: 0.15,
                      showOverlay: true,
                    ),
                  ],
                );
              } else if (state is AsyncError) {
                return ReloadWidget(
                  function: () => c.reloadExamInfo(),
                  errorStatus: state.error,
                  stackTrace: state.stackTrace,
                ).center();
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
        );
      },
    );
  }
}

String _examCacheHint(BuildContext context, Object? hint) {
  if (hint == null) {
    return I18n.of(context)!.cacheReasonDefault;
  }
  return switch (hint) {
    ExamCacheHint.passwordWrong =>
      I18n.of(context)!.examCacheHintPasswordWrong,
    ExamCacheHint.loginFailed =>
      I18n.of(context)!.examCacheHintLoginFailed,
    ExamCacheHint.networkFailed =>
      I18n.of(context)!.examCacheHintNetworkFailed,
    ExamCacheHint.unknownError =>
      I18n.of(context)!.examCacheHintUnknownError,
    _ => I18n.of(context)!.cacheReasonDefault,
  };
}