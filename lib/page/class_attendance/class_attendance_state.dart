// Copyright 2025 BenderBlog Rodriguez and contributors.
// Copyright 2025 Traintime PDA Authors
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:watermeter/controller/classtable_controller.dart';
import 'package:watermeter/model/xidian_ids/class_attendance.dart';
import 'package:watermeter/repository/logger.dart';
import 'package:watermeter/repository/xidian_ids/learning_session.dart';

enum ClassAttendanceFetchState { fetching, ok, error, empty }

class ClassAttendanceState extends ChangeNotifier {
  /// Hack on notifyListeners, do not fire when the widget is disposed.
  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_disposed) {
      super.notifyListeners();
    }
  }

  /// Fetch state.
  ClassAttendanceFetchState state = ClassAttendanceFetchState.fetching;

  /// Attendance data
  List<ClassAttendance> courses = [];
  Map<String, int> classTimes = {};

  /// Error info
  Object? error;
  StackTrace? stackTrace;

  /// Init
  ClassAttendanceState() {
    _loadData();
  }

  Future<void> _loadData() async {
    state = ClassAttendanceFetchState.fetching;
    notifyListeners();

    try {
      final controller = Get.put(ClassTableController());
      courses = await LearningSession().getAttandanceRecord();
      classTimes = controller.numberOfClass;

      if (courses.isEmpty) {
        state = ClassAttendanceFetchState.empty;
      } else {
        state = ClassAttendanceFetchState.ok;
      }
      error = null;
      stackTrace = null;
    } catch (e, s) {
      log.error("[ClassAttendanceState] Error on fetching attendance.", e, s);
      state = ClassAttendanceFetchState.error;
      error = e;
      stackTrace = s;
    } finally {
      log.info("[ClassAttendanceState] Finish fetching. state: $state");
      notifyListeners();
    }
  }

  /// Refresh data without losing current data during loading
  Future<void> refreshData() async {
    // 如果当前状态不是 ok 或 empty，则直接重新加载
    if (state != ClassAttendanceFetchState.ok &&
        state != ClassAttendanceFetchState.empty) {
      await _loadData();
      return;
    }

    // 保留当前数据，在后台刷新
    try {
      final controller = Get.put(ClassTableController());
      final newCourses = await LearningSession().getAttandanceRecord();
      final newClassTimes = controller.numberOfClass;

      courses = newCourses;
      classTimes = newClassTimes;

      if (courses.isEmpty) {
        state = ClassAttendanceFetchState.empty;
      } else {
        state = ClassAttendanceFetchState.ok;
      }
      error = null;
      stackTrace = null;
    } catch (e, s) {
      log.error("[ClassAttendanceState] Error on refreshing attendance.", e, s);
      // 刷新失败时保留原有数据，不改变状态
      // 但如果原来就没有数据，则显示错误
      if (courses.isEmpty) {
        state = ClassAttendanceFetchState.error;
        error = e;
        stackTrace = s;
      }
    } finally {
      log.info("[ClassAttendanceState] Finish refreshing. state: $state");
      notifyListeners();
    }
  }
}
