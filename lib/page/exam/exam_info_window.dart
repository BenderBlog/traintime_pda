// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

// Exam Infomation Interface.

import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:watermeter/controller/exam_controller.dart';
import 'package:watermeter/page/exam/exam_info_card.dart';
import 'package:watermeter/page/homepage/refresh.dart';
import 'package:watermeter/page/public_widget/empty_list_view.dart';
import 'package:watermeter/page/public_widget/timeline_widget/timeline_title.dart';
import 'package:watermeter/page/exam/not_arranged_info.dart';
import 'package:watermeter/page/public_widget/timeline_widget/timeline_widget.dart';
import 'package:watermeter/page/public_widget/toast.dart';
import 'package:watermeter/repository/xidian_ids/ids_session.dart';

class ExamInfoWindow extends StatefulWidget {
  final DateTime time;
  const ExamInfoWindow({
    super.key,
    required this.time,
  });

  @override
  State<ExamInfoWindow> createState() => _ExamInfoWindowState();
}

class _ExamInfoWindowState extends State<ExamInfoWindow> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<ExamController>(builder: (c) {
      if (offline && c.status == ExamStatus.cache) {
        showToast(
          context: context,
          msg: FlutterI18n.translate(
            context,
            "exam.cache_hint",
          ),
        );
      }

      return Scaffold(
        appBar: AppBar(
          title: Text(FlutterI18n.translate(
            context,
            "exam.title",
          )),
          actions: [
            if (!offline &&
                (c.status == ExamStatus.cache ||
                    c.status == ExamStatus.fetched))
              IconButton(
                icon: const Icon(Icons.update),
                onPressed: () => c.get().then((value) {
                  c.update();
                  updateCurrentData();
                }),
              ),
            if ((c.status == ExamStatus.cache ||
                c.status == ExamStatus.fetched))
              IconButton(
                icon: const Icon(Icons.more_time),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => NoArrangedInfo(
                      list: c.data.toBeArranged,
                    ),
                  ),
                ),
              ),
          ],
        ),
        body: Builder(builder: (context) {
          if (c.status == ExamStatus.cache || c.status == ExamStatus.fetched) {
            if (c.data.subject.isNotEmpty) {
              return TimelineWidget(
                isTitle: [
                  true,
                  false,
                  true,
                  false,
                  if (c.isDisQualified.isNotEmpty) ...[true, false],
                ],
                children: [
                  TimelineTitle(
                    title: FlutterI18n.translate(
                      context,
                      "exam.not_finished",
                    ),
                  ),
                  Builder(builder: (context) {
                    final isNotFinished = c.isNotFinished(widget.time);
                    if (isNotFinished.isNotEmpty) {
                      return isNotFinished
                          .map((e) => ExamInfoCard(toUse: e))
                          .toList()
                          .toColumn();
                    } else {
                      return ExamInfoCard(
                        title: FlutterI18n.translate(
                          context,
                          "exam.all_finished",
                        ),
                      );
                    }
                  }),
                  if (c.isDisQualified.isNotEmpty)
                    TimelineTitle(
                      title: FlutterI18n.translate(
                        context,
                        "exam.unable_to_exam",
                      ),
                    ),
                  if (c.isDisQualified.isNotEmpty)
                    c.isDisQualified
                        .map((e) => ExamInfoCard(toUse: e))
                        .toList()
                        .toColumn(),
                  TimelineTitle(
                    title: FlutterI18n.translate(
                      context,
                      "exam.finished",
                    ),
                  ),
                  Builder(builder: (context) {
                    final isFinished = c.isFinished(widget.time);
                    if (isFinished.isNotEmpty) {
                      return isFinished
                          .map((e) => ExamInfoCard(toUse: e))
                          .toList()
                          .toColumn();
                    } else {
                      return ExamInfoCard(
                        title: FlutterI18n.translate(
                          context,
                          "exam.none_finished",
                        ),
                      );
                    }
                  }),
                ],
              ).safeArea();
            } else {
              return EmptyListView(
                type: EmptyListViewType.defaultimg,
                text: FlutterI18n.translate(
                  context,
                  "exam.no_exam_arrangement",
                ),
              );
            }
          } else if (c.status == ExamStatus.error) {
            return Center(
              child: Text(FlutterI18n.translate(
                context,
                c.error.toString(),
              )),
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        }),
      );
    });
  }
}
