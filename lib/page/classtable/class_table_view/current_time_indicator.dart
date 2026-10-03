// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0 OR Apache-2.0

import 'package:material_ui/material_ui.dart';
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
  static double labelBackgroundAlpha = 1.0;
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

    final int timeInMin = now.hour * 60 + now.minute;
    int parseMinute(String hhmm) {
      final parts = hhmm.split(':');
      return int.parse(parts[0]) * 60 + int.parse(parts[1]);
    }

    final firstStart = timeList.isNotEmpty ? parseMinute(timeList.first) : 0;
    final endMinute = timeList.isNotEmpty
        ? parseMinute(timeList.last)
        : 24 * 60;

    final hasLabel = CurrentTimeIndicatorConfig.showTimeLabel;
    final labelHeight = CurrentTimeIndicatorConfig.labelHeight;
    final lineThickness = CurrentTimeIndicatorConfig.lineThickness;

    // Minimum lineTop ensures the time capsule is not cut off at the start (starts at y >= 1.0)
    final double minLineTop = hasLabel
        ? (labelHeight / 2 + 1.0)
        : (lineThickness / 2 + 1.0);

    // Maximum lineTop positions the time capsule below period 11 text ("21:25") so it does not block the text
    final double maxLineTop =
        blockHeight(61) +
        (hasLabel ? (labelHeight / 2 + 3.0) : (lineThickness / 2 + 3.0));

    double lineTop = blockHeight(_transferIndex(now));
    if (timeInMin < firstStart) {
      lineTop = minLineTop;
    } else if (timeInMin >= endMinute) {
      lineTop = maxLineTop;
    } else {
      lineTop = lineTop.clamp(minLineTop, maxLineTop);
    }

    final double halfHeight = hasLabel
        ? (labelHeight / 2)
        : (lineThickness / 2);
    final indicatorTop = lineTop - halfHeight;
    final indicatorHeight = hasLabel ? labelHeight : lineThickness;
    final labelTop = 0.0;
    final lineTopOffset = (indicatorHeight - lineThickness) / 2;

    final colorScheme = Theme.of(context).colorScheme;
    final color = colorScheme.primary;

    return _IndicatorGeometry(
      indicatorTop: indicatorTop,
      indicatorHeight: indicatorHeight,
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
      lineColor: color.withValues(alpha: CurrentTimeIndicatorConfig.lineAlpha),
      labelBackgroundColor: colorScheme.surface.withValues(
        alpha: CurrentTimeIndicatorConfig.labelBackgroundAlpha,
      ),
    );
  }

  /// The combined current time indicator: the time buoy on the timeline and the horizontal line
  /// across to today's column, as a single connected whole.
  ///
  /// [opacity] fades the whole indicator, which is how the sheet ties it to the swipe progress.
  static Positioned? build({
    required BuildContext context,
    required DateTime now,
    required DateTime weekStart,
    required double leftRow,
    required double blockWidth,
    required double Function(double) blockHeight,
    double opacity = 1.0,
  }) {
    if (opacity <= 0.0) {
      return null;
    }
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

    final hasLabel = geometry.hasLabel;

    /// The buoy floats inside the time column's floating panel, which is inset from the column's
    /// own edges, so its width follows the measured column rather than a constant.
    final double buoyWidth = leftRow - 2 * timeLineInset;
    final double lineStart = hasLabel ? (timeLineInset + buoyWidth) : leftRow;
    final double todayColumnStart =
        geometry.leftRow + geometry.blockWidth * geometry.dayOffset;
    final double totalWidth =
        geometry.leftRow + geometry.blockWidth * (geometry.dayOffset + 1);

    Widget content = SizedBox(
      height: geometry.indicatorHeight,
      child: Stack(
        children: [
          if (hasLabel)
            Positioned(
              top: geometry.labelTop,
              left: timeLineInset,
              width: buoyWidth,
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
                    vertical: CurrentTimeIndicatorConfig.labelVerticalPadding,
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
          if (todayColumnStart > lineStart)
            Positioned(
              top: geometry.lineTopOffset,
              left: lineStart,
              width: todayColumnStart - lineStart,
              child: Container(
                height: CurrentTimeIndicatorConfig.lineThickness,
                color: geometry.dayOffset == 0
                    ? geometry.lineColor
                    : geometry.connectorColor,
              ),
            ),
          Positioned(
            top: geometry.lineTopOffset,
            left: todayColumnStart,
            width: geometry.blockWidth,
            child: Container(
              height: CurrentTimeIndicatorConfig.lineThickness,
              color: geometry.lineColor,
            ),
          ),
        ],
      ),
    );

    if (opacity < 1.0) {
      content = Opacity(opacity: opacity.clamp(0.0, 1.0), child: content);
    }

    return Positioned(
      left: 0,
      top: geometry.indicatorTop,
      width: totalWidth,
      child: IgnorePointer(child: content),
    );
  }

  /// The box behind today's column.
  ///
  /// It spans the full height of the grid, like the time line's panel, so the two bands end level
  /// with each other, including over the blank room the table keeps after its last period for the
  /// bottom of the display.
  static Positioned? buildDayColumnBox({
    required BuildContext context,
    required DateTime now,
    required DateTime weekStart,
    required double leftRow,
    required double blockWidth,
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
      bottom: 0,
      width: blockWidth,
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
