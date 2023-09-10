// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

// Refresh formula for homepage.

import 'package:get/get.dart';
import 'package:watermeter/controller/classtable_controller.dart';
import 'package:watermeter/controller/exam_controller.dart';
import 'package:watermeter/controller/library_controller.dart';
import 'package:watermeter/controller/school_card_controller.dart';
import 'package:watermeter/repository/electricity_session.dart' as electricity;
//import 'package:watermeter/repository/xidian_ids/experiment_session.dart';
import 'package:watermeter/repository/xidian_sport_session.dart';
import 'dart:developer' as developer;

void update() {
  final classTableController = Get.put(ClassTableController());
  final examController = Get.put(ExamController());
  final libraryController = Get.put(LibraryController());
  final schoolCardController = Get.put(SchoolCardController());

  // Update Classtable
  developer.log(
    "Updating current class",
    name: "Homepage Update",
  );
  classTableController.updateCurrent();
  classTableController.update();
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
  SportSession().getPunch();
  // Update Library
  libraryController.onReady();
  // Update school card
  schoolCardController.updateMoney();
  // Get physics exp data
  // var data = ExperimentSession();
  // data.login().then((value) async => await data.getData());
}
