// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

// Refresh formula for homepage.

import 'package:get/get.dart';
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
import 'package:watermeter/repository/xidian_sport_session.dart';
import 'dart:developer' as developer;
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
  } on PasswordWrongException catch (e, s) {
    loginState = IDSLoginState.passwordWrong;

    developer.log(
      "Combo login failed! Because of the following error: ",
      name: "Watermeter",
    );
    developer.log(
      "$e\nThe stack of the error is: $s",
      name: "Watermeter",
    );
  } catch (e, s) {
    loginState = IDSLoginState.fail;

    developer.log(
      "Combo login failed! Because of the following error: ",
      name: "Watermeter",
    );
    developer.log(
      "$e\nThe stack of the error is: $s",
      name: "Watermeter",
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
  owe_session.update();

  // Update Sport
  developer.log(
    "Updating punch data",
    name: "Homepage Update",
  );
  SportSession().getPunch();

  // Update Library
  developer.log(
    "Updating library",
    name: "Homepage Update",
  );
  borrow_info.LibrarySession().getBorrowList();

  // Update school card
  developer.log(
    "Updating school card",
    name: "Homepage Update",
  );
  school_card_session.SchoolCardSession().initSession();
}

void updateOnAppResumed() {
  final classTableController = Get.put(ClassTableController());

  // Update Classtable
  developer.log(
    "Updating current class",
    name: "Homepage Update",
  );
  classTableController.updateCurrent();
  classTableController.update();
}
