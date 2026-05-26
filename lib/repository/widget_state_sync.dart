// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

import 'package:watermeter/bridge/save_to_groupid.g.dart';
import 'package:watermeter/repository/logger.dart';
import 'package:watermeter/repository/network_session.dart' show supportPath;
import 'package:watermeter/repository/preference.dart' as preference;

/// Delete all widget data files from the iOS App Group container.
///
/// Does NOT delete [WidgetState.json] — that file is updated separately
/// via [syncWidgetLoginState].
Future<void> clearWidgetFiles() async {
  if (!Platform.isIOS) return;
  final api = SaveToGroupIdSwiftApi();

  // Files written to the iOS App Group container by the main app.
  for (final fileName in [
    'ClassTable.json',
    'UserClass.json',
    'ExamFile.json',
    'WeekSwift.txt',
    'PhysicsExperiment.json',
    'OtherExperiment.json',
  ]) {
    try {
      await api.deleteFromGroupId(
        FileToGroupID(
          appid: preference.appId,
          fileName: fileName,
          data: '', // ignored by the native side
        ),
      );
      debugPrint('[widget_state_sync] Deleted $fileName');
    } catch (e, s) {
      log.handle(e, s, '[widget_state_sync] Failed to delete $fileName');
    }
  }
}

/// Write [WidgetState.json] so that the home-screen widget knows
/// whether the user is logged in.
///
/// - iOS: writes to the App Group container via Pigeon.
/// - Android: writes to [supportPath] (same directory as widget data files).
Future<void> syncWidgetLoginState(bool loggedIn) async {
  final state = jsonEncode({
    "loggedIn": loggedIn,
    "updatedAt": DateTime.now().toIso8601String(),
  });

  if (Platform.isIOS) {
    final api = SaveToGroupIdSwiftApi();
    try {
      await api.saveToGroupId(
        FileToGroupID(
          appid: preference.appId,
          fileName: "WidgetState.json",
          data: state,
        ),
      );
      log.info("[widget_state_sync] iOS wrote WidgetState.json loggedIn=$loggedIn");
    } catch (e, s) {
      log.handle(e, s, "[widget_state_sync] iOS failed to write WidgetState.json");
    }
  } else if (Platform.isAndroid) {
    try {
      final file = File("${supportPath.path}/WidgetState.json");
      await file.writeAsString(state);
      log.info("[widget_state_sync] Android wrote WidgetState.json loggedIn=$loggedIn");
    } catch (e, s) {
      log.handle(e, s, "[widget_state_sync] Android failed to write WidgetState.json");
    }
  }
}
