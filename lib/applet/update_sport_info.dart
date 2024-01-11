// Copyright 2024 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'dart:developer' as developer;

import 'package:get/get.dart';
import 'package:home_widget/home_widget.dart';
import 'package:watermeter/applet/widget_worker.dart';
import 'package:watermeter/model/xidian_sport/punch.dart';
import 'package:watermeter/repository/xidian_sport_session.dart';

Future<bool> updateSportInfo() async {
  developer.log(
    "Updating sport homewidget info.",
    name: "WidgetWorker updateSportInfo",
  );

  int success = 0;
  int score = 0;
  String? lastInfoTime;
  String? lastInfoPlace;
  String? lastInfoDescription;

  try {
    developer.log(
      "Updating sport info.",
      name: "WidgetWorker updateSportInfo",
    );
    await SportSession().getPunch();
    success = punchData.value.validTime.value;
    score = punchData.value.score.toInt();
    if (punchData.value.all.isNotEmpty) {
      PunchData toUse = punchData.value.all.last;
      lastInfoTime = toUse.time.format(pattern: 'yyyy-MM-dd HH:mm');
      lastInfoPlace = toUse.machineName;
      lastInfoDescription = toUse.state;
    }
    developer.log(
      "Updating sport info successful, sending data...",
      name: "WidgetWorker updateSportInfo",
    );
  } catch (e) {
    developer.log(
      "Updating sport info failed, sending empty data...",
      name: "WidgetWorker updateSportInfo",
    );
    developer.log(
      "Exception: $e",
      name: "WidgetWorker updateSportInfo",
    );
    success = -1;
    score = -1;
  }

  await saveToWidget('success_punch', success);
  await saveToWidget('score_punch', score);
  await saveToWidget('last_info_time', lastInfoTime);
  await saveToWidget('last_info_place', lastInfoPlace);
  await saveToWidget('last_info_description', lastInfoDescription);

  var toReturn = await HomeWidget.updateWidget(
    iOSName: 'SportWidget',
  ).then((value) {
    developer.log(
      "UpdateStatus: $value",
      name: "WidgetWorker updateSportInfo",
    );
    return value;
  });
  return toReturn ?? true;
}
