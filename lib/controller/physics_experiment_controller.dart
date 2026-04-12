// Copyright 2026 Traintime PDA Authours, originally by BenderBlog Rodriguez.
// SPDX-License-Identifier: MPL-2.0

import 'dart:async';

import 'package:intl/intl.dart';
import 'package:signals/signals_flutter.dart';
import 'package:time/time.dart';
import 'package:watermeter/controller/global_timer_controller.dart';
import 'package:watermeter/controller/semester_controller.dart';
import 'package:watermeter/model/fetch_result.dart';
import 'package:watermeter/model/home_arrangement.dart';
import 'package:watermeter/model/xidian_ids/experiment.dart';
import 'package:watermeter/repository/logger.dart';
import 'package:watermeter/repository/preference.dart' as pref;
import 'package:watermeter/repository/physics_experiment_session.dart';

class PhysicsExperimentController {
  static final PhysicsExperimentController i = PhysicsExperimentController._();

  PhysicsExperimentController._() {
    /// Load from cache at the beginning
    final cache = ExperimentSession.getCache();
    if (cache != null) {
      _lastValidPhysicsExperiment.value = FetchResult.cache(
        fetchTime: cache.$1,
        data: cache.$2,
        hintKey: "local_cache_hint",
      );
    }
    _initEffects();
  }

  final physicsExperimentSignal = futureSignal(
    () => getPhysicsExperimentData(),
  );

  final _lastValidPhysicsExperiment =
      signal<FetchResult<List<ExperimentData>>?>(null);
  SemesterSyncEvent? _lastHandledSemesterSyncEvent;

  void _initEffects() {
    effect(() {
      final state = physicsExperimentSignal.value;
      if (state is AsyncData<FetchResult<List<ExperimentData>>>) {
        _lastValidPhysicsExperiment.value = state.value;
      }
    }, debugLabel: "ExamControllerShadowSyncEffect");

    effect(() {
      final semesterChangeEvent =
          SemesterController.i.semesterSyncEventSignal.value;
      if (semesterChangeEvent == null ||
          identical(semesterChangeEvent, _lastHandledSemesterSyncEvent)) {
        return;
      }

      _lastHandledSemesterSyncEvent = semesterChangeEvent;
      if (semesterChangeEvent.didChange) {
        _lastValidPhysicsExperiment.value = null;
        unawaited(
          Future(() async {
            ExperimentSession.deleteCache();
            await pref.remove(pref.Preference.experimentPassword);
          }),
        );
        return;
      }
      unawaited(reloadPhysicsExperiment());
    }, debugLabel: "PhysicsExperimentSemesterChangeEffect");
  }

  Future<void> reloadPhysicsExperiment() async {
    if (physicsExperimentSignal.value.isLoading) return;
    await physicsExperimentSignal.reload().catchError(
      (e, s) => log.handle(
        e,
        s,
        "[PhysicsExperimentController][reloadPhysicsExperiment] Have issue",
      ),
    );
  }

  late final physicsExperiments = computed(
    () => _lastValidPhysicsExperiment.value?.data ?? <ExperimentData>[],
  );

  late final hasValidPhysicsExperiment = computed(
    () => _lastValidPhysicsExperiment.value != null,
  );

  late final isPhysicsExperimentFromCache = computed(
    () => _lastValidPhysicsExperiment.value?.isCache ?? false,
  );

  late final physicsExperimentFetchTime = computed<DateTime?>(
    () => _lastValidPhysicsExperiment.value?.fetchTime,
  );

  late final physicsExperimentCacheHintKey = computed<String?>(
    () => _lastValidPhysicsExperiment.value?.hintKey,
  );

  late final physicsExperimentOfTodayComputedSignal = computed(() {
    final now = GlobalTimerController.i.currentTimeSignal.value;
    DateFormat formatter = DateFormat(HomeArrangement.format);
    List<HomeArrangement> toReturn = [];

    for (final experiment in physicsExperiments.value) {
      for (final timeRange in experiment.timeRanges) {
        if (!timeRange.$1.isAtSameDayAs(now)) continue;
        toReturn.add(
          HomeArrangement(
            name: experiment.name,
            place: experiment.classroom,
            teacher: experiment.teacher,
            startTimeStr: formatter.format(timeRange.$1),
            endTimeStr: formatter.format(timeRange.$2),
          ),
        );
      }
    }

    return toReturn;
  });

  late final physicsExperimentOfTomorrowComputedSignal = computed(() {
    final now = GlobalTimerController.i.currentTimeSignal.value.add(1.days);
    DateFormat formatter = DateFormat(HomeArrangement.format);
    List<HomeArrangement> toReturn = [];

    for (final experiment in physicsExperiments.value) {
      for (final timeRange in experiment.timeRanges) {
        if (!timeRange.$1.isAtSameDayAs(now)) continue;
        toReturn.add(
          HomeArrangement(
            name: experiment.name,
            place: experiment.classroom,
            teacher: experiment.teacher,
            startTimeStr: formatter.format(timeRange.$1),
            endTimeStr: formatter.format(timeRange.$2),
          ),
        );
      }
    }

    return toReturn;
  });

  late final isFinishedPhysicsExperimentComputedSignal = computed(() {
    final now = GlobalTimerController.i.currentTimeSignal.value.add(1.days);
    List<ExperimentData> toReturn = [];

    bool isQualified((DateTime, DateTime) timeRange) =>
        now.isAfter(timeRange.$2);

    for (var experiment in physicsExperiments.value) {
      bool containsDoing = experiment.timeRanges.where(isQualified).isNotEmpty;
      if (!containsDoing) continue;
      ExperimentData toAdd = ExperimentData.from(experiment);
      toAdd.timeRanges.removeWhere((timeRange) => !isQualified(timeRange));
      toReturn.add(toAdd);
    }

    return toReturn;
  });

  late final isNotStartedPhysicsExperimentComputedSignal = computed(() {
    final now = GlobalTimerController.i.currentTimeSignal.value.add(1.days);
    List<ExperimentData> toReturn = [];

    bool isQualified((DateTime, DateTime) timeRange) =>
        now.isBefore(timeRange.$1);

    for (var experiment in physicsExperiments.value) {
      bool containsDoing = experiment.timeRanges.where(isQualified).isNotEmpty;
      if (!containsDoing) continue;
      ExperimentData toAdd = ExperimentData.from(experiment);
      toAdd.timeRanges.removeWhere((timeRange) => !isQualified(timeRange));
      toReturn.add(toAdd);
    }

    return toReturn;
  });

  late final isDoingPhysicsExperimentComputedSignal = computed(() {
    final now = GlobalTimerController.i.currentTimeSignal.value.add(1.days);
    List<ExperimentData> toReturn = [];

    bool isQualified((DateTime, DateTime) timeRange) =>
        now.isAfter(timeRange.$1) && now.isBefore(timeRange.$2);

    for (var experiment in physicsExperiments.value) {
      bool containsDoing = experiment.timeRanges.where(isQualified).isNotEmpty;
      if (!containsDoing) continue;
      ExperimentData toAdd = ExperimentData.from(experiment);
      toAdd.timeRanges.removeWhere((timeRange) => !isQualified(timeRange));
      toReturn.add(toAdd);
    }

    return toReturn;
  });
}
