// Copyright 2026 Traintime PDA Authours, originally by BenderBlog Rodriguez.
// SPDX-License-Identifier: MPL-2.0

import 'dart:io';

import 'package:watermeter/bridge/save_to_groupid.g.dart';
import 'package:signals/signals.dart';
import 'package:watermeter/controller/semester_controller.dart';
import 'package:watermeter/repository/logger.dart';
import 'package:watermeter/repository/preference.dart' as preference;

class WeekSwiftController {
  static final WeekSwiftController i = WeekSwiftController._();

  WeekSwiftController._() {
    _initEffects();
  }

  final weekSwiftSignal = signal(
    preference.getInt(preference.Preference.swift),
    debugLabel: "WeekSwiftSignal",
  );
  SemesterSyncEvent? _lastHandledSemesterSyncEvent;

  void _initEffects() {
    effect(() {
      final semesterChangeEvent =
          SemesterController.i.semesterSyncEventSignal.value;
      if (semesterChangeEvent == null ||
          identical(semesterChangeEvent, _lastHandledSemesterSyncEvent)) {
        return;
      }

      _lastHandledSemesterSyncEvent = semesterChangeEvent;
      if (semesterChangeEvent.didChange) {
        reset();
      }
    }, debugLabel: "WeekSwiftControllerSemesterChangeEffect");
  }

  void refresh() async {
    final latest = preference.getInt(preference.Preference.swift);
    weekSwiftSignal.value = latest;
  }

  Future<int> setWeekSwift(int value) async {
    await preference.setInt(preference.Preference.swift, value);
    if (Platform.isIOS) {
      final api = SaveToGroupIdSwiftApi();
      try {
        final result = await api.saveToGroupId(
          FileToGroupID(
            appid: preference.appId,
            fileName: "WeekSwift.txt",
            data: value.toString(),
          ),
        );
        log.info(
          "[WeekSwiftController][setWeekSwift] "
          "ios Save to public place status: $result.",
        );
      } catch (e, s) {
        log.handle(e, s);
      }
    }
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
