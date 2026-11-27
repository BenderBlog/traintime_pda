// Copyright 2026 Traintime PDA Authours, originally by BenderBlog Rodriguez.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/foundation.dart';
import 'package:signals/signals.dart';
import 'package:watermeter/controller/classtable_controller.dart';
import 'package:watermeter/controller/custom_class_controller.dart';
import 'package:watermeter/controller/exam_controller.dart';
import 'package:watermeter/controller/global_timer_controller.dart';
import 'package:watermeter/controller/other_experiment_controller.dart';
import 'package:watermeter/controller/physics_experiment_controller.dart';
import 'package:watermeter/controller/week_swift_controller.dart';
import 'package:watermeter/model/fetch_result.dart';
import 'package:watermeter/model/pda_service/custom_class.dart';
import 'package:watermeter/page/classtable/model/classtable_snapshot.dart';
import 'package:watermeter/page/classtable/model/classtable_source.dart';
import 'package:watermeter/repository/logger.dart';
import 'package:watermeter/repository/preference.dart' as preference;

/// The live class table: the app's controllers, read once per change and republished as a
/// [ClasstableSnapshot].
///
/// This is the only file under `page/classtable/` allowed to know that the controllers exist and
/// that they are built on `signals`. Everything above it speaks plain Dart and `ValueListenable`.
class GlobalClasstableDataSource implements ClasstableDataSource {
  GlobalClasstableDataSource() {
    _now = ValueNotifier<DateTime>(
      GlobalTimerController.i.currentTimeSignal.value,
    );
    _snapshot = ValueNotifier<ClasstableSnapshot>(_snapshotOf());
    _bind();
  }

  late final ValueNotifier<ClasstableSnapshot> _snapshot;
  late final ValueNotifier<DateTime> _now;
  final List<EffectCleanup> _cleanup = [];

  @override
  ValueListenable<ClasstableSnapshot> get snapshot => _snapshot;

  @override
  ValueListenable<DateTime> get now => _now;

  @override
  String get decorationFileName => ClassTableController.decorationName;

  void _bind() {
    /// 数据：一次读全，攒成一份快照。时钟另起一条，否则每分钟都会重算整份快照。
    _cleanup.add(
      effect(
        () {
          try {
            _snapshot.value = _snapshotOf();
          } catch (e, s) {
            // Half-loaded data must not take the page down with it: keep the previous snapshot.
            log.handle(e, s, "[GlobalClasstableDataSource][_bind]");
          }
        },
        options: const EffectOptions(
          name: "GlobalClasstableDataSourceDataEffect",
        ),
      ),
    );
    _cleanup.add(
      effect(
        () {
          _now.value = GlobalTimerController.i.currentTimeSignal.value;
        },
        options: const EffectOptions(
          name: "GlobalClasstableDataSourceClockEffect",
        ),
      ),
    );
  }

  ClasstableSnapshot _snapshotOf() {
    final ct = ClassTableController.i;
    final exam = ExamController.i;
    final phy = PhysicsExperimentController.i;
    final other = OtherExperimentController.i;

    return ClasstableSnapshot(
      classTableData: ct.classTableComputedSignal.value,
      classTable: _statusOf(
        ct.schoolClassTableStateSignal.value,
        isFromCache: ct.isClassTableFromCacheComputedSignal.value,
        cacheHint: ct.classTableCacheHintKeyComputedSignal.value,
      ),
      exam: _statusOf(
        exam.examInfoStateSignal.value,
        isFromCache: exam.isExamFromCache.value,
        cacheHint: exam.examCacheHintKey.value,
      ),
      physicsExperiment: _statusOf(
        phy.physicsExperimentStateSignal.value,
        isFromCache: phy.isPhysicsExperimentFromCache.value,
        cacheHint: phy.physicsExperimentCacheHintKey.value,
        hasArrangement: phy.hasPhysicsExperimentArrangement.value,
      ),
      otherExperiment: _statusOf(
        other.otherExperimentStateSignal.value,
        isFromCache: other.isOtherExperimentFromCache.value,
        cacheHint: other.otherExperimentCacheHintKey.value,
        hasArrangement: other.hasOtherExperimentArrangement.value,
      ),
      subjects: exam.subjects.value,
      experiments: [
        ...phy.physicsExperiments.value,
        ...other.otherExperiments.value,
      ],
      customClasses: CustomClassController.i.customClassesSignal.value,
      weekOffset: WeekSwiftController.i.weekSwiftSignal.value,
      hasExamArrangement: exam.hasExamArrangement.value,
      havePhysicsExperiment: ct.havePhysicsExperimentSignal.value,
      // 注意：这是 bool，不是 computed。
      haveOtherExperiment: ct.haveOtherExperimentSignal,
    );
  }

  ClassSourceStatus _statusOf<T>(
    AsyncState<FetchResult<T>> state, {
    required bool isFromCache,
    required CacheHint? cacheHint,
    bool hasArrangement = true,
  }) => ClassSourceStatus(
    isLoading: state.isLoading,
    hasError: state.hasError,
    isFromCache: isFromCache,
    cacheHint: cacheHint,
    hasArrangement: hasArrangement,
  );

  @override
  Future<void> refresh() => Future.wait([
    ClassTableController.i.reloadClassTable(),
    ExamController.i.reloadExamInfo(),
    if (!preference.getBool(preference.Preference.role)) ...[
      PhysicsExperimentController.i.reloadPhysicsExperiment(),
      OtherExperimentController.i.reloadOtherExperiment(),
    ],
  ]);

  @override
  Future<void> addCustomClass(CustomClass customClass) =>
      CustomClassController.i.addCustomClass(customClass);

  @override
  Future<void> editCustomClassById(
    String customClassId,
    CustomClass customClass,
  ) => CustomClassController.i.editCustomClassById(customClassId, customClass);

  @override
  Future<void> deleteCustomClassById(String customClassId) =>
      CustomClassController.i.deleteCustomClassById(customClassId);

  @override
  Future<void> deleteCustomClassTimeRange({
    required String customClassId,
    required String timeRangeId,
  }) => CustomClassController.i.deleteCustomClassTimeRange(
    customClassId: customClassId,
    timeRangeId: timeRangeId,
  );

  @override
  String newCustomClassId() => CustomClassController.i.generateCustomClassId();

  @override
  String newTimeRangeId() => CustomClassController.i.generateTimeRangeId();

  @override
  void dispose() {
    for (final cleanup in _cleanup) {
      cleanup();
    }
    _cleanup.clear();
    _snapshot.dispose();
    _now.dispose();
  }
}
