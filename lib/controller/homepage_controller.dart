// Copyright 2026 Traintime PDA Authours, originally by BenderBlog Rodriguez.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/foundation.dart';
import 'package:signals/signals.dart';
import 'package:watermeter/controller/classtable_controller.dart';
import 'package:watermeter/controller/exam_controller.dart';
import 'package:watermeter/controller/global_timer_controller.dart';
import 'package:watermeter/controller/other_experiment_controller.dart';
import 'package:watermeter/controller/physics_experiment_controller.dart';
import 'package:watermeter/model/password_exceptions.dart';
import 'package:watermeter/model/home_arrangement.dart';
import 'package:watermeter/repository/preference.dart' as preference;

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
  }

  int _getInAdvanceMinutes(DateTime updateTime) {
    final currentTime = updateTime.hour * 60 + updateTime.minute;
    if (currentTime < 8.5 * 60 ||
        (currentTime < 14 * 60 && currentTime >= 12 * 60) ||
        (currentTime < 19 * 60 && currentTime >= 18 * 60)) {
      return 60;
    }
    return 30;
  }

  List<HomeArrangement> _sortArrangements(Iterable<HomeArrangement> data) {
    final result = data.toList();
    result.sort((a, b) => a.startTime.compareTo(b.startTime));
    return result;
  }

  bool _isEffectiveLoading(HomepageSourceState state) =>
      state == HomepageSourceState.loading;

  bool _isRealError(HomepageSourceState state) =>
      state == HomepageSourceState.error;

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

  late final _arrangementSelectionComputedSignal =
      computed<(HomeArrangement?, HomeArrangement?, int)>(() {
        final updateTime = updateTimeComputedSignal.value;
        final arrangement = arrangementComputedSignal.value;

        if (arrangement.isEmpty) {
          return (null, null, 0);
        }

        if (isTomorrowComputedSignal.value) {
          return (null, arrangement.first, arrangement.length - 1);
        }

        final inAdvance = _getInAdvanceMinutes(updateTime);
        HomeArrangement? current;
        HomeArrangement? next;
        int currentIndex = -1;

        for (var i = 0; i < arrangement.length; ++i) {
          final item = arrangement[i];
          final isCurrent =
              updateTime.microsecondsSinceEpoch >=
                  item.startTime.microsecondsSinceEpoch &&
              updateTime.microsecondsSinceEpoch <=
                  item.endTime.microsecondsSinceEpoch;
          final isUpcomingSoon =
              item.startTime.difference(updateTime).inMinutes >= 0 &&
              item.startTime.difference(updateTime).inMinutes < inAdvance;

          if (isCurrent || isUpcomingSoon) {
            current = item;
            currentIndex = i;
            break;
          }
        }

        if (current == null) {
          next = arrangement.first;
        } else if (currentIndex + 1 < arrangement.length) {
          next = arrangement[currentIndex + 1];
        }

        int remaining = arrangement.length;
        if (current != null) remaining -= 1;
        if (next != null) remaining -= 1;

        return (current, next, remaining);
      });

  late final currentComputedSignal = computed<HomeArrangement?>(
    () => _arrangementSelectionComputedSignal.value.$1,
  );

  late final nextComputedSignal = computed<HomeArrangement?>(
    () => _arrangementSelectionComputedSignal.value.$2,
  );

  late final remainingComputedSignal = computed<int>(
    () => _arrangementSelectionComputedSignal.value.$3,
  );

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
