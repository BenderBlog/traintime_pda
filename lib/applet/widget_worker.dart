// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'dart:convert';
import 'dart:developer' as developer;

import 'package:background_fetch/background_fetch.dart';
import 'package:get/get.dart';
import 'package:home_widget/home_widget.dart';
import 'package:jiffy/jiffy.dart';
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
          i.startTime.date == 15) {
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

  await HomeWidget.saveWidgetData(
    'class_table_date',
    Jiffy.parseFromDateTime(time).format(pattern: 'yyyy-MM-dd'),
  ).then(
    (value) => developer.log(
      "saveData 'class_table_date' status: $value",
      name: "WidgetWorker updateClasstableInfo",
    ),
  );

  List<HomeArrangement> toSendList = toSend.toList();
  toSendList.sort(
    (a, b) => a.startTimeByMinutesOfDay - b.startTimeByMinutesOfDay,
  );
  await HomeWidget.saveWidgetData(
    'class_table_json',
    jsonEncode(toSendList),
  ).then(
    (value) => developer.log(
      "saveData 'class_table_json' status: $value\nvalue: ${jsonEncode(toSendList)}",
      name: "WidgetWorker updateClasstableInfo",
    ),
  );

  await HomeWidget.getWidgetData('class_table_json').then(
    (value) => developer.log(
      "confirm 'class_table_json' status: $value",
      name: "WidgetWorker updateClasstableInfo",
    ),
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

/// Used for Background Updates using Workmanager Plugin
@pragma("vm:entry-point")
backgroundFetchHeadlessTask(HeadlessTask task) async {
  String taskId = task.taskId;
  bool isTimeout = task.timeout;
  if (isTimeout) {
    // This task has exceeded its allowed running-time.
    // You must stop what you're doing and immediately .finish(taskId)
    developer.log(
      "Headless task timed-out: $taskId",
      name: "BackgroundFetch",
    );
    BackgroundFetch.finish(taskId);
    return;
  }
  developer.log(
    'Headless event received.',
    name: "BackgroundFetch",
  );
  // Do your work here...
  developer.log(
    "The iOS background fetch was triggered, "
    "BackgroundFetch",
  );
  await updateClasstableInfo();
  BackgroundFetch.finish(taskId);
}

/* Do not add button on the widget for the moment..
/// Called when Doing Background Work initiated from Widget
/// [data] uri passed from the native
@pragma("vm:entry-point")
void backgroundCallback(Uri? data) async {
  if (data == null) {
    return;
  }
  if (data.scheme != 'widget') {
    return;
  }
  //only for scheme 'widget'
  final widgetName = data.queryParameters['widgetName'];
  if (widgetName == null) {
    return;
  }
  switch (widgetName) {
    // case 'Electricity':
    // refresh the data of electricity
    // break;
    case 'ClassTable':
      processClassTableEvents(data);
      break;
    default:
  }
}

void processClassTableEvents(Uri data) async {
  //host name is converted to lowercase,
  //for which we must use host name in lowercase.
  switch (data.host) {
    case 'switcherclicked':
      // isToday: true if class table shows classes today,
      // false if class table shows classes tomorrow.
      bool isToday = !(await HomeWidget.getWidgetData(
          'class_table_switcher_next',
          defaultValue: true) as bool);
      //TODO replace the mock classes data with proper ones
      if (isToday) {
        await HomeWidget.saveWidgetData('class_table_date',
            DateTime(2023, 4, 4, 12, 0, 0, 0, 0).toString());
        await HomeWidget.saveWidgetData('class_table_json',
            '{"list":[{"name":"算法分析与设计","teacher":"覃桂敏","place":"B-706","start_time":1,"end_time":2},{"name":"算法分析与设计","teacher":"覃桂敏","place":"B-706","start_time":1,"end_time":2},{"name":"软件过程与项目管理","teacher":"Angaj（印）","place":"B-707","start_time":3,"end_time":4},{"name":"软件过程与项目管理","teacher":"Angaj（印）","place":"B-707","start_time":3,"end_time":4},{"name":"软件体系结构","teacher":"蔺一帅,李飞","place":"A-222","start_time":7,"end_time":8},{"name":"软件体系结构","teacher":"蔺一帅,李飞","place":"A-222","start_time":7,"end_time":8}]}');
      } else {
        await HomeWidget.saveWidgetData('class_table_date',
            DateTime(2023, 4, 5, 12, 0, 0, 0, 0).toString());
        await HomeWidget.saveWidgetData('class_table_json',
            '{"list":[{"name":"软件过程与项目管理","teacher":"Angaj（印）","place":"B-707","start_time":3,"end_time":4},{"name":"软件过程与项目管理","teacher":"Angaj（印）","place":"B-707","start_time":3,"end_time":4},{"name":"软件体系结构","teacher":"蔺一帅,李飞","place":"A-222","start_time":7,"end_time":8},{"name":"软件体系结构","teacher":"蔺一帅,李飞","place":"A-222","start_time":7,"end_time":8}]}');
      }
      await HomeWidget.saveWidgetData('class_table_switcher_next', isToday);
      break;
    default:
  }
  await HomeWidget.updateWidget(
    name: 'ClassTableWidgetProvider',
    iOSName: 'ClasstableWidget',
  );
}
*/
