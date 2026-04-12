// Copyright 2026 Traintime PDA Authours, originally by BenderBlog Rodriguez.
// SPDX-License-Identifier: MPL-2.0

import 'package:signals/signals.dart';
import 'package:watermeter/controller/classtable_controller.dart';
import 'package:watermeter/controller/exam_controller.dart';
import 'package:watermeter/controller/other_experiment_controller.dart';
import 'package:watermeter/controller/physics_experiment_controller.dart';
import 'package:watermeter/controller/week_swift_controller.dart';
import 'package:watermeter/repository/logger.dart';
import 'package:watermeter/repository/preference.dart' as pref;
import 'package:watermeter/repository/xidian_ids/personal_info_session.dart';

class SemesterSyncEvent {
  final String oldSemester;
  final String remoteSemester;
  final String effectiveSemester;
  final bool didChange;
  final bool isUserDefinedSemester;

  const SemesterSyncEvent({
    required this.oldSemester,
    required this.remoteSemester,
    required this.effectiveSemester,
    required this.didChange,
    required this.isUserDefinedSemester,
  });
}

class SemesterSyncResult {
  final String localSemester;
  final String remoteSemester;
  final String effectiveSemester;
  final bool didChange;
  final bool isUserDefinedSemester;

  const SemesterSyncResult({
    required this.localSemester,
    required this.remoteSemester,
    required this.effectiveSemester,
    required this.didChange,
    required this.isUserDefinedSemester,
  });
}

class SemesterController {
  static final SemesterController i = SemesterController._();

  SemesterController._() {
    semesterSignal.equalityCheck = (a, b) => a == b;
  }

  final semesterSignal = signal(
    pref.getString(pref.Preference.currentSemester),
    debugLabel: "SemesterSignal",
  );

  final semesterSyncEventSignal = signal<SemesterSyncEvent?>(
    null,
    debugLabel: "SemesterSyncEventSignal",
  );

  int _semesterOrder(String semesterCode) {
    if (semesterCode.isEmpty) return -1;
    return pref.parseSemesterCodeToInt(semesterCode);
  }

  String _latestSemester(String a, String b) {
    return _semesterOrder(a) >= _semesterOrder(b) ? a : b;
  }

  Future<String> _fetchRemoteSemester() async {
    final remoteSemester = pref.getBool(pref.Preference.role)
        ? await PersonalInfoSession().getSemesterInfoYjspt()
        : await PersonalInfoSession().getSemesterInfoEhall();
    return remoteSemester;
  }

  void _ensureSemesterAwareControllersReady() {
    ClassTableController.i;
    ExamController.i;
    OtherExperimentController.i;
    PhysicsExperimentController.i;
    WeekSwiftController.i;
  }

  Future<SemesterSyncResult> _syncSemester({String? preferredSemester}) async {
    final localSemester = semesterSignal.value;
    final remoteSemester = await _fetchRemoteSemester();
    final preferred = preferredSemester != null && preferredSemester.isNotEmpty
        ? preferredSemester
        : localSemester;
    final effectiveSemester = _latestSemester(remoteSemester, preferred);
    final didChange = effectiveSemester != localSemester;
    final isUserDefinedSemester = effectiveSemester != remoteSemester;

    _ensureSemesterAwareControllersReady();

    await pref.setString(pref.Preference.currentSemester, effectiveSemester);
    await pref.setBool(
      pref.Preference.isUserDefinedSemester,
      isUserDefinedSemester,
    );
    semesterSignal.value = effectiveSemester;
    semesterSyncEventSignal.value = SemesterSyncEvent(
      oldSemester: localSemester,
      remoteSemester: remoteSemester,
      effectiveSemester: effectiveSemester,
      didChange: didChange,
      isUserDefinedSemester: isUserDefinedSemester,
    );

    log.info(
      "[SemesterController][_syncSemester] "
      "local=$localSemester remote=$remoteSemester "
      "preferred=$preferred effective=$effectiveSemester "
      "changed=$didChange userDefined=$isUserDefinedSemester.",
    );

    return SemesterSyncResult(
      localSemester: localSemester,
      remoteSemester: remoteSemester,
      effectiveSemester: effectiveSemester,
      didChange: didChange,
      isUserDefinedSemester: isUserDefinedSemester,
    );
  }

  Future<void> refreshSemesterInfo() async {
    await _syncSemester();
  }

  Future<SemesterSyncResult> switchSemester(String preferredSemester) async {
    return _syncSemester(preferredSemester: preferredSemester);
  }
}
