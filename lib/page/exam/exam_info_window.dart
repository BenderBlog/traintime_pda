// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

// Exam Infomation Interface.

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:watermeter/controller/exam_controller.dart';
import 'package:watermeter/page/column_choose_dialog.dart';
import 'package:watermeter/page/exam/exam_info_card.dart';
import 'package:watermeter/page/exam/exam_title.dart';
import 'package:watermeter/page/exam/not_arranged_info.dart';
import 'package:watermeter/page/exam/timeline_widget.dart';

class ExamInfoWindow extends StatefulWidget {
  const ExamInfoWindow({super.key});

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
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.more_time),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => NoArrangedInfo(list: c.toBeArranged),
                ),
              ),
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(48.0),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: TextButton(
                style: TextButton.styleFrom(
                  backgroundColor:
                      Theme.of(context).colorScheme.secondaryContainer,
                ),
                onPressed: () async {
                  await showDialog(
                    context: context,
                    builder: (context) => ColumnChooseDialog(
                      semesterList: c.semesters,
                    ),
                  ).then((value) {
                    setState(() {
                      c.dropdownValue = value!;
                    });
                    c.get(semesterStr: c.semesters[c.dropdownValue]);
                  });
                },
                child: Text(
                  "当前展示的学期 ${c.semesters[c.dropdownValue]}",
                ),
              ),
            ),
          ),
        ),
        body: c.isGet == true
            ? c.subjects.isNotEmpty
                ? TimelineWidget(
                    isTitle: const [true, false, true, false],
                    children: [
                      const ExamTitle(title: "未完成考试"),
                      c.isNotFinished.isNotEmpty
                          ? Column(
                              children: List.generate(
                                c.isNotFinished.length,
                                (index) => ExamInfoCard(
                                  toUse: c.isNotFinished[index],
                                ),
                              ),
                            )
                          : const ExamInfoCard(title: "所有考试全部完成"),
                      const ExamTitle(title: "已完成考试"),
                      c.isFinished.isNotEmpty
                          ? Column(
                              children: List.generate(
                                c.isFinished.length,
                                (index) => ExamInfoCard(
                                  toUse: c.isFinished[index],
                                ),
                              ),
                            )
                          : const ExamInfoCard(title: "一门还没考呢"),
                    ],
                  )
                : const Center(child: Text("没有考试安排"))
            : c.error != null
                ? Center(child: Text(c.error.toString()))
                : const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
