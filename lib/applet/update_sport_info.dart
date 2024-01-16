// Copyright 2024 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'package:watermeter/repository/logger.dart';
import 'package:get/get.dart';
import 'package:home_widget/home_widget.dart';
import 'package:watermeter/applet/widget_worker.dart';
import 'package:watermeter/model/xidian_sport/punch.dart';
import 'package:watermeter/repository/xidian_sport_session.dart';

Future<bool> updateSportInfo() async {
  log.i(
    "[WidgetWorker updateSportInfo] "
    "Updating sport homewidget info.",
  );

  int success = 0;
  int score = 0;
  String? lastInfoTime;
  String? lastInfoPlace;
  String? lastInfoDescription;

  try {
    await SportSession().getPunch();
    success = punchData.value.validTime.value;
    score = punchData.value.score.toInt();
    if (punchData.value.all.isNotEmpty) {
      PunchData toUse = punchData.value.all.last;
      lastInfoTime = toUse.time.format(pattern: 'yyyy-MM-dd HH:mm:ss');
      lastInfoPlace = toUse.machineName;
      lastInfoDescription = toUse.state;
    }
    log.i(
      "[WidgetWorker updateSportInfo] "
      "Updating sport info successful, sending data...",
    );
  } catch (e, s) {
    log.i(
      "[WidgetWorker updateSportInfo] "
      "Updating sport info failed, sending empty data...",
    );
    log.i(
      "[WidgetWorker updateSportInfo] "
      "Exception: \n$e\nStacktrace: \n$s",
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
    log.i(
      "[WidgetWorker updateSportInfo] "
      "UpdateStatus: $value.",
    );
    return value;
  });
  return toReturn ?? true;
}
