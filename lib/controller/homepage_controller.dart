// Copyright 2026 Traintime PDA Authours, originally by BenderBlog Rodriguez.
// SPDX-License-Identifier: MPL-2.0

import 'package:intl/intl.dart' show DateFormat;
import 'package:signals/signals.dart';
import 'package:watermeter/controller/classtable_controller.dart';
import 'package:watermeter/controller/custom_class_controller.dart';
import 'package:watermeter/controller/energy_controller.dart';
import 'package:watermeter/controller/exam_controller.dart';
import 'package:watermeter/controller/global_timer_controller.dart';
import 'package:watermeter/controller/library_controller.dart';
import 'package:watermeter/controller/other_experiment_controller.dart';
import 'package:watermeter/controller/physics_experiment_controller.dart';
import 'package:watermeter/controller/school_card_controller.dart';
import 'package:watermeter/controller/semester_controller.dart';
import 'package:watermeter/controller/sport_controller.dart';
import 'package:watermeter/controller/week_swift_controller.dart';
import 'package:watermeter/model/home_arrangement.dart';
import 'package:watermeter/model/password_exceptions.dart';
import 'package:watermeter/repository/ids_session/ids_reauth_client.dart';
import 'package:watermeter/repository/ids_session/ids_session.dart';
import 'package:watermeter/repository/logger.dart';
import 'package:watermeter/repository/notification/course_reminder_service.dart';
import 'package:watermeter/repository/preference.dart' as preference;
import 'package:watermeter/repository/system_calendar_sync_service.dart';
import 'package:watermeter/repository/widget_state_sync.dart';

enum ArrangementState { fetching, fetched, error, none }

enum HomepageSourceState { loading, success, error, ignored, none }

enum HomepageFailedSource {
  classInfo,
  examInfo,
  physicsExperiment,
  otherExperiment,
}

class HomepageController {
  static final HomepageController i = HomepageController._();

