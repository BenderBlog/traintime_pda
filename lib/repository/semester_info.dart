// Copyright 2026 Traintime PDA Authours, originally by BenderBlog Rodriguez.
// SPDX-License-Identifier: MPL-2.0

import 'package:watermeter/repository/preference.dart';
import 'package:watermeter/repository/logger.dart';

/// get semester from user or robot
String getSemester() {
  final userDefinedSemester = getString(Preference.userDefinedSemester);
  if (userDefinedSemester.isNotEmpty) {
    log.info("[getSemester] user semester $userDefinedSemester");
    return userDefinedSemester;
  }
  log.info("[getSemester] current semester $userDefinedSemester");
  return getString(Preference.currentSemester);
}

Future<void> setUserSemester(int selectedYear, int selectedSemester) async {
  String semester = selectedYear.toString();
  if (!getBool(Preference.role)) {
    semester += "-${selectedYear + 1}-";
  }
  semester += selectedSemester.toString();
  await setString(Preference.userDefinedSemester, semester);
}

Future<void> setCurrentSemester(
  String semester, {
  bool clearUserSemester = false,
}) async {
  if (clearUserSemester) {
    await setString(Preference.userDefinedSemester, "");
  }
  await setString(Preference.currentSemester, semester);
}
