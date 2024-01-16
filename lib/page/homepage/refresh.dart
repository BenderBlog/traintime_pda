// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

// Refresh formula for homepage.

import 'package:watermeter/repository/logger.dart';
import 'package:get/get.dart';
import 'package:watermeter/applet/update_sport_info.dart';
import 'package:watermeter/controller/classtable_controller.dart';
import 'package:watermeter/controller/exam_controller.dart';
import 'package:watermeter/repository/xidian_ids/school_card_session.dart'
    as school_card_session;
import 'package:watermeter/repository/electricity_session.dart' as electricity;
import 'package:watermeter/repository/message_session.dart' as message;
import 'package:watermeter/repository/xidian_ids/payment_session.dart'
    as owe_session;
import 'package:watermeter/repository/xidian_ids/library_session.dart'
    as borrow_info;
//import 'package:watermeter/repository/experiment/experiment_session.dart';
import 'package:watermeter/repository/xidian_ids/ids_session.dart';

Future<void> _comboLogin({
  Future<void> Function(String)? sliderCaptcha,
}) async {
  // Guard
  if (loginState == IDSLoginState.requesting) {
    return;
  }
  loginState = IDSLoginState.requesting;

  try {
    await IDSSession().checkAndLogin(
      target: "https://ehall.xidian.edu.cn/login?service="
          "https://ehall.xidian.edu.cn/new/index.html",
      sliderCaptcha: sliderCaptcha,
    );
    loginState = IDSLoginState.success;
  } on PasswordWrongException {
    loginState = IDSLoginState.passwordWrong;

    log.w(
      "[_comboLogin] "
      "Combo login failed! Because your password is wrong.",
    );
  } catch (e, s) {
    loginState = IDSLoginState.fail;

    log.w(
      "[_comboLogin] "
      "Combo login failed! Because of the following error: "
      "$e\nThe stack of the error is: \n$s",
    );
  }
}

Future<void> update({
  bool forceRetryLogin = false,
  Future<void> Function(String)? sliderCaptcha,
}) async {
  final classTableController = Get.put(ClassTableController());
  final examController = Get.put(ExamController());

  // Update data
  message.checkMessage();

  // Retry Login
  if (forceRetryLogin || loginState == IDSLoginState.fail) {
    await _comboLogin(sliderCaptcha: sliderCaptcha);
  }

  // Update Classtable
  log.i(
    "[refresh][update] "
    "Updating current class",
  );
  classTableController.updateCurrent();
  classTableController.update();

  // Update Examation Info
  log.i(
    "[refresh][update] "
    "Updating exam info",
  );
  examController.get().then((value) => examController.update());

  // Update Electricity
  log.i(
    "[refresh][update] "
    "Updating electricity",
  );
  electricity.update();
  owe_session.update();

  // Update Sport
  log.i(
    "[refresh][update] "
    "Updating sport info",
  );
  updateSportInfo();

  // Update Library
  log.i(
    "[refresh][update] "
    "Updating library",
  );
  borrow_info.LibrarySession().getBorrowList();

  // Update school card
  log.i(
    "[refresh][update] "
    "Updating school card",
  );
  school_card_session.SchoolCardSession().initSession();
}

void updateOnAppResumed() {
  final classTableController = Get.put(ClassTableController());

  // Update Classtable
  log.i(
    "[updateOnAppResumed]"
    "Updating current class",
  );
  classTableController.updateCurrent();
  classTableController.update();
}
