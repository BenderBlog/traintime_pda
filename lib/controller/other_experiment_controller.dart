// Copyright 2026 Traintime PDA Authours, originally by BenderBlog Rodriguez.
// SPDX-License-Identifier: MPL-2.0

import 'package:intl/intl.dart';
import 'package:signals/signals_flutter.dart';
import 'package:time/time.dart';
import 'package:watermeter/controller/global_timer_controller.dart';
import 'package:watermeter/model/fetch_result.dart';
import 'package:watermeter/model/home_arrangement.dart';
import 'package:watermeter/model/xidian_ids/experiment.dart';
import 'package:watermeter/repository/logger.dart';
import 'package:watermeter/repository/xidian_ids/sysj_session.dart';

class OtherExperimentController {
  static final OtherExperimentController i = OtherExperimentController._();

  OtherExperimentController._() {
    /// Load from cache at the beginning
    final cache = SysjSession.getCache();
    if (cache != null) {
      _lastValidOtherExperiment.value = FetchResult.cache(
        fetchTime: cache.$1,
        data: cache.$2,
        hintKey: "local_cache_hint",
      );
    }
    _initEffects();
  }

  final otherExperimentSignal = futureSignal(() => getOtherExperimentData());

  final _lastValidOtherExperiment = signal<FetchResult<List<ExperimentData>>?>(
    null,
  );

  void _initEffects() {
    effect(() {
      final state = otherExperimentSignal.value;
      if (state is AsyncData<FetchResult<List<ExperimentData>>>) {
        _lastValidOtherExperiment.value = state.value;
      }
    }, debugLabel: "ExamControllerShadowSyncEffect");
  }

  Future<void> reloadOtherExperiment() async {
    if (otherExperimentSignal.value.isLoading) return;
    await otherExperimentSignal.reload().catchError(
      (e, s) => log.handle(
        e,
        s,
        "[OtherExperimentController][reloadOtherExperiment] Have issue",
      ),
    );
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
