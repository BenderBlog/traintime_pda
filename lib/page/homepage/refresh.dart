// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

// Refresh formula for homepage.

import 'package:watermeter/controller/classtable_controller.dart';
import 'package:watermeter/controller/electricity_controller.dart';
import 'package:watermeter/controller/exam_controller.dart';
import 'package:watermeter/controller/library_controller.dart';
import 'package:watermeter/controller/other_experiment_controller.dart';
import 'package:watermeter/controller/physics_experiment_controller.dart';
import 'package:watermeter/controller/school_card_controller.dart';
import 'package:watermeter/controller/schoolnet_controller.dart';
import 'package:watermeter/controller/semester_controller.dart';
import 'package:watermeter/repository/logger.dart';
import 'package:watermeter/repository/notification/course_reminder_service.dart';
import 'package:watermeter/repository/xidian_ids/ids_session.dart';

Future<void> _comboLogin({
  required Future<void> Function(String) sliderCaptcha,
}) async {
  if (loginState == IDSLoginState.requesting) {
    return;
  }
  loginState = IDSLoginState.requesting;

  try {
    await IDSSession().checkAndLogin(
      target:
          "https://ehall.xidian.edu.cn/login?service="
          "https://ehall.xidian.edu.cn/new/index.html",
      sliderCaptcha: sliderCaptcha,
    );
    loginState = IDSLoginState.success;
  } on PasswordWrongException {
    loginState = IDSLoginState.passwordWrong;
    log.warning(
      "[_comboLogin] "
      "Combo login failed! Because your password is wrong.",
    );
  } catch (e, s) {
    loginState = IDSLoginState.fail;
    log.warning(
      "[_comboLogin] "
      "Combo login failed! Because of the following error: "
      "$e\nThe stack of the error is: \n$s",
    );
  }
}

Future<void> _safeReload(String name, Future<void> Function() callback) async {
  try {
    await callback();
  } catch (e, s) {
    log.handle(e, s, "[homepage Update][$name] Have issue");
  }
}

Future<void> update({
  bool forceRetryLogin = false,
  required context,
  required Future<void> Function(String) sliderCaptcha,
}) async {
  if (forceRetryLogin || loginState == IDSLoginState.fail) {
    await _comboLogin(sliderCaptcha: sliderCaptcha);
  }

  await _safeReload("Semester", SemesterController.i.refreshSemesterInfo);

  await Future.wait([
    _safeReload("Classtable", ClassTableController.i.reloadClassTable),
    _safeReload("Exam", ExamController.i.reloadExamInfo),
    _safeReload(
      "PhysicsExperiment",
      PhysicsExperimentController.i.reloadPhysicsExperiment,
    ),
    _safeReload(
      "OtherExperiment",
      OtherExperimentController.i.reloadOtherExperiment,
    ),
    _safeReload("Library", LibraryController.i.reloadBorrowList),
    _safeReload("SchoolCard", SchoolCardController.i.reloadOverview),
    _safeReload("Electricity", ElectricityController.i.refreshElectricityInfo),
    _safeReload("Schoolnet", SchoolnetController.i.reloadSchoolnetInfo),
  ]);

  if (CourseReminderService().isInitialized) {
    CourseReminderService().validateAndUpdateNotifications();
  } else {
    await CourseReminderService().initialize();
    CourseReminderService().validateAndUpdateNotifications();
  }
}
