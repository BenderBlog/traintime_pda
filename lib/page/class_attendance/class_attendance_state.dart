// Copyright 2025 BenderBlog Rodriguez and contributors.
// Copyright 2025 Traintime PDA Authors
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/widgets.dart';
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
      courses = await LearningSession().getAttandanceRecord();
      classTimes = ClassTableController.i.numberOfClassComputedSignal.value;

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
    if (state != ClassAttendanceFetchState.ok &&
        state != ClassAttendanceFetchState.empty) {
      await _loadData();
      return;
    }

    try {
      final newCourses = await LearningSession().getAttandanceRecord();
      final newClassTimes =
          ClassTableController.i.numberOfClassComputedSignal.value;

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
