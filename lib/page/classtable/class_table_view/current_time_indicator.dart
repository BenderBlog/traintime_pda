// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0 OR Apache-2.0

import 'package:flutter/material.dart';
import 'package:watermeter/model/time_list.dart';
import 'package:watermeter/page/classtable/classtable_constant.dart';
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
  static double labelFontSize = 7;
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

  /// Everything the indicator needs to place itself this frame.
  ///
  /// Pulled out because the indicator is drawn in two layers: the label belongs with the time line,
  /// which is stacked above the classes, while the line itself belongs with the week pages so that
  /// it slides with the column it crosses.
  static _IndicatorGeometry? _geometry({
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
    final hasLabel = CurrentTimeIndicatorConfig.showTimeLabel;
    final labelHeight = CurrentTimeIndicatorConfig.labelHeight;
    final indicatorTop = lineTop - labelHeight;
    final lineOffset = lineTop - indicatorTop;
    final lineTopOffset =
        lineOffset - CurrentTimeIndicatorConfig.lineThickness / 2;
    final labelTop = lineOffset - labelHeight / 2;
    final labelBottom = labelTop + labelHeight;
    final lineBottom = lineTopOffset + CurrentTimeIndicatorConfig.lineThickness;

    return _IndicatorGeometry(
      indicatorTop: indicatorTop,
      indicatorHeight:
          (hasLabel
                  ? (labelBottom > lineBottom ? labelBottom : lineBottom)
                  : lineBottom)
              .clamp(0.0, double.infinity)
              .toDouble(),
      labelTop: labelTop,
      lineTopOffset: lineTopOffset,
      dayOffset: dayOffset,
      leftRow: leftRow,
      blockWidth: blockWidth,
      hasLabel: hasLabel,
      labelText:
          '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
      color: color,
      connectorColor: color.withValues(
        alpha: CurrentTimeIndicatorConfig.lineAlpha * 0.35,
      ),
      lineColor: color.withValues(
        alpha: CurrentTimeIndicatorConfig.lineAlpha,
      ),
      labelBackgroundColor: colorScheme.surface.withValues(
        alpha: CurrentTimeIndicatorConfig.labelBackgroundAlpha,
      ),
    );
  }

  /// The line across today's column, with the connector running back towards the time line.
  static Positioned? build({
    required BuildContext context,
    required DateTime now,
    required DateTime weekStart,
    required double leftRow,
    required double blockWidth,
    required double Function(double) blockHeight,
  }) {
    final _IndicatorGeometry? geometry = _geometry(
      context: context,
      now: now,
      weekStart: weekStart,
      leftRow: leftRow,
      blockWidth: blockWidth,
      blockHeight: blockHeight,
    );
    if (geometry == null) {
      return null;
    }

    return Positioned(
      left: 0,
      top: geometry.indicatorTop,
      width: geometry.leftRow + geometry.blockWidth * (geometry.dayOffset + 1),
      child: IgnorePointer(
        child: SizedBox(
          height: geometry.indicatorHeight,
          child: Stack(
            children: [
              if (geometry.dayOffset > 0)
                Positioned(
                  top: geometry.lineTopOffset,
                  left: geometry.leftRow,
                  width: geometry.blockWidth * geometry.dayOffset,
                  child: Container(
                    height: CurrentTimeIndicatorConfig.lineThickness,
                    color: geometry.connectorColor,
                  ),
                ),
              Positioned(
                top: geometry.lineTopOffset,
                left:
                    geometry.leftRow +
                    geometry.blockWidth * geometry.dayOffset,
                width: geometry.blockWidth,
                child: Container(
                  height: CurrentTimeIndicatorConfig.lineThickness,
                  color: geometry.lineColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Just the time label.
  ///
  /// Drawn with the time line rather than with the week pages, so that the floating time-line panel
  /// cannot cover it now that the time line is stacked above the classes.
  static Positioned? buildLabel({
    required BuildContext context,
    required DateTime now,
    required DateTime weekStart,
    required double leftRow,
    required double blockWidth,
    required double Function(double) blockHeight,
  }) {
    final _IndicatorGeometry? geometry = _geometry(
      context: context,
      now: now,
      weekStart: weekStart,
      leftRow: leftRow,
      blockWidth: blockWidth,
      blockHeight: blockHeight,
    );
    if (geometry == null || !geometry.hasLabel) {
      return null;
    }

    return Positioned(
      left: 0,
      top: geometry.indicatorTop,
      width: geometry.leftRow,
      child: IgnorePointer(
        child: SizedBox(
          height: geometry.indicatorHeight,
          child: Stack(
            children: [
              Positioned(
                top: geometry.labelTop,
                /// Lines up with the floating time-line panel, which is inset from the edge.
                left: timeLineInset,
                width: timeLineWidth,
                height: CurrentTimeIndicatorConfig.labelHeight,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: geometry.labelBackgroundColor,
                    border: Border.all(
                      color: geometry.color.withValues(alpha: 0.7),
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
                        geometry.labelText,
                        style: TextStyle(
                          fontSize: CurrentTimeIndicatorConfig.labelFontSize,
                          color: geometry.color,
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

/// Where the current-time indicator sits this frame.
///
/// Shared by [CurrentTimeIndicator.build] and [CurrentTimeIndicator.buildLabel], which are drawn in
/// different layers.
class _IndicatorGeometry {
  const _IndicatorGeometry({
    required this.indicatorTop,
    required this.indicatorHeight,
    required this.labelTop,
    required this.lineTopOffset,
    required this.dayOffset,
    required this.leftRow,
    required this.blockWidth,
    required this.hasLabel,
    required this.labelText,
    required this.color,
    required this.connectorColor,
    required this.lineColor,
    required this.labelBackgroundColor,
  });

  final double indicatorTop;
  final double indicatorHeight;
  final double labelTop;
  final double lineTopOffset;
  final int dayOffset;
  final double leftRow;
  final double blockWidth;
  final bool hasLabel;
  final String labelText;
  final Color color;
  final Color connectorColor;
  final Color lineColor;
  final Color labelBackgroundColor;
}
