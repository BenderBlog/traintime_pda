// Copyright 2026 Traintime PDA Authours, originally by BenderBlog Rodriguez.
// SPDX-License-Identifier: MPL-2.0

import 'dart:async';

import 'package:signals/signals.dart';
import 'package:watermeter/model/time_list.dart';
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
  late final nowPeriodComputedSignal = computed(() {
    final now = currentTimeSignal.value;
    final minutes = now.hour * 60 + now.minute;
    for (var index = 0; index < timeList.length ~/ 2; index++) {
      if (minutes <= minutesOf(timeList[index * 2 + 1])) {
        if (minutes >= minutesOf(timeList[index * 2]) - 30) {
          return index + 1;
        } else {
          return null;
        }
      }
    }
    return null;
  });

  int minutesOf(String hourMinute) {
    final parts = hourMinute.split(":");
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }

  late Timer _timer;

  late final isNowOngoingComputedSignal = computed(() {
    final period = nowPeriodComputedSignal.value;
    if (period == null) {
      return false;
    }

    final now = currentTimeSignal.value;
    return now.hour * 60 + now.minute >= minutesOf(timeList[(period - 1) * 2]);
  });

  bool isToday(DateTime day) {
    final now = currentTimeSignal.value;
    return day.year == now.year && day.month == now.month && day.day == now.day;
  }

  /// 今天最后一节课是否已经结束。
  ///
  /// 「现在没有正在进行的节次」有两种可能：还没开始，或者已经全部上完。
  /// 用它把这两种情况分开，免得半夜和课间空档被当成"今天的课已经结束了"。
  late final isTodayClassesOverComputedSignal = computed(() {
    final now = currentTimeSignal.value;
    final minutes = now.hour * 60 + now.minute;
    return minutes > minutesOf(timeList.last);
  });

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
