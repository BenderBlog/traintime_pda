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
import 'package:watermeter/controller/theme_controller.dart';
import 'package:watermeter/model/pda_service/custom_class.dart';
import 'package:watermeter/model/xidian_ids/classtable.dart';
import 'package:watermeter/model/xidian_ids/exam.dart';
import 'package:watermeter/model/xidian_ids/experiment.dart';
import 'package:watermeter/repository/logger.dart';
import 'package:watermeter/repository/preference.dart' as preference;
import 'package:watermeter/repository/watch/watch_schedule_snapshot.dart';

/// 某一时刻从各个 Controller 读取到的完整同步输入。
///
/// 在 Signal effect 中一次读取同步输入并固定列表成员；源模型仍由
/// Controller 持有，后续依赖变化通过 generation 废弃待发送任务。
final class _WatchScheduleSourceState {
  const _WatchScheduleSourceState({
    required this.classTable,
    required this.effectiveTermStart,
    required this.currentWeekIndex,
    required this.customClasses,
    required this.subjects,
    required this.experiments,
    required this.reminderMinutes,
  });

  final ClassTableData classTable;
  final DateTime? effectiveTermStart;
  final int currentWeekIndex;
  final List<CustomClass> customClasses;
  final List<Subject> subjects;
  final List<ExperimentData> experiments;
  final int reminderMinutes;
}

/// 将手机端最新课表持续同步给配对 Apple Watch。
///
/// 服务只在 iOS 启动，通过 Signals 监听所有相关数据源。变化会先经过短暂
/// 防抖，再生成完整学期快照交给原生 WatchConnectivity 层。
class WatchScheduleSyncService {
  WatchScheduleSyncService._();

  static final WatchScheduleSyncService instance = WatchScheduleSyncService._();

  static const _debounceDuration = Duration(milliseconds: 400);
  static const _defaultReminderMinutes = 5;

  final WatchScheduleSnapshotBuilder _builder =
      const WatchScheduleSnapshotBuilder();
  final WatchSyncSwiftApi _api = WatchSyncSwiftApi();

  Timer? _debounce;
  bool _started = false;
  bool _suspended = false;
  /// 清空课表时递增；首页刷新只可恢复它启动时所见的同一登录会话。
  int _sessionRevision = 0;
  int get sessionRevision => _sessionRevision;
  /// 课表、语言和清空共用此链，失败会被隔离，不会阻塞后续写入。
  Future<void> _pendingWrite = Future.value();

  /// 每次数据源变化都会递增；旧定时任务和旧构建任务会主动放弃发送。
  int _generation = 0;
  int _languageGeneration = 0;
  String? _lastSyncedLanguage;

  /// 幂等启动监听。非 iOS 平台不会创建任何 Effect 或原生通道调用。
  void start() {
    if (!_shouldStart()) return;
    _started = true;
    if (preference.getString(preference.Preference.idsAccount).isEmpty ||
        preference.getString(preference.Preference.idsPassword).isEmpty) {
      unawaited(clear(signedOut: true));
    }
    _startReactiveSync();
  }

  /// 主动清空手机和手表端课表。
  ///
  /// 递增代次并取消防抖，防止排队中的旧快照在清空后重新写回。
  Future<void> clear({bool signedOut = false}) async {
    if (!Platform.isIOS) return;
    _suspended = true;
    _sessionRevision += 1;
    _debounce?.cancel();
    final generation = _nextGeneration();
    await _enqueueClear(generation, signedOut: signedOut);
  }

  /// 数据重新就绪后恢复同步；登录前或退出前启动的旧刷新不能解除暂停。
  void resume({required int sessionRevision}) {
    if (!Platform.isIOS || sessionRevision != _sessionRevision) return;
    if (!_started) start();
    if (sessionRevision != _sessionRevision) return;
    if (!_suspended) return;
    _suspended = false;
    _scheduleUpdate(_readSourceState());
  }

