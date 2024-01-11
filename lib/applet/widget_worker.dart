// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'dart:developer' as developer;

import 'package:background_fetch/background_fetch.dart';
import 'package:home_widget/home_widget.dart';
import 'package:watermeter/applet/update_classtable_info.dart';
import 'package:watermeter/applet/update_sport_info.dart';

Future<void> saveToWidget(String key, dynamic value) async {
  await HomeWidget.saveWidgetData(key, value).then(
    (result) => developer.log(
      "saveData '$key' status: $result value: $value",
      name: "WidgetWorker saveToWidget",
    ),
  );
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

  await Future.wait([
    updateClasstableInfo(),
    updateSportInfo(),
  ]);

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
