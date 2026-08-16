// Copyright 2026 Traintime PDA Authours, originally by BenderBlog Rodriguez.
// SPDX-License-Identifier: MPL-2.0

import 'dart:math';
import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:watermeter/model/xidian_ids/energy.dart';
import 'package:watermeter/repository/logger.dart';
import 'package:watermeter/generated/translations.g.dart';

class _GraphMetrics {
  static const double tooltipFontSize = 9;
  static const double lineStrokeWidth = 0;
  static const axisLabelFontWeight = FontWeight.w400;
  static const lineWidth = 8.0;
  static const graphRowPadding = 4.0;
  static const double minRowHeight = 24.0;
  static const horizontalLines = 5;
}

/// The usage of one calendar day after meter readings have been merged.
class DailyElectricityUsage {
  final DateTime date;
  final double usage;

  const DailyElectricityUsage({required this.date, required this.usage});

  @override
  bool operator ==(Object other) {
    return other is DailyElectricityUsage &&
        other.date == date &&
        other.usage == usage;
  }

  @override
  int get hashCode => Object.hash(date, usage);

  @override
  String toString() => '{date: $date, usage: $usage}';
}

class ElectricityAverageUsageGraph extends StatefulWidget {
  late final List<DailyElectricityUsage> plotData;
  final double graphWidth;
  final double? preferredRowHeight;

  ElectricityAverageUsageGraph({
    super.key,
    required List<MeterInfo> historyElectricityInfo,
    required this.graphWidth,
    this.preferredRowHeight,
  }) {
    final rowsByDay = SplayTreeMap<DateTime, List<MeterInfo>>();
    for (final row in historyElectricityInfo) {
      final day = DateTime(
        row.ReadTime.year,
        row.ReadTime.month,
        row.ReadTime.day,
      );
      rowsByDay.putIfAbsent(day, () => []).add(row);
    }

    final result = <DailyElectricityUsage>[];
    for (final entry in rowsByDay.entries) {
      final uniqueRows = <String, MeterInfo>{};

      for (final row in entry.value) {
        final start = row.StartNum.toDouble();
        final end = row.EndNum.toDouble();
        final usage = row.ReadNum.toDouble();

        if (!start.isFinite || !end.isFinite || !usage.isFinite) {
          continue;
        }

        // The same interval can be returned more than once with a different
        // read timestamp. It must not be counted twice. Negative usage is
        // intentionally kept because it represents a meter-reading
        // correction and offsets the positive reading on the same day.
        final key = '$start|$end|$usage';
        uniqueRows.putIfAbsent(key, () => row);
      }

      if (uniqueRows.isEmpty) continue;

      // Usage is a signed meter delta. A negative row is a correction and
      // must offset the positive rows from the same calendar day.
      final totalUsage = uniqueRows.values.fold<double>(
        0.0,
        (total, row) => total + row.ReadNum.toDouble(),
      );

      result.add(DailyElectricityUsage(date: entry.key, usage: totalUsage));
    }
    plotData = result;

    log.info("[ElectricityWindow][ElectricityUsageGraph] Based on $plotData");
  }

  @override
  State<ElectricityAverageUsageGraph> createState() =>
      _ElectricityAverageUsageGraphState();
}

