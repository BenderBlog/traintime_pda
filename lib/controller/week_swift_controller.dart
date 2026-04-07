// Copyright 2026 Traintime PDA Authours, originally by BenderBlog Rodriguez.
// SPDX-License-Identifier: MPL-2.0

import 'package:signals/signals.dart';
import 'package:watermeter/repository/logger.dart';
import 'package:watermeter/repository/preference.dart' as preference;

class WeekSwiftController {
  static final WeekSwiftController i = WeekSwiftController._();

  WeekSwiftController._();

  final weekSwiftSignal = signal(
    preference.getInt(preference.Preference.swift),
    debugLabel: "WeekSwiftSignal",
  );

  void refresh() async {
    final latest = preference.getInt(preference.Preference.swift);
    weekSwiftSignal.value = latest;
  }

  Future<int> setWeekSwift(int value) async {
    await preference.setInt(preference.Preference.swift, value);
    weekSwiftSignal.value = value;
    log.info(
      "[WeekSwiftController][setWeekSwift] Update week swift to $value.",
    );
    return value;
  }

  Future<int> reset() async {
    return setWeekSwift(0);
  }
}
