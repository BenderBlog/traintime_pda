// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0 OR Apache-2.0

import 'package:flutter/material.dart';
import 'package:watermeter/model/time_list.dart';
import 'package:watermeter/repository/preference.dart' as preference;

class CurrentTimeIndicatorConfig {
  /// Default tuning parameters for the current time indicator.
  /// Configuration for the current time indicator in the class table view.
  static bool enabled = true;
  static bool showTimeLabel = true;
  static bool showTodayColumnHighlight = true;
  static double lineAlpha = 0.9;
  static double lineThickness = 2;
  static double labelHeight = 13;
  static double labelFontSize = 8;
  static double labelBackgroundAlpha = 0.75;
  static double labelHorizontalPadding = 1;
  static double labelVerticalPadding = 1;
  static double labelBorderRadius = 4;
  static double dayColumnHighlightAlpha = 0.25;
  static double dayColumnHighlightRadius = 8;

  static void loadFromPreference() {
    if (preference.contains(
      preference.Preference.currentTimeIndicatorEnabled,
    )) {
      enabled = preference.getBool(
        preference.Preference.currentTimeIndicatorEnabled,
      );
    }
    if (preference.contains(
      preference.Preference.currentTimeIndicatorShowTimeLabel,
    )) {
      showTimeLabel = preference.getBool(
        preference.Preference.currentTimeIndicatorShowTimeLabel,
      );
    }
    if (preference.contains(
      preference.Preference.currentTimeIndicatorShowTodayColumnHighlight,
    )) {
      showTodayColumnHighlight = preference.getBool(
        preference.Preference.currentTimeIndicatorShowTodayColumnHighlight,
      );
    }
  }

  static Future<void> saveToPreference() async {
    await preference.setBool(
      preference.Preference.currentTimeIndicatorEnabled,
      enabled,
    );
    await preference.setBool(
      preference.Preference.currentTimeIndicatorShowTimeLabel,
      showTimeLabel,
    );
    await preference.setBool(
      preference.Preference.currentTimeIndicatorShowTodayColumnHighlight,
      showTodayColumnHighlight,
    );
  }
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
    final colorScheme = Theme.of(context).colorScheme;
    final color = colorScheme.primary;
    final labelText =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    final hasLabel = CurrentTimeIndicatorConfig.showTimeLabel;
    final labelHeight = CurrentTimeIndicatorConfig.labelHeight;
    final indicatorTop = lineTop > labelHeight ? lineTop - labelHeight : 0.0;
    final lineOffset = lineTop - indicatorTop;
    final lineTopOffset =
        lineOffset - CurrentTimeIndicatorConfig.lineThickness / 2;
    final labelTop = (lineOffset - CurrentTimeIndicatorConfig.labelHeight / 2)
        .clamp(0.0, double.infinity)
        .toDouble();
    final labelBottom = labelTop + CurrentTimeIndicatorConfig.labelHeight;
    final lineBottom = lineTopOffset + CurrentTimeIndicatorConfig.lineThickness;
    final indicatorHeight =
        (hasLabel
                ? (labelBottom > lineBottom ? labelBottom : lineBottom)
                : lineBottom)
            .clamp(0.0, double.infinity)
            .toDouble();
    final labelBackgroundColor = colorScheme.surface.withValues(
      alpha: CurrentTimeIndicatorConfig.labelBackgroundAlpha,
    );
    final connectorColor = color.withValues(
      alpha: CurrentTimeIndicatorConfig.lineAlpha * 0.35,
    );
    final lineColor = color.withValues(
      alpha: CurrentTimeIndicatorConfig.lineAlpha,
    );

    return Positioned(
      left: 0,
      top: indicatorTop,
      width: leftRow + blockWidth * (dayOffset + 1),
      child: IgnorePointer(
        child: SizedBox(
          height: indicatorHeight,
          child: Stack(
            children: [
              if (hasLabel)
                Positioned(
                  top: labelTop,
                  left: 0,
                  width: leftRow,
                  height: CurrentTimeIndicatorConfig.labelHeight,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: labelBackgroundColor,
                      border: Border.all(
                        color: color.withValues(alpha: 0.7),
                        width: 1.4,
                      ),
                      borderRadius: BorderRadius.circular(
                        CurrentTimeIndicatorConfig.labelBorderRadius,
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal:
                            CurrentTimeIndicatorConfig.labelHorizontalPadding,
                        vertical:
                            CurrentTimeIndicatorConfig.labelVerticalPadding,
                      ),
                      child: Center(
                        child: Text(
                          labelText,
                          style: TextStyle(
                            fontSize: CurrentTimeIndicatorConfig.labelFontSize,
                            color: color,
                            fontWeight: FontWeight.w700,
                            height: 1,
                            shadows: const [
                              Shadow(
                                offset: Offset(0, 0),
                                blurRadius: 2,
                                color: Colors.black26,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              if (dayOffset > 0)
                Positioned(
                  top: lineTopOffset,
                  left: leftRow,
                  width: blockWidth * dayOffset,
                  child: Container(
                    height: CurrentTimeIndicatorConfig.lineThickness,
                    color: connectorColor,
                  ),
                ),
              Positioned(
                top: lineTopOffset,
                left: leftRow + blockWidth * dayOffset,
                width: blockWidth,
                child: Container(
                  height: CurrentTimeIndicatorConfig.lineThickness,
                  color: lineColor,
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
      alpha: CurrentTimeIndicatorConfig.dayColumnHighlightAlpha,
    );

    return Positioned(
      left: leftRow + blockWidth * dayOffset,
      top: 0,
      width: blockWidth,
      height: blockHeight(61),
      child: IgnorePointer(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(
              CurrentTimeIndicatorConfig.dayColumnHighlightRadius,
            ),
          ),
        ),
      ),
    );
  }
}
