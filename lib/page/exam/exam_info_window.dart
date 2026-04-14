// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

// Exam Infomation Interface.

import 'package:flutter_i18n/flutter_i18n.dart';
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

class ExamInfoWindow extends StatefulWidget {
  const ExamInfoWindow({super.key});

  @override
  State<ExamInfoWindow> createState() => _ExamInfoWindowState();
}

class _ExamInfoWindowState extends State<ExamInfoWindow> {
  @override
  Widget build(BuildContext context) {
    final c = ExamController.i;

    return Watch((cache) {
      final state = c.examInfoSignal.value;
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
          title: Text(FlutterI18n.translate(context, "exam.title")),
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
                    TimelineTitle(
                      title: FlutterI18n.translate(
                        context,
                        "exam.not_finished",
                      ),
                    ),
                    if (isNotFinished.isNotEmpty)
                      ...isNotFinished.map((e) => ExamInfoCard(toUse: e))
                    else
                      [
                        ExamInfoCard(
                          title: FlutterI18n.translate(
                            context,
                            "exam.all_finished",
                          ),
                        ),
                      ].toColumn(),
                    if (isDisQualified.isNotEmpty)
                      TimelineTitle(
                        title: FlutterI18n.translate(
                          context,
                          "exam.unable_to_exam",
                        ),
                      ),
                    if (isDisQualified.isNotEmpty)
                      isDisQualified
                          .map((e) => ExamInfoCard(toUse: e))
                          .toList()
                          .toColumn(),
                    TimelineTitle(
                      title: FlutterI18n.translate(context, "exam.finished"),
                    ),
                    if (isFinished.isNotEmpty)
                      ...isFinished.map((e) => ExamInfoCard(toUse: e))
                    else
                      [
                        ExamInfoCard(
                          title: FlutterI18n.translate(
                            context,
                            "exam.none_finished",
                          ),
                        ),
                      ].toColumn(),
                  ],
                );
              } else {
                content = EmptyListView(
                  type: EmptyListViewType.defaultimg,
                  text: FlutterI18n.translate(
                    context,
                    "exam.no_exam_arrangement",
                  ),
                );
              }

              final body = Column(
                children: [
                  if (isFromCache && fetchTime != null)
                    CacheAlerter(
                      dataType: FlutterI18n.translate(context, "exam.title"),
                      hint: FlutterI18n.translate(
                        context,
                        cacheHintKey == null ||
                                cacheHintKey == "local_cache_hint"
                            ? "cache_reason_default"
                            : cacheHintKey,
                      ),
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
                    hint: FlutterI18n.translate(context, "exam.fetching_hint"),
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
    });
  }
}
