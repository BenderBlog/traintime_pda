// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0 OR Apache-2.0

import 'package:flutter/material.dart';
import 'package:watermeter/model/time_list.dart';

class CurrentTimeIndicatorConfig {
  static bool enabled = true;
  static bool showTimeLabel = true;
  static bool showTodayColumnHighlight = true;
  static double lineAlpha = 0.9;
  static double lineThickness = 2;
  static double labelHeight = 14;
  static double labelFontSize = 9;
  static double dayColumnBorderAlpha = 0.65;
  static double dayColumnBorderWidth = 2;
}

class CurrentTimeIndicator {
  static double _transferIndex(DateTime time) {
    final timeInMin = time.hour * 60 + time.minute;
    if (timeList.isEmpty) {
      return 0;
    }

    int parseMinute(String hhmm) {
      final parts = hhmm.split(':');
      return int.parse(parts[0]) * 60 + int.parse(parts[1]);
    }

    double classStartBlock(int classIndex) {
      if (classIndex < 4) {
        return classIndex * 5.0;
      }
      if (classIndex < 8) {
        return 23 + (classIndex - 4) * 5.0;
      }
      return 46 + (classIndex - 8) * 5.0;
    }

    final firstStart = parseMinute(timeList.first);
    if (timeInMin < firstStart) {
      return 0;
    }

    final classCount = timeList.length ~/ 2;
    for (var classIndex = 0; classIndex < classCount; classIndex++) {
      final startMinute = parseMinute(timeList[classIndex * 2]);
      final endMinute = parseMinute(timeList[classIndex * 2 + 1]);
      final startBlock = classStartBlock(classIndex);
      final endBlock = startBlock + 5;

      if (timeInMin >= startMinute && timeInMin < endMinute) {
        final ratio = (timeInMin - startMinute) / (endMinute - startMinute);
        return startBlock + 5 * ratio;
      }

      if (classIndex == classCount - 1) {
        if (timeInMin >= endMinute) {
          return 61;
        }
        continue;
      }

      final nextStartMinute = parseMinute(timeList[(classIndex + 1) * 2]);
      if (timeInMin >= endMinute && timeInMin < nextStartMinute) {
        final nextStartBlock = classStartBlock(classIndex + 1);
        final breakMinuteSpan = nextStartMinute - endMinute;
        final breakBlockSpan = nextStartBlock - endBlock;

        // Move continuously during breaks that have visible rows (e.g. lunch/dinner).
        // If there is no visual gap between classes, keep the indicator at the boundary.
        if (breakMinuteSpan > 0 && breakBlockSpan > 0) {
          final ratio = (timeInMin - endMinute) / breakMinuteSpan;
          return endBlock + breakBlockSpan * ratio;
        }
        return endBlock;
      }
    }

    return 61;
  }

  static double transferTimeToBlockIndex(DateTime time) => _transferIndex(time);

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
    final normalizedWeekStart = DateTime(
      weekStart.year,
      weekStart.month,
      weekStart.day,
    );
    final dayOffset = today.difference(normalizedWeekStart).inDays;
    if (dayOffset < 0 || dayOffset > 6) {
      return null;
    }

    final lineTop = blockHeight(_transferIndex(now));
    final color = Theme.of(context).colorScheme.primary;
    final lineHorizontalInset =
        CurrentTimeIndicatorConfig.showTodayColumnHighlight
        ? CurrentTimeIndicatorConfig.dayColumnBorderWidth
        : 0.0;
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
                top: lineOffset - CurrentTimeIndicatorConfig.lineThickness / 2,
                left: lineHorizontalInset / 2,
                right: lineHorizontalInset / 2,
                child: Container(
                  height: CurrentTimeIndicatorConfig.lineThickness,
                  color: color.withValues(
                    alpha: CurrentTimeIndicatorConfig.lineAlpha,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Positioned? buildDayColumnBox({
    required BuildContext context,
    required DateTime now,
    required DateTime weekStart,
    required double leftRow,
    required double blockWidth,
    required double Function(double) blockHeight,
  }) {
    if (!CurrentTimeIndicatorConfig.showTodayColumnHighlight) {
      return null;
    }

    final today = DateTime(now.year, now.month, now.day);
    final normalizedWeekStart = DateTime(
      weekStart.year,
      weekStart.month,
      weekStart.day,
    );
    final dayOffset = today.difference(normalizedWeekStart).inDays;
    if (dayOffset < 0 || dayOffset > 6) {
      return null;
    }

    final color = Theme.of(context).colorScheme.primary.withValues(
      alpha: CurrentTimeIndicatorConfig.lineAlpha,
    );

    return Positioned(
      left:
          leftRow +
          blockWidth * dayOffset -
          CurrentTimeIndicatorConfig.dayColumnBorderWidth / 2,
      top: 0,
      width: blockWidth + CurrentTimeIndicatorConfig.dayColumnBorderWidth,
      height: blockHeight(61),
      child: IgnorePointer(
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(
              color: color,
              width: CurrentTimeIndicatorConfig.dayColumnBorderWidth,
            ),
          ),
        ),
      ),
    );
  }
}
