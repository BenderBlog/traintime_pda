// Copyright 2024 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0
import 'dart:convert';
import 'dart:developer' as developer;

import 'package:get/get.dart';
import 'package:home_widget/home_widget.dart';
import 'package:jiffy/jiffy.dart';
import 'package:watermeter/applet/widget_worker.dart';
import 'package:watermeter/model/home_arrangement.dart';

import 'package:watermeter/controller/classtable_controller.dart';
import 'package:watermeter/controller/exam_controller.dart';
import 'package:watermeter/model/xidian_ids/classtable.dart'
    as classtable_module;

Future<bool> updateClasstableInfo() async {
  /// TODO: Add exception dealt...
  Set<HomeArrangement> toSend = {};
  developer.log(
    "Ready to update to homepage...",
    name: "WidgetWorker updateClasstableInfo",
  );
  var classTableController = Get.put(ClassTableController());
  var nextClass = classTableController.nextClassArrangements;
  var current = classTableController.currentData;
  DateTime time = DateTime.now().add(Duration(days: nextClass.$2 ? 1 : 0));

  developer.log(
    "Updating exam info.",
    name: "WidgetWorker updateClasstableInfo",
  );
  var examController = Get.put(ExamController());
  if (examController.status == ExamStatus.cache ||
      examController.status == ExamStatus.fetched) {
    developer.log(
      "Exam can be updated.",
      name: "WidgetWorker updateClasstableInfo",
    );
    var examList = examController.data.subject;
    for (var i in examList) {
      if (i.startTime.year == time.year &&
          i.startTime.month == time.month &&
          i.startTime.date == time.day) {
        toSend.add(HomeArrangement(
          name: i.subject,
          teacher: "Exam",
          place: "${i.place} ${i.seat}",
          startTime: i.startTime.Hm,
          endTime: i.stopTime.Hm,
        ));
      }
    }
  }

  developer.log(
    "Updating current class info.",
    name: "WidgetWorker updateClasstableInfo",
  );
  if (current != null) {
    toSend.add(HomeArrangement(
      name: current.$1.name,
      teacher: current.$2.teacher ?? "未知老师",
      place: current.$2.classroom ?? "未知教室",
      startTime: classtable_module.time[(current.$2.start - 1) * 2],
      endTime: classtable_module.time[(current.$2.stop - 1) * 2],
    ));
  }

  developer.log(
    "Updating next class info.",
    name: "WidgetWorker updateClasstableInfo",
  );
  for (var i in nextClass.$1) {
    var toUse = classTableController.classTableData.timeArrangement[i];
    toSend.add(HomeArrangement(
      name: classTableController.classTableData.getClassDetail(i).name,
      teacher: toUse.teacher ?? "未知老师",
      place: toUse.classroom ?? "未知教室",
      startTime: classtable_module.time[(toUse.start - 1) * 2],
      endTime: classtable_module.time[(toUse.stop - 1) * 2],
    ));
  }

  await saveToWidget(
    'class_table_date',
    Jiffy.parseFromDateTime(time).format(pattern: 'yyyy-MM-dd'),
  );

  List<HomeArrangement> toSendList = toSend.toList();
  toSendList.sort(
    (a, b) => a.startTimeByMinutesOfDay - b.startTimeByMinutesOfDay,
  );
  await saveToWidget(
    'class_table_json',
    jsonEncode(toSendList),
  );

  var toReturn = await HomeWidget.updateWidget(
    name: 'ClassTableWidgetProvider',
    iOSName: 'ClasstableWidget',
  ).then((value) {
    developer.log(
      "UpdateStatus: $value",
      name: "WidgetWorker updateClasstableInfo",
    );
    return value;
  });
  return toReturn ?? true;
}
