// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'dart:convert';
import 'dart:developer' as developer;

import 'package:background_fetch/background_fetch.dart';
import 'package:get/get.dart';
import 'package:home_widget/home_widget.dart';
import 'package:jiffy/jiffy.dart';
import 'package:watermeter/model/xidian_ids/classtable.dart';

import 'package:watermeter/controller/classtable_controller.dart';
import 'package:watermeter/controller/exam_controller.dart';

Future<bool> updateClasstableInfo() async {
  /// TODO: Add exception dealt...
  ClassToShowList toSend = ClassToShowList();
  var con = Get.put(ClassTableController());
  var c = con.nextClassArrangements;
  DateTime time = DateTime.now().add(Duration(days: c.$2 ? 1 : 0));

  /// Update exam info
  var examList = Get.put(ExamController()).isNotFinished;
  for (var i in examList) {
    if (i.startTime.year == time.year &&
        i.startTime.month == time.month &&
        i.startTime.date == time.day) {
      toSend.list.add(ClassToShow(
        name: i.subject,
        teacher: "Exam",
        place: i.place,
        // TODO: Rewrite this to string...
        startTime: 1,
        endTime: 2,
      ));
    }
  }

  /// Update class info
  for (var i in c.$1) {
    toSend.list.add(ClassToShow(
      name: con.classTableData.getClassDetail(i.index).name,
      teacher: i.teacher ?? "未知老师",
      place: i.classroom ?? "未知教室",
      startTime: i.start,
      endTime: i.stop,
    ));
  }
  await HomeWidget.saveWidgetData(
    'class_table_date',
    Jiffy.parseFromDateTime(time).yMd,
  ).then(
    (value) => developer.log(
      "saveData 'class_table_date' status: $value",
      name: "WidgetWorker",
    ),
  );
  await HomeWidget.saveWidgetData(
    'class_table_json',
    jsonEncode(toSend.toJson()),
  ).then(
    (value) => developer.log(
      "saveData 'class_table_json' status: $value\nvalue: ${jsonEncode(toSend.toJson())}",
      name: "WidgetWorker",
    ),
  );

  await HomeWidget.getWidgetData('class_table_json').then(
    (value) => developer.log(
      "confirm 'class_table_json' status: $value",
      name: "WidgetWorker",
    ),
  );

  var toReturn = await HomeWidget.updateWidget(
    name: 'ClassTableWidgetProvider',
    iOSName: 'ClasstableWidget',
  ).then((value) {
    developer.log(
      "UpdateStatus: $value",
      name: "WidgetWorker",
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