  /// 判断服务是否允许启动。
  bool _shouldStart() {
    return !_started && Platform.isIOS;
  }

  /// 创建 Signals effect；读取行为必须发生在 effect 回调内才能建立依赖。
  void _startReactiveSync() {
    // 语言独立于课表和登录状态；退出后仍能同步语言，也不会为语言变化重建学期。
    effect(() {
      final locale = ThemeController.i.localeIdentifierSignal.value;
      final generation = ++_languageGeneration;
      unawaited(_syncPreferredLanguageIfCurrent(locale, generation));
    }, options: EffectOptions(name: 'WatchPreferredLanguageSyncEffect'));
    effect(() {
      final state = _readSourceState();
      _scheduleUpdate(state);
    }, options: EffectOptions(name: 'WatchScheduleSyncEffect'));
  }

  /// 从各个 Controller 读取同一轮同步需要的全部数据。
  _WatchScheduleSourceState _readSourceState() {
    final classTableController = ClassTableController.i;
    final configuredMinutes = preference.getInt(
      preference.Preference.courseReminderMinutesBefore,
    );

    return _WatchScheduleSourceState(
      classTable: classTableController.classTableComputedSignal.value,
      effectiveTermStart: classTableController.startDayComputedSignal.value,
      currentWeekIndex: classTableController.currentWeekComputedSignal.value,
      customClasses: List.unmodifiable(
        CustomClassController.i.customClassesSignal.value,
      ),
      subjects: List.unmodifiable(ExamController.i.subjects.value),
      experiments: List.unmodifiable([
        ...PhysicsExperimentController.i.physicsExperiments.value,
        ...OtherExperimentController.i.otherExperiments.value,
      ]),
      reminderMinutes: _normalizedReminderMinutes(configuredMinutes),
    );
  }

  /// 替换上一轮防抖任务，只保留最新数据状态。
  void _scheduleUpdate(_WatchScheduleSourceState state) {
    if (_suspended) return;
    _debounce?.cancel();
    final generation = _nextGeneration();
    _debounce = Timer(
      _debounceDuration,
      () => _runScheduledUpdate(state, generation),
    );
  }

  /// 定时器到期后再次检查代次，避免已经过期的闭包继续工作。
  void _runScheduledUpdate(_WatchScheduleSourceState state, int generation) {
    if (!_isCurrentGeneration(generation)) return;
    unawaited(_performScheduledUpdate(state, generation));
  }

  /// 课表只响应数据变化；语言通过独立 effect 和同一写入队列同步。
  Future<void> _performScheduledUpdate(
    _WatchScheduleSourceState state,
    int generation,
  ) async {
    if (!_isCurrentGeneration(generation)) return;

    final termStart = state.effectiveTermStart;
    // 初始化和临时获取失败不具有删除语义；只在用户明确清理/退出时发送清除。
    if (termStart == null) return;
    await _sync(
      state: state,
      effectiveTermStart: termStart,
      generation: generation,
    );
  }

  /// 把手机当前实际语言代码发送到原生 WatchConnectivity 层。
  Future<void> _syncPreferredLanguageIfCurrent(
    String localeIdentifier,
    int generation,
  ) async {
    if (generation != _languageGeneration) return;

    try {
      await _serializeWrite(() async {
        if (generation != _languageGeneration) return false;
        // 到实际执行时再去重，避免快速 A→B→A 时跳过正在发送的 B 后面的 A。
        if (localeIdentifier == _lastSyncedLanguage) return true;
        final accepted = await _api.syncPreferredLanguage(localeIdentifier);
        if (accepted) _lastSyncedLanguage = localeIdentifier;
        return accepted;
      });
    } catch (error, stackTrace) {
      if (generation != _languageGeneration) return;
      log.handle(
        error,
        stackTrace,
        '[WatchScheduleSyncService] Failed to sync preferred language',
      );
    }
  }

