// Copyright 2026 Traintime PDA Authours, originally by BenderBlog Rodriguez.
// SPDX-License-Identifier: MPL-2.0

import 'dart:math' as math;

import 'package:signals/signals.dart';
import 'package:watermeter/repository/logger.dart';
import 'package:watermeter/repository/pda_service_session.dart';
import 'package:watermeter/repository/preference.dart' as pref;

class UpdateNoticeController {
  static UpdateNoticeController i = UpdateNoticeController._();

  UpdateNoticeController._();

  final updateMessageSignal = futureSignal(checkUpdate);

  Future<void> reloadUpdateNoticeInfo() async {
    if (updateMessageSignal.value.isLoading) return;
    return await updateMessageSignal.reload().catchError(
      (e, s) => log.handle(
        e,
        s,
        "[UpdateNoticeController][reloadUpdateNoticeInfo] Have issue",
      ),
    );
  }

  /// true: new version avaliable
  /// false: latest version
  /// null: testing version
  late final isNewVersionAvaliableComputed = computed(() {
    return updateMessageSignal.value.map(
      data: (updateMessage) {
        List<int> versionCode = updateMessage.code
            .split('.')
            .map((value) => int.parse(value))
            .toList();
        List<int> localCode = pref.packageInfo.version
            .split('.')
            .map((value) => int.parse(value))
            .toList();
        bool? isNewAvaliable = false;
        for (
          int i = 0;
          i < math.min(versionCode.length, localCode.length);
          i++
        ) {
          if (versionCode[i] > localCode[i]) {
            isNewAvaliable = true;
            break;
          } else if (versionCode[i] < localCode[i]) {
            isNewAvaliable = null;
            break;
          }
        }
        return isNewAvaliable;
      },
      error: (err, _) => false,
      loading: () => false,
    );
  });
}
