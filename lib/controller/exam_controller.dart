// Copyright 2026 Traintime PDA Authours, originally by BenderBlog Rodriguez.
// SPDX-License-Identifier: MPL-2.0

import 'dart:async';

import 'package:intl/intl.dart';
import 'package:signals/signals.dart';
import 'package:time/time.dart';
import 'package:watermeter/controller/global_timer_controller.dart';
import 'package:watermeter/controller/semester_controller.dart';
import 'package:watermeter/model/fetch_result.dart';
import 'package:watermeter/model/home_arrangement.dart';
import 'package:watermeter/model/xidian_ids/exam.dart';
import 'package:watermeter/repository/logger.dart';
import 'package:watermeter/repository/xidian_ids/exam_session.dart';

class ExamController {
  static final ExamController i = ExamController._();

  ExamController._() {
    final cache = ExamSession.getCache();
    if (cache != null) {
      _lastValidExamInfo.value = FetchResult.cache(
        fetchTime: cache.$1,
        data: cache.$2,
        hintKey: "local_cache_hint",
      );
    }
    _initEffects();
  }

  final examInfoSignal = futureSignal(
    () => getScoreInfo(SemesterController.i.semesterSignal.value),
    dependencies: [SemesterController.i.semesterSignal],
  );
  final _lastValidExamInfo = signal<FetchResult<ExamData>?>(null);
  SemesterSyncEvent? _lastHandledSemesterSyncEvent;

  void _initEffects() {
    effect(() {
      final state = examInfoSignal.value;
      if (state is AsyncData<FetchResult<ExamData>>) {
        _lastValidExamInfo.value = state.value;
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
        _lastValidExamInfo.value = null;
        ExamSession.deleteCache();
      }
      unawaited(reloadExamInfo());
    }, debugLabel: "ExamControllerSemesterChangeEffect");
  }

  Future<void> reloadExamInfo() async {
    if (examInfoSignal.value.isLoading) return;
    if (examInfoSignal.value is AsyncError) {
      examInfoSignal.reset();
    }
    return await examInfoSignal.reload().catchError(
      (e, s) => log.handle(e, s, "[ExamController][reloadExamInfo] Have issue"),
    );
  }

  late final subjects = computed(
    () => _lastValidExamInfo.value?.data.subject ?? <Subject>[],
  );

  late final toBeArranged = computed(
    () => _lastValidExamInfo.value?.data.toBeArranged ?? <ToBeArranged>[],
  );

  late final hasValidExamInfo = computed(
    () => _lastValidExamInfo.value != null,
  );

  late final isExamFromCache = computed(
    () => _lastValidExamInfo.value?.isCache ?? false,
  );

  late final examFetchTime = computed<DateTime?>(
    () => _lastValidExamInfo.value?.fetchTime,
  );

  late final examCacheHintKey = computed<String?>(
    () => _lastValidExamInfo.value?.hintKey,
  );

  late final hasExamArrangement = computed(
    () => subjects.value.isNotEmpty || toBeArranged.value.isNotEmpty,
  );

  late final isDisQualified = computed(() {
    return subjects.value
        .where((e) => e.startTime == null || e.stopTime == null)
        .toList();
  });

  late final isFinished = computed(() {
    final now = GlobalTimerController.i.currentTimeSignal.value;
    return subjects.value.where((e) {
      if (e.startTime == null) return false;
      return !e.startTime!.isAfter(now);
    }).toList();
  });

  late final isNotFinished = computed(() {
    final now = GlobalTimerController.i.currentTimeSignal.value;

    final list = subjects.value.where((e) {
      if (e.startTime == null) return false;
      return e.startTime!.isAfter(now);
    }).toList();

    return list..sort((a, b) => a.startTime!.compareTo(b.startTime!));
  });

  late final todayExams = computed<List<HomeArrangement>>(() {
    final now = GlobalTimerController.i.currentTimeSignal.value;
    final formatter = DateFormat(HomeArrangement.format);

    return subjects.value
        .where((e) => e.startTime?.isAtSameDayAs(now) ?? false)
        .map(
          (e) => HomeArrangement(
            name: "${e.subject}考试",
            place: e.place,
            seat: e.seat,
            startTimeStr: e.startTime != null
                ? formatter.format(e.startTime!)
                : e.startTimeStr,
            endTimeStr: e.stopTime != null
                ? formatter.format(e.stopTime!)
                : e.endTimeStr,
          ),
        )
        .toList();
  });

  late final tomorrowExams = computed<List<HomeArrangement>>(() {
    final now = GlobalTimerController.i.currentTimeSignal.value.add(
      const Duration(days: 1),
    );
    final formatter = DateFormat(HomeArrangement.format);

    return subjects.value
        .where((e) => e.startTime?.isAtSameDayAs(now) ?? false)
        .map(
          (e) => HomeArrangement(
            name: "${e.subject}考试",
            place: e.place,
            seat: e.seat,
            startTimeStr: e.startTime != null
                ? formatter.format(e.startTime!)
                : e.startTimeStr,
            endTimeStr: e.stopTime != null
                ? formatter.format(e.stopTime!)
                : e.endTimeStr,
          ),
        )
        .toList();
  });
}
