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
import 'package:watermeter/controller/exam_controller.dart';

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
            ? Text("${c.subjects.toString()}\n${c.toBeArranged.toString()}")
            : c.error != null
                ? Text(c.error.toString())
                : const Text("正在加载"),
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
