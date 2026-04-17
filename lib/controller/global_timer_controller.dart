// Copyright 2026 Traintime PDA Authours, originally by BenderBlog Rodriguez.
// SPDX-License-Identifier: MPL-2.0

import 'dart:async';

import 'package:signals/signals.dart';
import 'package:watermeter/repository/logger.dart';

class GlobalTimerController {
  static final GlobalTimerController i = GlobalTimerController._();
  GlobalTimerController._() {
    _timer = Timer.periodic(const Duration(seconds: 15), (_) {
      currentTimeSignal.value = DateTime.now();
      log.debug("Global Timer: Time is ${currentTimeSignal.value}");
    });
  }

  final currentTimeSignal = signal(DateTime.now());

  late final Timer _timer;

  void dispose() => _timer.cancel();
}
