/*
Exam Infomation Interface.
Copyright 2022 SuperBart

This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.

Please refer to ADDITIONAL TERMS APPLIED TO WATERMETER SOURCE CODE
if you want to use.
*/

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:watermeter/model/xidian_ids/exam.dart';
import 'package:watermeter/controller/exam_controller.dart';
import 'package:watermeter/page/widget.dart';

class ExamInfoWindow extends StatefulWidget {
  const ExamInfoWindow({super.key});

  @override
  State<ExamInfoWindow> createState() => _ExamInfoWindowState();
}

class _ExamInfoWindowState extends State<ExamInfoWindow> {
  int dropdownValue = 0;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ExamController>(
      builder: (c) => Scaffold(
        appBar: AppBar(
          title: const Text("考试安排"),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.info),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => aboutDialog(context),
                );
              },
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(48.0),
            child: Container(
              height: 48.0,
              alignment: Alignment.center,
              child: DropdownButton<int>(
                value: dropdownValue,
                icon: const Icon(Icons.arrow_downward),
                elevation: 16,
                style: const TextStyle(color: Colors.deepPurple),
                underline: Container(
                  height: 2,
                  color: Colors.deepPurpleAccent,
                ),
                onChanged: (int? value) {
                  setState(() {
                    dropdownValue = value!;
                  });
                  c.get(semesterStr: c.semesters[dropdownValue]);
                },
                items: List.generate(
                  c.semesters.length,
                  (index) => DropdownMenuItem(
                    value: index,
                    child: Text(c.semesters[index]),
                  ),
                ),
              ),
            ),
          ),
        ),
        body: c.isGet == true
            ? c.subjects.isNotEmpty
                ? dataList<InfoCard, InfoCard>(
                    List.generate(
                      c.subjects.length,
                      (index) => InfoCard(toUse: c.subjects[index]),
                    ),
                    (toUse) => toUse,
                  )
                : const Center(child: Text("没有考试安排，考古愉快(确信)"))
            : c.error != null
                ? Center(child: Text(c.error.toString()))
                : const Center(child: Text("正在加载")),
      ),
    );
  }

  Widget aboutDialog(context) => AlertDialog(
        title: const Text("考试还不是所有......"),
        content: Image.asset("assets/Boochi-Afraid-Work.jpg"),
        actions: <Widget>[
          TextButton(
            child: const Text("确定"),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
}

class InfoCard extends StatelessWidget {
  final Subject toUse;

  const InfoCard({super.key, required this.toUse});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 10,
      ),
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceVariant,
      child: Container(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  toUse.subject.length > 12
                      ? "${toUse.subject.substring(0, 11)}..."
                      : toUse.subject,
                ),
                Text(toUse.type),
              ],
            ),
            Row(
              children: [
                Icon(
                  Icons.access_time_filled_rounded,
                  size: 14,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 2),
                Text(toUse.time),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.person,
                      size: 14,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 2),
                    Text(toUse.teacher != null
                        ? toUse.teacher!.length > 10
                            ? "${toUse.teacher!.substring(0, 10)}..."
                            : toUse.teacher!
                        : "未知老师"),
                  ],
                ),
                Row(
                  children: [
                    Icon(
                      Icons.room,
                      size: 14,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 2),
                    Text(toUse.place),
                  ],
                ),
                Row(
                  children: [
                    Icon(
                      Icons.chair,
                      size: 14,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 2),
                    Text(toUse.seat.toString()),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