  /// 构建并发送完整学期快照。
  ///
  /// 构建完成后再次校验代次；如果构建期间数据源又变化，本轮结果会被丢弃。
  Future<void> _sync({
    required _WatchScheduleSourceState state,
    required DateTime effectiveTermStart,
    required int generation,
  }) async {
    try {
      final snapshot = _buildSnapshot(
        state: state,
        effectiveTermStart: effectiveTermStart,
      );
      if (!_isCurrentGeneration(generation)) return;

      final accepted = await _sendSnapshot(snapshot, generation);
      if (!_isCurrentGeneration(generation)) return;
      _logSuccessfulSync(snapshot: snapshot, accepted: accepted);
    } catch (error, stackTrace) {
      if (!_isCurrentGeneration(generation)) return;
      _logSyncFailure(error, stackTrace);
    }
  }

  /// 使用捕获的数据源状态创建完整学期快照。
  WatchScheduleSnapshot _buildSnapshot({
    required _WatchScheduleSourceState state,
    required DateTime effectiveTermStart,
  }) {
    return _builder.build(
      classTable: state.classTable,
      effectiveTermStart: effectiveTermStart,
      currentWeekIndex: state.currentWeekIndex,
      now: DateTime.now(),
      customClasses: state.customClasses,
      subjects: state.subjects,
      experiments: state.experiments,
      rangeStart: effectiveTermStart,
      days: state.classTable.semesterLength * DateTime.daysPerWeek,
      reminderMinutes: state.reminderMinutes,
    );
  }

  /// 通过 Pigeon 调用原生 Swift 层。
  Future<bool> _sendSnapshot(WatchScheduleSnapshot snapshot, int generation) {
    return _serializeWrite(() async {
      if (!_isCurrentGeneration(generation)) return false;
      return _api.syncSchedule(WatchSchedulePayload(json: snapshot.encode()));
    });
  }

  // 跨 Pigeon 通道串行写入，清理必须排在已经发出的旧同步之后。
  Future<T> _serializeWrite<T>(Future<T> Function() write) {
    final result = _pendingWrite.then((_) => write());
    _pendingWrite = result.then<void>(
      (_) {},
      onError: (Object _, StackTrace _) {},
    );
    return result;
  }

  /// 清空一旦入队便必须执行，作为旧账户快照与后续恢复同步之间的屏障。
  /// 不能在队列实际执行时再次按 generation 跳过它，否则 resume 发出的新
  /// 快照可能沿用旧账户代次；快照和语言更新则可以直接丢弃被替代的任务。
  Future<void> _enqueueClear(
    int generation, {
    required bool signedOut,
  }) async {
    if (!_isCurrentGeneration(generation)) return;

    try {
      await _serializeWrite(() => _api.clearSchedule(signedOut));
    } catch (error, stackTrace) {
      if (!_isCurrentGeneration(generation)) return;
      log.handle(
        error,
        stackTrace,
        '[WatchScheduleSyncService] Failed to clear schedule',
      );
    }
  }

  /// 用户配置非正数时使用默认提前提醒分钟数。
  int _normalizedReminderMinutes(int configuredMinutes) {
    return configuredMinutes > 0 ? configuredMinutes : _defaultReminderMinutes;
  }

  /// 生成并返回新代次。
  int _nextGeneration() {
    _generation += 1;
    return _generation;
  }

  /// 判断异步任务是否仍代表最新数据状态。
  bool _isCurrentGeneration(int generation) {
    return generation == _generation;
  }

  /// 记录成功同步的数量和原生接收状态。
  void _logSuccessfulSync({
    required WatchScheduleSnapshot snapshot,
    required bool accepted,
  }) {
    log.info(
      '[WatchScheduleSyncService] Sent full semester with '
      '${snapshot.courses.length} courses; accepted=$accepted',
    );
  }

  /// 统一记录构建或发送失败。
  void _logSyncFailure(Object error, StackTrace stackTrace) {
    log.handle(
      error,
      stackTrace,
      '[WatchScheduleSyncService] Failed to sync schedule',
    );
  }
}
