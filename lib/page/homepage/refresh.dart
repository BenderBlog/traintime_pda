// Copyright 2023 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

// Refresh formula for homepage.

import 'package:jiffy/jiffy.dart';
import 'package:watermeter/model/home_arrangement.dart';
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
import 'package:watermeter/repository/xidian_ids/ids_session.dart';

DateTime updateTime = DateTime.now();

RxInt remaining = 0.obs;
RxBool isTomorrow = false.obs;
Rxn<HomeArrangement> next = Rxn<HomeArrangement>();
Rxn<HomeArrangement> current = Rxn<HomeArrangement>();
RxList<HomeArrangement> arrangement = <HomeArrangement>[].obs;
Rx<ArrangementState> arrangementState = ArrangementState.none.obs;

enum ArrangementState {
  fetching,
  fetched,
  error,
  none,
}

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
  final examController = Get.put(ExamController());

  // Update data
  message.checkMessage();

  // Retry Login
  if (forceRetryLogin || loginState == IDSLoginState.fail) {
    await _comboLogin(sliderCaptcha: sliderCaptcha);
  }

  await Future.wait([
    examController
        .get()
        .then((value) => updateCurrentData())
        .onError((error, stackTrace) => updateCurrentData()),
    electricity.update(),
    owe_session.update(),
    updateSportInfo(),
    borrow_info.LibrarySession().getBorrowList(),
    school_card_session.SchoolCardSession().initSession(),
  ]);
}

/// Originally updateOnAppResumed
void updateCurrentData() {
  log.i(
    "[updateCurrentData]"
    "Updating current data. ${arrangementState.value}",
  );
  if (arrangementState.value == ArrangementState.fetching) {
    return;
  }
  arrangementState.value = ArrangementState.fetching;
  final classTableController = Get.put(ClassTableController());
  final examController = Get.put(ExamController());

  // Update Classtable

  List<HomeArrangement> toAdd = [];
  updateTime = DateTime.now();
  log.i(
    "[updateCurrentData]"
    "Update classtable, updateTime: $updateTime, "
    "isTomorrow: ${classTableController.isTomorrow(updateTime)} "
    "classTableControllerState: ${classTableController.state} "
    "examControllerState: ${ExamStatus.fetched}",
  );
  if (classTableController.isTomorrow(updateTime)) {
    DateTime tomorrow = updateTime.add(const Duration(days: 1));
    isTomorrow.value = true;
    if (classTableController.state == ClassTableState.fetched) {
      toAdd.addAll(classTableController.getArrangementOfDay(tomorrow));
    }
    if (examController.status == ExamStatus.fetched ||
        examController.status == ExamStatus.cache) {
      toAdd.addAll(examController.getExamOfDate(tomorrow));
    }
  } else {
    isTomorrow.value = false;
    if (classTableController.state == ClassTableState.fetched) {
      toAdd.addAll(classTableController.getArrangementOfDay(updateTime));
    }
    if (examController.status == ExamStatus.fetched ||
        examController.status == ExamStatus.cache) {
      toAdd.addAll(examController.getExamOfDate(updateTime));
    }
    toAdd.removeWhere((element) => updateTime.isAfter(element.endTime));
  }

  toAdd.sort((a, b) => Jiffy.parseFromDateTime(a.startTime)
      .diff(Jiffy.parseFromDateTime(b.startTime))
      .toInt());

  arrangement.clear();
  arrangement.addAll(toAdd);
  log.i("[updateCurrentData]toAddArrangement: ${toAdd.length}");

  Iterator<HomeArrangement> arr = arrangement.iterator;
  if (isTomorrow.isTrue) {
    current.value = arr.moveNext() ? arr.current : null;
    next.value = arr.moveNext() ? arr.current : null;
  } else {
    while (arr.moveNext()) {
      log.i(
        "[updateCurrentData] arr.current: ${arr.current.name}",
      );

      /// Is current.
      if (Jiffy.parseFromDateTime(updateTime).isBetween(
        Jiffy.parseFromDateTime(arr.current.startTime),
        Jiffy.parseFromDateTime(arr.current.endTime),
      )) {
        break;
      }

      /// Will be occured next 30 minute.
      if (List<int>.generate(
        30,
        (index) => index,
      ).contains(
        Jiffy.parseFromDateTime(arr.current.startTime).diff(
          Jiffy.parseFromDateTime(updateTime),
          unit: Unit.minute,
        ),
      )) {
        break;
      }
    }

    try {
      current.value = arr.current;
    } on TypeError {
      current.value = null;
    }
    next.value = arr.moveNext() ? arr.current : null;
  }
  int len = arrangement.length;
  if (current.value != null) len -= 1;
  if (next.value != null) len -= 1;
  remaining.value = len;

  log.i(
    "[updateCurrentData]current: ${current.value?.name}, "
    "next: ${next.value?.name}, remaining: ${remaining.value}",
  );

  arrangementState.value = ArrangementState.fetched;
}
