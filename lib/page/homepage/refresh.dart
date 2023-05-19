/*
Refresh formula for homepage.
Copyright 2022 SuperBart

This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.

Please refer to ADDITIONAL TERMS APPLIED TO WATERMETER SOURCE CODE
if you want to use.
*/

import 'package:get/get.dart';
import 'package:watermeter/controller/classtable_controller.dart';
import 'package:watermeter/controller/exam_controller.dart';
import 'package:watermeter/repository/electricity/electricity_session.dart'
    as electricity;
import 'package:watermeter/repository/xidian_sport/punch_session.dart' as punch;
import 'dart:developer' as developer;

void update() {
  final classTableController = Get.put(ClassTableController());
  final examController = Get.put(ExamController());
  // Update Classtable
  developer.log(
    "Updating classtable",
    name: "Homepage Update",
  );
  classTableController
      .updateClassTable(isForce: true)
      .then((value) => classTableController.update());
  // Update Examation Info
  developer.log(
    "Updating exam info",
    name: "Homepage Update",
  );
  examController.get().then((value) => examController.update());
  // Update Electricity
  developer.log(
    "Updating electricity",
    name: "Homepage Update",
  );
  electricity.update();
  // Update Sport
  developer.log(
    "Updating punch data",
    name: "Homepage Update",
  );
  punch.getPunch();
}
