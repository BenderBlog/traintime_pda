// Copyright 2026 Traintime PDA Authours, originally by BenderBlog Rodriguez.
// SPDX-License-Identifier: MPL-2.0

import 'dart:async';

import 'package:signals/signals.dart';
import 'package:watermeter/repository/logger.dart';

class GlobalTimerController {
  static final GlobalTimerController i = GlobalTimerController._();
  GlobalTimerController._() {
    _scheduleNext();
    log.info(
      "Global Timer: Time is ${currentTimeSignal.value}, timer initialized",
    );
  }

  final currentTimeSignal = signal(DateTime.now());
  late Timer _timer;

  /// 每次触发后重新计算到下一个整分的间隔，确保始终对齐整分。
  void _scheduleNext() {
    final now = DateTime.now();
    final nextMinute = DateTime(
      now.year,
      now.month,
      now.day,
      now.hour,
      now.minute + 1,
    );
    _timer = Timer(
      nextMinute.difference(now) + const Duration(milliseconds: 100),
      () {
        currentTimeSignal.value = DateTime.now();
        log.debug("Global Timer: Time is ${currentTimeSignal.value}");
        _scheduleNext();
      },
    );
  }

  void dispose() => _timer.cancel();
}
