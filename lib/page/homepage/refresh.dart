// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

// Refresh formula for homepage.

import 'package:flutter_logs/flutter_logs.dart';
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

    FlutterLogs.logWarn(
      "PDA refresh",
      "_comboLogin",
      "Combo login failed! Because your password is wrong.",
    );
  } catch (e, s) {
    loginState = IDSLoginState.fail;

    FlutterLogs.logWarn(
      "PDA refresh",
      "_comboLogin",
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
  FlutterLogs.logWarn(
    "PDA refresh",
    "update",
    "Updating current class",
  );
  classTableController.updateCurrent();
  classTableController.update();

  // Update Examation Info
  FlutterLogs.logWarn(
    "PDA refresh",
    "update",
    "Updating exam info",
  );
  examController.get().then((value) => examController.update());

  // Update Electricity
  FlutterLogs.logWarn(
    "PDA refresh",
    "update",
    "Updating electricity",
  );
  electricity.update();
  owe_session.update();

  // Update Sport
  FlutterLogs.logWarn(
    "PDA refresh",
    "update",
    "Updating sport info",
  );
  updateSportInfo();

  // Update Library
  FlutterLogs.logWarn(
    "PDA refresh",
    "update",
    "Updating library",
  );
  borrow_info.LibrarySession().getBorrowList();

  // Update school card
  FlutterLogs.logWarn(
    "PDA refresh",
    "update",
    "Updating school card",
  );
  school_card_session.SchoolCardSession().initSession();
}

void updateOnAppResumed() {
  final classTableController = Get.put(ClassTableController());

  // Update Classtable
  FlutterLogs.logWarn(
    "PDA refresh",
    "updateOnAppResumed",
    "Updating current class",
  );
  classTableController.updateCurrent();
  classTableController.update();
}
