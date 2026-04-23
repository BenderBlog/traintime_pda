// Copyright 2026 Traintime PDA Authours, originally by BenderBlog Rodriguez.
// SPDX-License-Identifier: MPL-2.0

import 'dart:math' as math;

import 'package:signals/signals.dart';
import 'package:watermeter/model/pda_service/message.dart';
import 'package:watermeter/repository/logger.dart';
import 'package:watermeter/repository/pda_service_session.dart';
import 'package:watermeter/repository/preference.dart' as pref;

class UpdateNoticeController {
  static UpdateNoticeController i = UpdateNoticeController._();
  bool _isReloading = false;

  UpdateNoticeController._();

  final updateMessageStateSignal = signal<AsyncState<UpdateMessage>>(
    const AsyncLoading(),
  );

  Future<void> reloadUpdateNoticeInfo() async {
    if (_isReloading) return;
    _isReloading = true;
    final previous = updateMessageStateSignal.peek().value;
    updateMessageStateSignal.value = previous != null
        ? AsyncState.dataRefreshing(previous)
        : AsyncState.loading();
    try {
      final result = await checkUpdate();
      updateMessageStateSignal.value = AsyncState.data(result);
    } catch (e, s) {
      updateMessageStateSignal.value = AsyncState.error(e, s);
      log.handle(
        e,
        s,
        "[UpdateNoticeController][reloadUpdateNoticeInfo] Have issue",
      );
    } finally {
      _isReloading = false;
    }
  }

  /// true: new version avaliable
  /// false: latest version
  /// null: testing version
  late final isNewVersionAvaliableComputed = computed(() {
    return updateMessageStateSignal.value.map(
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
