// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'dart:io';

import 'package:get_it/get_it.dart';
import 'package:watermeter/controller/classtable_controller.dart';
import 'package:watermeter/controller/exam_controller.dart';
import 'package:watermeter/controller/other_experiment_controller.dart';
import 'package:watermeter/controller/physics_experiment_controller.dart';
import 'package:watermeter/controller/schedule_snapshot_controller.dart';
import 'package:watermeter/controller/theme_controller.dart';
import 'package:watermeter/external/ruisi_flutter/controller/ruisi_controller.dart';
import 'package:watermeter/model/xidian_ids/classtable.dart';
import 'package:watermeter/repository/network_session.dart';
import 'package:watermeter/repository/physics_experiment_session.dart';
import 'package:watermeter/repository/preference.dart' as preference;
import 'package:watermeter/repository/user_defined_class_file.dart';
import 'package:watermeter/repository/widget_state_sync.dart';
import 'package:watermeter/repository/xidian_ids/classtable_session.dart';
import 'package:watermeter/repository/xidian_ids/energy_session.dart';
import 'package:watermeter/repository/xidian_ids/exam_session.dart';
import 'package:watermeter/repository/xidian_ids/score_session.dart';
import 'package:watermeter/repository/xidian_ids/sysj_session.dart';
import 'package:watermeter/repository/xidian_sport_session.dart';

class SettingActionsController {
  const SettingActionsController();

  bool get isSemesterAwareControllerLoading =>
      ClassTableController.i.schoolClassTableStateSignal.value.isLoading ||
      ExamController.i.examInfoStateSignal.value.isLoading ||
      PhysicsExperimentController
          .i
          .physicsExperimentStateSignal
          .value
          .isLoading ||
      OtherExperimentController.i.otherExperimentStateSignal.value.isLoading;

  Future<void> waitForSemesterAwareReloads() async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    final stopwatch = Stopwatch()..start();
    while (isSemesterAwareControllerLoading &&
        stopwatch.elapsed < const Duration(seconds: 30)) {
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }
  }

  Future<void> refreshSemesterAwareData() async {
    await Future.wait([
      ClassTableController.i.reloadClassTable(),
      ExamController.i.reloadExamInfo(),
      PhysicsExperimentController.i.reloadPhysicsExperiment(),
      OtherExperimentController.i.reloadOtherExperiment(),
    ]);
    await maybeAutoSyncSystemCalendar();
  }

  Future<void> autoSyncSystemCalendarIfNeeded() =>
      maybeAutoSyncSystemCalendar();

  void clearUserDefinedClasses() {
    UserDefinedClassFile.clearUserDefinedClass();
    ClassTableController.i.userDefinedClassSignal.value =
        UserDefinedClassData.empty();
  }

  Future<void> clearAppCache() async {
    await _clearCookieState();
    EnergySession.clearCache();
    EnergySession.clearElectricityHistory();
    _deleteSupportFiles([
      ClassTableSession.schoolClassName,
      ExamSession.examDataCacheName,
      ExperimentSession.physicsExperimentCacheName,
      SysjSession.otherExperimentCacheName,
      ScoreSession.scoreListCacheName,
    ]);
  }

  Future<void> logoutAndClearLocalState() async {
    await _clearCookieState();
    EnergySession.clearCache();
    EnergySession.clearElectricityHistory();
    _deleteSupportFiles([
      ClassTableSession.schoolClassName,
      UserDefinedClassFile.userDefinedClassName,
      ClassTableController.decorationName,
      ExamSession.examDataCacheName,
      ExperimentSession.physicsExperimentCacheName,
      SysjSession.otherExperimentCacheName,
      ScoreSession.scoreListCacheName,
    ]);

    await GetIt.instance<RuisiService>().logout();
    await preference.prefrenceClear();
    ThemeController.i.updateTheme();
    await syncWidgetLoginState(false);
    await clearWidgetFiles();
  }

  Future<void> _clearCookieState() async {
    try {
      await NetworkSession().clearCookieJar();
      // ignore: empty_catches
    } on Exception {}

    try {
      await SportSession().sportCookieJar.deleteAll();
      // ignore: empty_catches
    } on Exception {}
  }

  void _deleteSupportFiles(List<String> fileNames) {
    for (final value in fileNames) {
      final file = File("${supportPath.path}/$value");
      if (file.existsSync()) {
        file.deleteSync();
      }
    }
  }
}