  HomepageController._() {
    GlobalTimerController.i;
    SemesterController.i;
    WeekSwiftController.i;
    ClassTableController.i;
    ExamController.i;
    OtherExperimentController.i;
    PhysicsExperimentController.i;
  }

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
        "[HomepageController][_comboLogin] "
        "Combo login failed because the password is wrong.",
      );
    } on IDSReAuthCancelledException {
      loginState = IDSLoginState.cancelled;
      log.info(
        '[HomepageController][_comboLogin] '
        'Additional verification was cancelled by the user.',
      );
    } catch (e, s) {
      loginState = IDSLoginState.fail;
      log.warning(
        "[HomepageController][_comboLogin] Combo login failed.",
        e,
        s,
      );
    }
  }

  Future<void> _safeReload(
    String name,
    Future<void> Function() callback,
  ) async {
    try {
      await callback();
    } catch (e, s) {
      log.handle(e, s, "[HomepageController][$name] Have issue");
    }
  }

  Future<void> refresh({
    bool forceRetryLogin = false,
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
      _safeReload("Sport", () async {
        await SportController.i.reloadClass();
      }),
      _safeReload("Library", LibraryController.i.reloadBorrowList),
      _safeReload("SchoolCard", SchoolCardController.i.reloadOverview),
      _safeReload("Electricity", EnergyController.i.refreshElectricityInfo),
    ]);
    await maybeAutoSyncSystemCalendar();

    final reminderService = CourseReminderService();
    if (reminderService.isInitialized) {
      reminderService.validateAndUpdateNotifications();
    } else {
      await reminderService.initialize();
      reminderService.validateAndUpdateNotifications();
    }

    final hasCredential =
        preference.getString(preference.Preference.idsAccount).isNotEmpty &&
        preference.getString(preference.Preference.idsPassword).isNotEmpty;
    await syncWidgetLoginState(hasCredential);
  }

  List<HomeArrangement> _sortArrangements(Iterable<HomeArrangement> data) {
    return data.toList()..sort();
  }

  bool _isEffectiveLoading(HomepageSourceState state) =>
      state == HomepageSourceState.loading;

  bool _isRealError(HomepageSourceState state) =>
      state == HomepageSourceState.error;

  List<HomeArrangement> _getCustomClassOfDay(DateTime day) {
    final formatter = DateFormat(HomeArrangement.format);
    final result = <HomeArrangement>[];
    for (final cc in CustomClassController.i.customClassesSignal.value) {
      for (final tr in cc.timeRanges) {
        if (tr.startTime.year == day.year &&
            tr.startTime.month == day.month &&
            tr.startTime.day == day.day) {
          result.add(
            HomeArrangement(
              name: cc.name,
              teacher: cc.teacher,
              place: cc.classroom,
              startTimeStr: formatter.format(tr.startTime),
              endTimeStr: formatter.format(tr.endTime),
            ),
          );
        }
      }
    }
    return result;
  }

  late final updateTimeComputedSignal = computed<DateTime>(
    () => GlobalTimerController.i.currentTimeSignal.value,
  );

  late final classTableSourceStateComputedSignal =
      computed<HomepageSourceState>(() {
        final state = ClassTableController.i.schoolClassTableStateSignal.value;
        if (state.isLoading) {
          return HomepageSourceState.loading;
        }
        if (ClassTableController.i.hasValidClassInfo.value) {
          return HomepageSourceState.success;
        }
        if (state is AsyncError) {
          return HomepageSourceState.error;
        }
        return HomepageSourceState.none;
      });

  late final examSourceStateComputedSignal = computed<HomepageSourceState>(() {
    final state = ExamController.i.examInfoStateSignal.value;
    if (state.isLoading) {
      return HomepageSourceState.loading;
    }
    if (ExamController.i.hasValidExamInfo.value) {
      return HomepageSourceState.success;
    }
    if (state is AsyncError) {
      return HomepageSourceState.error;
    }
    return HomepageSourceState.none;
  });

  late final physicsExperimentSourceStateComputedSignal =
      computed<HomepageSourceState>(() {
        final state =
            PhysicsExperimentController.i.physicsExperimentStateSignal.value;
        if (state.isLoading) {
          return HomepageSourceState.loading;
        }
        if (PhysicsExperimentController.i.hasValidPhysicsExperiment.value) {
          return HomepageSourceState.success;
        }
        if (state is AsyncError) {
          final error = state.error;
          if (error is NoPasswordException &&
              error.type == PasswordType.physicsExperiment) {
            return HomepageSourceState.ignored;
          }
          return HomepageSourceState.error;
        }
        return HomepageSourceState.none;
      });

  late final otherExperimentSourceStateComputedSignal =
      computed<HomepageSourceState>(() {
        final state =
            OtherExperimentController.i.otherExperimentStateSignal.value;
        if (state.isLoading) {
          return HomepageSourceState.loading;
        }
        if (OtherExperimentController.i.hasValidOtherExperiment.value) {
          return HomepageSourceState.success;
        }
        if (state is AsyncError) {
          return HomepageSourceState.error;
        }
        return HomepageSourceState.none;
      });

  late final _sourceStatesComputedSignal = computed<List<HomepageSourceState>>(
    () => [
      classTableSourceStateComputedSignal.value,
      examSourceStateComputedSignal.value,
      physicsExperimentSourceStateComputedSignal.value,
      otherExperimentSourceStateComputedSignal.value,
    ],
  );

  late final isTomorrowComputedSignal = computed<bool>(() {
    final updateTime = GlobalTimerController.i.currentTimeSignal.value;
    return updateTime.hour * 60 + updateTime.minute > 21 * 60 + 25;
  });

  late final todayArrangementComputedSignal = computed<List<HomeArrangement>>(
    () => _sortArrangements([
      ...ClassTableController.i.arrangementOfTodayComputedSignal.value,
      ..._getCustomClassOfDay(GlobalTimerController.i.currentTimeSignal.value),
      ...ExamController.i.todayExams.value,
      ...PhysicsExperimentController
          .i
          .physicsExperimentOfTodayComputedSignal
          .value,
      ...OtherExperimentController.i.otherExperimentOfTodayComputedSignal.value,
    ]),
  );

  late final tomorrowArrangementComputedSignal =
      computed<List<HomeArrangement>>(
        () => _sortArrangements([
          ...ClassTableController.i.arrangementOfTomorrowComputedSignal.value,
          ..._getCustomClassOfDay(
            GlobalTimerController.i.currentTimeSignal.value.add(
              const Duration(days: 1),
            ),
          ),
          ...ExamController.i.tomorrowExams.value,
          ...PhysicsExperimentController
              .i
              .physicsExperimentOfTomorrowComputedSignal
              .value,
          ...OtherExperimentController
              .i
              .otherExperimentOfTomorrowComputedSignal
              .value,
        ]),
      );

  late final arrangementComputedSignal = computed<List<HomeArrangement>>(() {
    final updateTime = updateTimeComputedSignal.value;
    final isTomorrow = isTomorrowComputedSignal.value;

    if (isTomorrow) {
      return tomorrowArrangementComputedSignal.value;
    }

    return _sortArrangements(
      todayArrangementComputedSignal.value.where(
        (element) => updateTime.isBefore(element.endTime),
      ),
    );
  });

  late final hasArrangementComputedSignal = computed<bool>(
    () => arrangementComputedSignal.value.isNotEmpty,
  );

  late final arrangementStateComputedSignal = computed<ArrangementState>(() {
    final sourceStates = _sourceStatesComputedSignal.value;

    if (classTableSourceStateComputedSignal.value ==
        HomepageSourceState.success) {
      return ArrangementState.fetched;
    }

    if (sourceStates.any(_isEffectiveLoading)) {
      return ArrangementState.fetching;
    }

    if (sourceStates.any(_isRealError)) {
      return ArrangementState.error;
    }

    return ArrangementState.none;
  });

  late final homepageArrangementStateComputedSignal =
      computed<ArrangementState>(() => arrangementStateComputedSignal.value);

  late final isAllSourcesLoadingComputedSignal = computed<bool>(
    () => _sourceStatesComputedSignal.value.every(_isEffectiveLoading),
  );

  late final isPartialSourcesLoadingComputedSignal = computed<bool>(() {
    final sourceStates = _sourceStatesComputedSignal.value;
    return sourceStates.any(_isEffectiveLoading) &&
        !sourceStates.every(_isEffectiveLoading);
  });

  late final failedSourcesComputedSignal = computed<List<HomepageFailedSource>>(
    () {
      final failedSources = <HomepageFailedSource>[];

      if (classTableSourceStateComputedSignal.value ==
          HomepageSourceState.error) {
        failedSources.add(HomepageFailedSource.classInfo);
      }
      if (examSourceStateComputedSignal.value == HomepageSourceState.error) {
        failedSources.add(HomepageFailedSource.examInfo);
      }
      if (physicsExperimentSourceStateComputedSignal.value ==
          HomepageSourceState.error) {
        failedSources.add(HomepageFailedSource.physicsExperiment);
      }
      if (otherExperimentSourceStateComputedSignal.value ==
          HomepageSourceState.error) {
        failedSources.add(HomepageFailedSource.otherExperiment);
      }

      return failedSources;
    },
  );

  late final havePhysicsExperimentSignal = computed<bool>(
    () => ClassTableController.i.havePhysicsExperimentSignal.value,
  );

  final isPostGraduate = preference.getBool(preference.Preference.role);
}
