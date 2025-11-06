// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

// Refresh formula for homepage.

import 'package:watermeter/controller/experiment_controller.dart';
import 'package:watermeter/model/home_arrangement.dart';
import 'package:watermeter/repository/logger.dart';
import 'package:get/get.dart';
import 'package:watermeter/controller/classtable_controller.dart';
import 'package:watermeter/controller/exam_controller.dart';
import 'package:watermeter/repository/notification/course_reminder.dart';
import 'package:watermeter/repository/xidian_ids/school_card_session.dart'
    as school_card_session;
import 'package:watermeter/repository/pda_service_session.dart' as message;
import 'package:watermeter/repository/xidian_ids/library_session.dart'
    as borrow_info;
import 'package:watermeter/repository/xidian_ids/electricity_session.dart'
    as electricity;
import 'package:watermeter/repository/xidian_ids/ids_session.dart';
import 'package:watermeter/repository/schoolnet_session.dart' as school_net;
import 'package:watermeter/repository/preference.dart' as preference;

DateTime updateTime = DateTime.now();

RxInt remaining = 0.obs;
RxBool isTomorrow = false.obs;
Rxn<HomeArrangement> next = Rxn<HomeArrangement>();
Rxn<HomeArrangement> current = Rxn<HomeArrangement>();
RxList<HomeArrangement> arrangement = <HomeArrangement>[].obs;
Rx<ArrangementState> arrangementState = ArrangementState.none.obs;

enum ArrangementState { fetching, fetched, error, none }

Future<void> _comboLogin({
  required Future<void> Function(String) sliderCaptcha,
}) async {
  // Guard
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

Future<void> update({
  bool forceRetryLogin = false,
  required context,
  required Future<void> Function(String) sliderCaptcha,
}) async {
  // Update data
  message.getClubList();

  // Retry Login
  if (forceRetryLogin || loginState == IDSLoginState.fail) {
    await _comboLogin(sliderCaptcha: sliderCaptcha);
  }

  await Future.wait([
    Future.wait([
      Future(() async {
        final c = Get.put(ExamController());
        await c.get();
      }),
      Future(() async {
        final c = Get.put(ClassTableController());
        await c.updateClassTable();
      }),
      Future(() async {
        final c = Get.put(ExperimentController());
        await c.get();
      }),
      Future(() => borrow_info.LibrarySession().getBorrowList()),
      Future(() => school_card_session.SchoolCardSession().initSession()),
      Future(() => electricity.update()),
      Future(() => school_net.update()),
    ]).then((value) => updateCurrentData()).onError((error, stackTrace) {
      log.info(
        "[homepage Update]"
        "Update failed with following exception: $error\n"
        "$stackTrace",
      );
      updateCurrentData();
    }),
  ]);

  // 验证和更新课程通知
  _validateCourseNotifications();
}

/// 验证和更新课程通知（在后台静默执行）
Future<void> _validateCourseNotifications() async {
  try {
    // 检查通知是否启用
    final isEnabled = preference.prefs.getBool('notification_enabled') ?? false;
    if (!isEnabled) {
      return;
    }

    final courseReminder = CourseReminder();
    await courseReminder.initialize();
    await courseReminder.validateAndUpdateNotifications();

    log.info('[_validateCourseNotifications] Course notifications validated successfully');
  } catch (e, stackTrace) {
    log.error('[_validateCourseNotifications] Failed to validate course notifications', e, stackTrace);
    // 静默失败，不影响主流程
  }
}

/// Originally updateOnAppResumed
void updateCurrentData() {
  log.info(
    "[updateCurrentData]"
    "Updating current data. ${arrangementState.value}",
  );
  final classTableController = Get.put(ClassTableController());
  final examController = Get.put(ExamController());
  final experimentController = Get.put(ExperimentController());

  if (arrangementState.value == ArrangementState.fetching) {
    return;
  }
  if (classTableController.state == ClassTableState.fetching) {
    return;
  }

  arrangementState.value = ArrangementState.fetching;

  if (classTableController.state == ClassTableState.error) {
    arrangementState.value = ArrangementState.error;
    return;
  }

  // Update Classtable

  List<HomeArrangement> toAdd = [];
  updateTime = DateTime.now();

  log.info(
    "[updateCurrentData]"
    "Update classtable, updateTime: $updateTime\n"
    "isTomorrow: ${classTableController.isTomorrow(updateTime)}\n"
    "classTableControllerState: ${classTableController.state}\n"
    "examControllerState: ${examController.status}\n"
    "physicsExperimentState: ${experimentController.physicsStatus}\n"
    "otherExperimentState: ${experimentController.otherStatus}",
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
    if ((experimentController.physicsStatus == ExperimentStatus.fetched ||
            experimentController.physicsStatus == ExperimentStatus.cache) ||
        (experimentController.otherStatus == ExperimentStatus.fetched ||
            experimentController.otherStatus == ExperimentStatus.cache)) {
      toAdd.addAll(experimentController.getExperimentOfDay(tomorrow));
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
    if ((experimentController.physicsStatus == ExperimentStatus.fetched ||
            experimentController.physicsStatus == ExperimentStatus.cache) ||
        (experimentController.otherStatus == ExperimentStatus.fetched ||
            experimentController.otherStatus == ExperimentStatus.cache)) {
      toAdd.addAll(experimentController.getExperimentOfDay(updateTime));
    }
    toAdd.removeWhere((element) => !updateTime.isBefore(element.endTime));
  }

  toAdd.sort((a, b) => a.startTime.difference(b.startTime).inMicroseconds);

  arrangement.clear();
  arrangement.addAll(toAdd);
  log.info("[updateCurrentData]toAddArrangement: ${toAdd.length}");

  if (isTomorrow.isTrue) {
    current.value = null;
    next.value = arrangement.isEmpty ? null : arrangement[0];
  } else {
    Iterator<HomeArrangement> arr = arrangement.iterator;
    while (arr.moveNext()) {
      log.info("[updateCurrentData] arr.current: ${arr.current.name}");

      /// Is current.
      if (updateTime.microsecondsSinceEpoch >=
              arr.current.startTime.microsecondsSinceEpoch &&
          updateTime.microsecondsSinceEpoch <=
              arr.current.endTime.microsecondsSinceEpoch) {
        break;
      }

      /// If break, an hour advance.
      int inAdvance = 30;
      int currentTime = updateTime.hour * 60 + updateTime.minute;
      if (currentTime < 8.5 * 60 ||
          (currentTime < 14 * 60 && currentTime >= 12 * 60) ||
          (currentTime < 19 * 60 && currentTime >= 18 * 60)) {
        inAdvance = 60;
      }

      /// Will be occured next 30 minute.
      if (List<int>.generate(
        inAdvance,
        (index) => index,
      ).contains(arr.current.startTime.difference(updateTime).inMinutes)) {
        break;
      }
    }

    try {
      current.value = arr.current;
    } on TypeError {
      current.value = null;
    }

    if (current.value == null) {
      next.value = arrangement.isEmpty ? null : arrangement[0];
    } else if (arr.moveNext()) {
      next.value = arr.current;
    } else {
      next.value = null;
    }
  }
  int len = arrangement.length;
  if (current.value != null) len -= 1;
  if (next.value != null) len -= 1;
  remaining.value = len;

  log.info(
    "[updateCurrentData]current: ${current.value?.name}, "
    "next: ${next.value?.name}, remaining: ${remaining.value}",
  );

  arrangementState.value = ArrangementState.fetched;
}
