// Copyright 2026 Traintime PDA Authours, originally by BenderBlog Rodriguez.
// SPDX-License-Identifier: MPL-2.0

import 'package:signals/signals.dart';
import 'package:watermeter/repository/logger.dart';
import 'package:watermeter/repository/preference.dart' as pref;
import 'package:watermeter/repository/xidian_ids/personal_info_session.dart';

class SemesterChangeEvent {
  final String oldSemester;
  final String newSemester;

  const SemesterChangeEvent({
    required this.oldSemester,
    required this.newSemester,
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

  final semesterChangeEventSignal = signal<SemesterChangeEvent?>(
    null,
    debugLabel: "SemesterChangeEventSignal",
  );

  Future<void> refreshSemesterInfo() async {
    final localSemester = semesterSignal.value;
    final remoteSemester = pref.getBool(pref.Preference.role)
        ? await PersonalInfoSession().getSemesterInfoYjspt()
        : await PersonalInfoSession().getSemesterInfoEhall();

    final shouldUseRemote =
        localSemester.isEmpty ||
        pref.parseSemesterCodeToInt(remoteSemester) >=
            pref.parseSemesterCodeToInt(localSemester);
    final isNewSemester =
        localSemester.isNotEmpty &&
        pref.parseSemesterCodeToInt(remoteSemester) >
            pref.parseSemesterCodeToInt(localSemester);

    if (shouldUseRemote) {
      await pref.setString(pref.Preference.currentSemester, remoteSemester);
      await pref.setBool(pref.Preference.isUserDefinedSemester, false);
      if (isNewSemester) {
        semesterChangeEventSignal.value = SemesterChangeEvent(
          oldSemester: localSemester,
          newSemester: remoteSemester,
        );
      }
      semesterSignal.value = remoteSemester;
      log.info(
        "[SemesterController][refreshSemesterInfo] "
        "Update semester from $localSemester to $remoteSemester.",
      );
      return;
    }

    log.info(
      "[SemesterController][refreshSemesterInfo] "
      "Keep local semester $localSemester, remote semester is $remoteSemester.",
    );
  }
}
