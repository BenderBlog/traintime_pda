// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0 OR Apache-2.0

import 'package:flutter/material.dart';

class CurrentTimeIndicatorConfig {
  static bool enabled = true;
  static bool showTimeLabel = true;
  static double lineAlpha = 0.9;
  static double lineThickness = 2;
  static double labelHeight = 14;
  static double labelFontSize = 9;
}

class CurrentTimeIndicator {
  static const List<String> _timeInBlock = [
    '08:30',
    '09:20',
    '10:25',
    '11:15',
    '12:00',
    '14:00',
    '14:50',
    '15:55',
    '16:45',
    '17:30',
    '19:00',
    '19:55',
    '20:35',
    '21:25',
  ];

  static double _transferIndex(DateTime time) {
    final timeInMin = time.hour * 60 + time.minute;
    var previous = 0;
    for (final i in _timeInBlock) {
      final timeChosen =
          int.parse(i.split(':')[0]) * 60 + int.parse(i.split(':')[1]);
      if (previous == 0) {
        if (timeInMin < timeChosen) {
          return 0;
        }
        previous = timeChosen;
        continue;
      }

      if (timeInMin >= previous && timeInMin < timeChosen) {
        var basic = 0.0;
        var blocks = 5.0;
        final ratio = (timeInMin - previous) / (timeChosen - previous);
        if (previous < 12 * 60) {
          basic = (_timeInBlock.indexOf(i) - 1) * 5;
        } else if (previous < 14 * 60) {
          basic = 20;
          blocks = 3;
        } else if (previous < 17.5 * 60) {
          basic = 23 + (_timeInBlock.indexOf(i) - 6) * 5;
        } else if (previous < 19 * 60) {
          basic = 43;
          blocks = 3;
        } else {
          basic = 46 + (_timeInBlock.indexOf(i) - 11) * 5;
        }
        return basic + blocks * ratio;
      }
      previous = timeChosen;
    }

    return 61;
  }

  static Positioned? build({
    required BuildContext context,
    required DateTime now,
    required DateTime weekStart,
    required double leftRow,
    required double blockWidth,
    required double Function(double) blockHeight,
  }) {
    if (!CurrentTimeIndicatorConfig.enabled) {
      return null;
    }

    final today = DateTime(now.year, now.month, now.day);
    final normalizedWeekStart =
        DateTime(weekStart.year, weekStart.month, weekStart.day);
    final dayOffset = today.difference(normalizedWeekStart).inDays;
    if (dayOffset < 0 || dayOffset > 6) {
      return null;
    }

    final lineTop = blockHeight(_transferIndex(now));
    final color = Theme.of(context).colorScheme.primary;
    final labelText =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    final hasLabel = CurrentTimeIndicatorConfig.showTimeLabel;
    final labelHeight = hasLabel ? CurrentTimeIndicatorConfig.labelHeight : 0.0;
    final labelTop = lineTop > labelHeight ? lineTop - labelHeight : 0.0;
    final lineOffset = lineTop - labelTop;

    return Positioned(
      left: leftRow + blockWidth * dayOffset,
      top: labelTop,
      width: blockWidth,
      child: IgnorePointer(
        child: SizedBox(
          height: lineOffset + CurrentTimeIndicatorConfig.lineThickness,
          child: Stack(
            children: [
              if (hasLabel)
                Align(
                  alignment: Alignment.topCenter,
                  child: Text(
                    labelText,
                    style: TextStyle(
                      fontSize: CurrentTimeIndicatorConfig.labelFontSize,
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              Positioned(
                top: lineOffset,
                left: 0,
                right: 0,
                child: Container(
                  height: CurrentTimeIndicatorConfig.lineThickness,
                  color: color.withValues(alpha: CurrentTimeIndicatorConfig.lineAlpha),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
