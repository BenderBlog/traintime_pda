// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

// Exam Infomation Interface.

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:watermeter/controller/exam_controller.dart';
import 'package:watermeter/page/exam/exam_info_card.dart';
import 'package:watermeter/page/public_widget/timeline_widget/timeline_title.dart';
import 'package:watermeter/page/exam/not_arranged_info.dart';
import 'package:watermeter/page/public_widget/timeline_widget/timeline_widget.dart';

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
    return GetBuilder<ExamController>(
      builder: (c) => Scaffold(
        appBar: AppBar(
          title: const Text("考试安排"),
          actions: [
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
                isTitle: const [true, false, true, false],
                children: [
                  const TimelineTitle(title: "未完成考试"),
                  Builder(builder: (context) {
                    final isNotFinished = c.isNotFinished(widget.time);
                    if (isNotFinished.isNotEmpty) {
                      return isNotFinished
                          .map((e) => ExamInfoCard(toUse: e))
                          .toList()
                          .toColumn();
                    } else {
                      return const ExamInfoCard(title: "所有考试全部完成");
                    }
                  }),
                  const TimelineTitle(title: "已完成考试"),
                  Builder(builder: (context) {
                    final isFinished = c.isFinished(widget.time);
                    if (isFinished.isNotEmpty) {
                      return isFinished
                          .map((e) => ExamInfoCard(toUse: e))
                          .toList()
                          .toColumn();
                    } else {
                      return const ExamInfoCard(title: "一门还没考呢");
                    }
                  }),
                ],
              ).safeArea();
            } else {
              return const Center(child: Text("没有考试安排"));
            }
          } else if (c.status == ExamStatus.error) {
            return Center(child: Text(c.error.toString()));
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        }),
      ),
    );
  }
}
