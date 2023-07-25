/*
Exam Infomation Interface.
Copyright 2023 SuperBart

This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.

*/

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:watermeter/model/xidian_ids/exam.dart';
import 'package:watermeter/controller/exam_controller.dart';
import 'package:watermeter/page/exam/exam_info_card.dart';
import 'package:watermeter/page/exam/exam_title.dart';
import 'package:watermeter/page/exam/timeline_widget.dart';
import 'package:watermeter/page/widget.dart';

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
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => NoArrangedInfo(list: c.toBeArranged))),
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(48.0),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6.0),
              child: Container(
                height: 36.0,
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("当前展示的学期："),
                    DropdownButton(
                      focusColor: Theme.of(context).appBarTheme.backgroundColor,
                      borderRadius: const BorderRadius.all(Radius.circular(30)),
                      value: c.dropdownValue,
                      style: const TextStyle(color: Colors.black),
                      underline: Container(color: Colors.transparent),
                      onChanged: (int? value) {
                        setState(() {
                          c.dropdownValue = value!;
                        });
                        c.get(semesterStr: c.semesters[c.dropdownValue]);
                      },
                      items: List.generate(
                        c.semesters.length,
                        (index) => DropdownMenuItem(
                          value: index,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Text(c.semesters[index]),
                          ),
                        ),
                      ),
                    ),
                  ],
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

class NoArrangedInfo extends StatelessWidget {
  final List<ToBeArranged> list;
  const NoArrangedInfo({super.key, required this.list});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("目前无安排考试的科目"),
      ),
      body: dataList<Card, Card>(
        List.generate(
          list.length,
          (index) => Card(
            child: ListTile(
              title: Text(list[index].subject),
              subtitle: Text(
                "编号: ${list[index].id}\n"
                "老师: ${list[index].teacher ?? "没有数据"}",
              ),
            ),
          ),
        ),
        (toUse) => toUse,
      ),
    );
  }
}
