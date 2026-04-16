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
import 'package:watermeter/repository/xidian_ids/sysj_session.dart';

class OtherExperimentController {
  static final OtherExperimentController i = OtherExperimentController._();
  bool _isReloading = false;

  OtherExperimentController._() {
    /// Load from cache at the beginning
    final cache = SysjSession.getCache();
    if (cache != null) {
      final cached = FetchResult.cache(fetchTime: cache.$1, data: cache.$2);
      _lastValidOtherExperiment.value = cached;
      otherExperimentStateSignal.value = AsyncState.data(cached);
    }
    _initEffects();
  }

  final _lastValidOtherExperiment = signal<FetchResult<List<ExperimentData>>?>(
    null,
  );
  final otherExperimentStateSignal =
      signal<AsyncState<FetchResult<List<ExperimentData>>>>(
        const AsyncLoading(),
      );
  SemesterSyncEvent? _lastHandledSemesterSyncEvent;

  void _initEffects() {
    effect(() {
      final semesterChangeEvent =
          SemesterController.i.semesterSyncEventSignal.value;
      if (semesterChangeEvent == null ||
          identical(semesterChangeEvent, _lastHandledSemesterSyncEvent)) {
        return;
      }

      _lastHandledSemesterSyncEvent = semesterChangeEvent;
      if (semesterChangeEvent.didChange) {
        _lastValidOtherExperiment.value = null;
        SysjSession.deleteCache();
      }
      unawaited(reloadOtherExperiment());
    }, debugLabel: "OtherExperimentSemesterChangeEffect");
  }

  Future<void> reloadOtherExperiment() async {
    if (_isReloading) return;
    _isReloading = true;
    final previous = _lastValidOtherExperiment.value;
    otherExperimentStateSignal.value = previous != null
        ? AsyncState.dataRefreshing(previous)
        : AsyncState.loading();
    try {
      final result = await getOtherExperimentData();
      _lastValidOtherExperiment.value = result;
      otherExperimentStateSignal.value = AsyncState.data(result);
    } catch (e, s) {
      otherExperimentStateSignal.value = AsyncState.error(e, s);
      log.handle(
        e,
        s,
        "[OtherExperimentController][reloadOtherExperiment] Have issue",
      );
    } finally {
      _isReloading = false;
    }
  }

  late final otherExperiments = computed(
    () => _lastValidOtherExperiment.value?.data ?? <ExperimentData>[],
  );

  late final hasValidOtherExperiment = computed(
    () => _lastValidOtherExperiment.value != null,
  );

  late final isOtherExperimentFromCache = computed(
    () => _lastValidOtherExperiment.value?.isCache ?? false,
  );

  late final otherExperimentFetchTime = computed<DateTime?>(
    () => _lastValidOtherExperiment.value?.fetchTime,
  );

  late final otherExperimentCacheHintKey = computed<String?>(
    () => _lastValidOtherExperiment.value?.hintKey,
  );

  late final hasOtherExperimentArrangement = computed(
    () => otherExperiments.value.isNotEmpty,
  );

  late final otherExperimentOfTodayComputedSignal = computed(() {
    final now = GlobalTimerController.i.currentTimeSignal.value;
    DateFormat formatter = DateFormat(HomeArrangement.format);
    List<HomeArrangement> toReturn = [];

    for (final experiment in otherExperiments.value) {
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

  late final otherExperimentOfTomorrowComputedSignal = computed(() {
    final now = GlobalTimerController.i.currentTimeSignal.value.add(1.days);
    DateFormat formatter = DateFormat(HomeArrangement.format);
    List<HomeArrangement> toReturn = [];

    for (final experiment in otherExperiments.value) {
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

  late final isFinishedOtherExperimentComputedSignal = computed(() {
    final now = GlobalTimerController.i.currentTimeSignal.value.add(1.days);
    List<ExperimentData> toReturn = [];

    bool isQualified((DateTime, DateTime) timeRange) =>
        now.isAfter(timeRange.$2);

    for (var experiment in otherExperiments.value) {
      bool containsDoing = experiment.timeRanges.where(isQualified).isNotEmpty;
      if (!containsDoing) continue;
      ExperimentData toAdd = ExperimentData.from(experiment);
      toAdd.timeRanges.removeWhere((timeRange) => !isQualified(timeRange));
      toReturn.add(toAdd);
    }
    return toReturn;
  });

  late final isNotStartedOtherExperimentComputedSignal = computed(() {
    final now = GlobalTimerController.i.currentTimeSignal.value.add(1.days);
    List<ExperimentData> toReturn = [];

    bool isQualified((DateTime, DateTime) timeRange) =>
        now.isBefore(timeRange.$1);

    for (var experiment in otherExperiments.value) {
      bool containsDoing = experiment.timeRanges.where(isQualified).isNotEmpty;
      if (!containsDoing) continue;
      ExperimentData toAdd = ExperimentData.from(experiment);
      toAdd.timeRanges.removeWhere((timeRange) => !isQualified(timeRange));
      toReturn.add(toAdd);
    }

    return toReturn;
  });

  late final isDoingOtherExperimentComputedSignal = computed(() {
    final now = GlobalTimerController.i.currentTimeSignal.value.add(1.days);
    List<ExperimentData> toReturn = [];

    bool isQualified((DateTime, DateTime) timeRange) =>
        now.isAfter(timeRange.$1) && now.isBefore(timeRange.$2);

    for (var experiment in otherExperiments.value) {
      bool containsDoing = experiment.timeRanges.where(isQualified).isNotEmpty;
      if (!containsDoing) continue;
      ExperimentData toAdd = ExperimentData.from(experiment);
      toAdd.timeRanges.removeWhere((timeRange) => !isQualified(timeRange));
      toReturn.add(toAdd);
    }

    return toReturn;
  });
}
