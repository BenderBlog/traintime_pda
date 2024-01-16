// Copyright 2024 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0
import 'dart:convert';

import 'package:watermeter/repository/logger.dart';
import 'package:get/get.dart';
import 'package:home_widget/home_widget.dart';
import 'package:jiffy/jiffy.dart';
import 'package:watermeter/applet/widget_worker.dart';
import 'package:watermeter/model/home_arrangement.dart';

import 'package:watermeter/controller/classtable_controller.dart';
import 'package:watermeter/controller/exam_controller.dart';

Future<bool> updateClasstableInfo() async {
  /// TODO: Add exception dealt...

  log.i(
    "[WidgetWorker updateClasstableInfo] "
    "Ready to update to homepage.",
  );
  var classTableController = Get.put(ClassTableController());

  log.i(
    "[WidgetWorker updateClasstableInfo] "
    "Updating class info.",
  );

  var data = classTableController.homeArrangementData;
  List<HomeArrangement> todayData = [...data.$1];
  List<HomeArrangement> tomorrowData = [...data.$2];
  DateTime time = classTableController.updateTime;

  var examController = Get.put(ExamController());
  log.i(
    "[WidgetWorker updateClasstableInfo] "
    "Updating exam info, state is ${examController.status}.",
  );
  if (examController.status == ExamStatus.cache ||
      examController.status == ExamStatus.fetched) {
    log.i(
      "[WidgetWorker updateClasstableInfo] "
      "Exam info can be updated.",
    );
    var examList = examController.isNotFinished;
    for (var i in examList) {
      if (i.startTime.year == time.year &&
          i.startTime.month == time.month &&
          i.startTime.date == time.day) {
        todayData.add(HomeArrangement(
          name: i.subject,
          teacher: "Exam",
          place: "${i.place} ${i.seat}",
          startTimeStr: Jiffy.parseFromDateTime(i.startTime.dateTime)
              .format(pattern: HomeArrangement.format),
          endTimeStr: Jiffy.parseFromDateTime(i.stopTime.dateTime)
              .format(pattern: HomeArrangement.format),
        ));
      } else if (i.startTime.year == time.year &&
          i.startTime.month == time.month &&
          i.startTime.date == time.day + 1) {
        tomorrowData.add(HomeArrangement(
          name: i.subject,
          teacher: "Exam",
          place: "${i.place} ${i.seat}",
          startTimeStr: Jiffy.parseFromDateTime(i.startTime.dateTime)
              .format(pattern: HomeArrangement.format),
          endTimeStr: Jiffy.parseFromDateTime(i.stopTime.dateTime)
              .format(pattern: HomeArrangement.format),
        ));
      }
    }
  }

  await saveToWidget('class_table_date',
      Jiffy.parseFromDateTime(time).format(pattern: HomeArrangement.format));

  todayData.sort((a, b) =>
      a.startTime.microsecondsSinceEpoch - b.startTime.microsecondsSinceEpoch);
  tomorrowData.sort((a, b) =>
      a.startTime.microsecondsSinceEpoch - b.startTime.microsecondsSinceEpoch);
  await saveToWidget('today_data', jsonEncode(todayData));
  await saveToWidget('tomorrow_data', jsonEncode(tomorrowData));

  var toReturn = await HomeWidget.updateWidget(
    name: 'ClassTableWidgetProvider',
    iOSName: 'ClasstableWidget',
  ).then((value) {
    log.i(
      "[WidgetWorker updateClasstableInfo] "
      "UpdateStatus: $value",
    );
    return value;
  });
  return toReturn ?? true;
}