class _ElectricityAverageUsageGraphState
    extends State<ElectricityAverageUsageGraph> {
  double _estimateRowHeight(BuildContext context) {
    final testTitle = TextPainter(
      text: const TextSpan(
        text: "12.31",
        style: TextStyle(
          fontSize: _GraphMetrics.tooltipFontSize,
          fontWeight: _GraphMetrics.axisLabelFontWeight,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final testValue = TextPainter(
      text: const TextSpan(
        text: "99.99",
        style: TextStyle(
          fontSize: _GraphMetrics.tooltipFontSize,
          fontWeight: _GraphMetrics.axisLabelFontWeight,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final contentHeight = max(testTitle.height, testValue.height);
    final rowHeight = contentHeight + _GraphMetrics.graphRowPadding * 2;

    return max(rowHeight, _GraphMetrics.minRowHeight);
  }

  @override
  Widget build(BuildContext context) {
    log.info(
      "[ElectricityAverageUsageGraph] Based on plotdata ${widget.plotData}",
    );

    // No rows means there is nothing to draw.
    if (widget.plotData.isEmpty) {
      log.info("[ElectricityAverageUsageGraph] Not enough data, quit!");

      return Text(
        context.t.electricity.notEnoughData,
        textAlign: TextAlign.center,

        style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
      ).width(double.infinity);
    }
    final rowHeight = widget.preferredRowHeight ?? _estimateRowHeight(context);
    final totalHeight = rowHeight * widget.plotData.length;
    log.info(
      "[ElectricityAverageUsageGraph] Decided height: $totalHeight (rows=${widget.plotData.length})",
    );
    return SizedBox(
      width: widget.graphWidth,
      height: totalHeight,
      child: RepaintBoundary(
        child: CustomPaint(
          painter: HistogramPainter(
            context,
            plotData: widget.plotData,
            color: Theme.of(context).colorScheme.primary,
            rowHeight: rowHeight,
          ),
          child: RepaintBoundary(
            child: SizedBox(width: widget.graphWidth, height: totalHeight),
          ),
        ),
      ),
    );
  }
}

class HistogramPainter extends CustomPainter {
  final List<DailyElectricityUsage> plotData;
  final BuildContext context;
  final Color color;
  final double rowHeight;

  late final Paint _strokePaint;
  late final Paint _fillPaint;

  HistogramPainter(
    this.context, {
    required this.plotData,
    required this.color,
    required this.rowHeight,
  }) {
    _fillPaint = Paint()
      ..strokeWidth = _GraphMetrics.lineStrokeWidth
      ..color = color
      ..style = PaintingStyle.fill;
    _strokePaint = Paint()
      ..strokeWidth = _GraphMetrics.lineStrokeWidth
      ..style = PaintingStyle.fill;
  }

  @override
  void paint(Canvas canvas, Size size) {
    List<TextPainter> titles = plotData.map((v) {
      return TextPainter(
        text: TextSpan(
          text: "${v.date.month}.${v.date.day}",
          style: Theme.of(context).textTheme.labelSmall!.copyWith(
            fontSize: _GraphMetrics.tooltipFontSize,
            fontWeight: _GraphMetrics.axisLabelFontWeight,
          ),
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      )..layout();
    }).toList();
    double longestTitleWidth = titles.fold(
      0,
      (previousValue, element) => element.size.width > previousValue
          ? element.size.width
          : previousValue,
    );
    double longestTitleHeight = titles.fold(
      0,
      (previousValue, element) => element.size.height > previousValue
          ? element.size.height
          : previousValue,
    );
    log.info(
      "[HistogramPainter] longestTitleWidth: $longestTitleWidth; "
      "longestTitleHeight: $longestTitleHeight",
    );

    List<TextPainter> values = plotData.map((v) {
      return TextPainter(
        text: TextSpan(
          text: v.usage.toStringAsFixed(2),
          style: Theme.of(context).textTheme.labelSmall!.copyWith(
            fontSize: _GraphMetrics.tooltipFontSize,
            fontWeight: _GraphMetrics.axisLabelFontWeight,
            color: v.usage < 0 ? Colors.red : null,
          ),
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      )..layout();
    }).toList();
    double longestValueWidth = values.fold(
      0,
      (previousValue, element) => element.size.width > previousValue
          ? element.size.width
          : previousValue,
    );
    double longestValueHeight = values.fold(
      0,
      (previousValue, element) => element.size.height > previousValue
          ? element.size.height
          : previousValue,
    );
    log.info(
      "[HistogramPainter] longestValueWidth: $longestValueWidth; "
      "longestValueHeight: $longestValueHeight",
    );

    double paintRange =
        size.width -
        longestTitleWidth -
        longestValueWidth -
        _GraphMetrics.lineWidth;
    num maxNum = plotData.fold<num>(
      0.0,
      (previous, current) =>
          current.usage > previous ? current.usage : previous,
    );
    num minNum = plotData.fold<num>(
      0.0,
      (previous, current) =>
          current.usage < previous ? current.usage : previous,
    );
    log.info(
      "[HistogramPainter] paintRange: $paintRange; "
      "maxNum: $maxNum; minNum: $minNum",
    );

    final rectHeight = rowHeight - _GraphMetrics.graphRowPadding * 2;
    double rectLeftStart = longestTitleWidth + _GraphMetrics.lineWidth;

    for (var i = 0; i <= _GraphMetrics.horizontalLines; ++i) {
      canvas.drawLine(
        Offset(
          rectLeftStart + paintRange / _GraphMetrics.horizontalLines * i,
          0,
        ),
        Offset(
          rectLeftStart + paintRange / _GraphMetrics.horizontalLines * i,
          size.height,
        ),
        _strokePaint..color = Colors.grey,
      );
    }

    for (var i = 0; i < plotData.length; ++i) {
      double titleTopStart = rowHeight * (i + 0.5) - longestTitleHeight * 0.5;
      double titleLeftStart = longestTitleWidth - titles[i].size.width;
      titles[i].paint(canvas, Offset(titleLeftStart, titleTopStart));

      double rectTopStart = rowHeight * (i + 0.5) - rectHeight * 0.5;
      final range = maxNum - minNum;
      final rectWidth = range == 0
          ? 0.0
          : paintRange / range * (plotData[i].usage - minNum);
      canvas.drawRect(
        Rect.fromLTWH(rectLeftStart, rectTopStart, rectWidth, rectHeight),
        _fillPaint..color = plotData[i].usage < 0 ? Colors.red : color,
      );

      double valueLeftStart =
          rectLeftStart + rectWidth + _GraphMetrics.lineWidth / 2;
      double valueTopStart = rowHeight * (i + 0.5) - longestTitleHeight * 0.5;
      values[i].paint(canvas, Offset(valueLeftStart, valueTopStart));
    }
  }

  @override
  bool shouldRepaint(covariant HistogramPainter oldDelegate) {
    return !listEquals(oldDelegate.plotData, plotData) ||
        oldDelegate.color != color ||
        oldDelegate.rowHeight != rowHeight;
  }
}
