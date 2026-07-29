// Copyright 2026 Traintime PDA Authors.
// SPDX-License-Identifier: MPL-2.0

import 'dart:async';
import 'dart:io';

import 'package:signals/signals.dart';
import 'package:watermeter/bridge/save_to_groupid.g.dart';
import 'package:watermeter/controller/classtable_controller.dart';
import 'package:watermeter/controller/custom_class_controller.dart';
import 'package:watermeter/controller/exam_controller.dart';
import 'package:watermeter/controller/other_experiment_controller.dart';
import 'package:watermeter/controller/physics_experiment_controller.dart';
import 'package:watermeter/model/pda_service/custom_class.dart';
import 'package:watermeter/model/xidian_ids/classtable.dart';
import 'package:watermeter/model/xidian_ids/exam.dart';
import 'package:watermeter/model/xidian_ids/experiment.dart';
import 'package:watermeter/repository/logger.dart';
import 'package:watermeter/repository/preference.dart' as preference;
import 'package:watermeter/repository/watch/watch_schedule_snapshot.dart';

/// Keeps the paired Apple Watch updated with a complete semester schedule.
class WatchScheduleSyncService {
  WatchScheduleSyncService._();

  static final WatchScheduleSyncService instance = WatchScheduleSyncService._();

  final WatchScheduleSnapshotBuilder _builder =
      const WatchScheduleSnapshotBuilder();
  final WatchSyncSwiftApi _api = WatchSyncSwiftApi();
  Timer? _debounce;
  bool _started = false;

  void start() {
    if (_started || !Platform.isIOS) return;
    _started = true;

    effect(() {
      final controller = ClassTableController.i;
      final classTable = controller.classTableComputedSignal.value;
      final effectiveTermStart = controller.startDayComputedSignal.value;
      final currentWeekIndex = controller.currentWeekComputedSignal.value;
      final customClasses = CustomClassController.i.customClassesSignal.value;
      final subjects = ExamController.i.subjects.value;
      final experiments = <ExperimentData>[
        ...PhysicsExperimentController.i.physicsExperiments.value,
        ...OtherExperimentController.i.otherExperiments.value,
      ];
      final configuredMinutes = preference.getInt(
        preference.Preference.courseReminderMinutesBefore,
      );

      _debounce?.cancel();
      _debounce = Timer(const Duration(milliseconds: 400), () {
        if (effectiveTermStart == null) {
          unawaited(clear());
          return;
        }
        unawaited(
          _sync(
            classTable: classTable,
            effectiveTermStart: effectiveTermStart,
            currentWeekIndex: currentWeekIndex,
            customClasses: customClasses,
            subjects: subjects,
            experiments: experiments,
            reminderMinutes: configuredMinutes > 0 ? configuredMinutes : 5,
          ),
        );
      });
    }, options: EffectOptions(name: 'WatchScheduleSyncEffect'));
  }

  Future<void> _sync({
    required ClassTableData classTable,
    required DateTime effectiveTermStart,
    required int currentWeekIndex,
    required List<CustomClass> customClasses,
    required List<Subject> subjects,
    required List<ExperimentData> experiments,
    required int reminderMinutes,
  }) async {
    try {
      final snapshot = _builder.build(
        classTable: classTable,
        effectiveTermStart: effectiveTermStart,
        currentWeekIndex: currentWeekIndex,
        now: DateTime.now(),
        customClasses: customClasses,
        subjects: subjects,
        experiments: experiments,
        rangeStart: effectiveTermStart,
        days: classTable.semesterLength * DateTime.daysPerWeek,
        reminderMinutes: reminderMinutes,
      );
      final accepted = await _api.syncSchedule(
        WatchSchedulePayload(json: snapshot.encode()),
      );
      log.info(
        '[WatchScheduleSyncService] Sent full semester with '
        '${snapshot.courses.length} courses; accepted=$accepted',
      );
    } catch (error, stackTrace) {
      log.handle(
        error,
        stackTrace,
        '[WatchScheduleSyncService] Failed to sync schedule',
      );
    }
  }

  Future<void> clear() async {
    if (!Platform.isIOS) return;
    try {
      await _api.clearSchedule();
    } catch (error, stackTrace) {
      log.handle(
        error,
        stackTrace,
        '[WatchScheduleSyncService] Failed to clear schedule',
      );
    }
  }
}
