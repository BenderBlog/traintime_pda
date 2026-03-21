// Copyright 2026 Traintime PDA Authours, originally by BenderBlog Rodriguez.
// SPDX-License-Identifier: MPL-2.0

import 'dart:math';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:watermeter/model/xidian_ids/electricity.dart';
import 'package:watermeter/repository/logger.dart';

class _GraphMetrics {
  static const double tooltipFontSize = 9;
  static const double lineStrokeWidth = 0;
  static const axisLabelFontWeight = FontWeight.w400;
  static const lineWidth = 8.0;
  static const graphRowPadding = 4.0;
  static const double minRowHeight = 24.0;
  static const horizontalLines = 5;
}

class ElectricityAverageUsageGraph extends StatefulWidget {
  late final SplayTreeMap<(DateTime, DateTime), double> plotData;
  final double graphWidth;
  final double? preferredRowHeight;

  ElectricityAverageUsageGraph({
    super.key,
    required List<ElectricityInfo> historyElectricityInfo,
    required this.graphWidth,
    this.preferredRowHeight,
  }) {
    SplayTreeMap<DateTime, double> dayMin = SplayTreeMap();
    for (final info in historyElectricityInfo) {
      final v = double.tryParse(info.remain);
      if (v == null) continue;
      final dayTime = DateTime(
        info.fetchDay.year,
        info.fetchDay.month,
        info.fetchDay.day,
      );
      if (!dayMin.containsKey(dayTime) || v < dayMin[dayTime]!) {
        dayMin[dayTime] = v;
      }
    }
    log.info("[ElectricityAverageUsageGraph] Based on dayMin $dayMin");
    plotData = SplayTreeMap((a, b) => a.$1.difference(b.$1).inDays);
    if (dayMin.keys.length <= 1) return;

    // Daily usage of the electricity
    final keys = dayMin.keys.toList();
    double max = 0.0;
    double min = double.maxFinite;
    for (int i = 1; i < keys.length; i++) {
      final dt = keys[i];
      final dtPrev = keys[i - 1];
      final curr = dayMin[keys[i]]!;
      final prev = dayMin[keys[i - 1]]!;
      final dayDiff = DateTime(
        dt.year,
        dt.month,
        dt.day,
      ).difference(DateTime(dtPrev.year, dtPrev.month, dtPrev.day)).inDays;
      final diff = (prev - curr) / dayDiff;
      if (diff < 0) continue;
      if (diff > max) max = diff;
      if (diff < min) min = diff;
      plotData[(dtPrev, dt)] = diff;
    }
  }

  @override
  State<ElectricityAverageUsageGraph> createState() =>
      _ElectricityAverageUsageGraphState();
}

class _ElectricityAverageUsageGraphState
    extends State<ElectricityAverageUsageGraph> {
  double _estimateRowHeight(BuildContext context) {
    // 用一个假的 TextPainter 来估算最长可能的标签高度
    final testTitle = TextPainter(
      text: const TextSpan(
        text: "12.31~01.15",
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

    // If only one day, unable to parse.
    if (widget.plotData.keys.isEmpty) {
      log.info("[ElectricityAverageUsageGraph] Not enough data, quit!");

      return Text(
        FlutterI18n.translate(context, "electricity.not_enough_data"),
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
  final SplayTreeMap<(DateTime, DateTime), double> plotData;
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
    List<TextPainter> titles = plotData.keys.map((v) {
      return TextPainter(
        text: TextSpan(
          text: "${v.$1.month}.${v.$1.day}~${v.$2.month}.${v.$2.day}",
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

    List<TextPainter> values = plotData.values.map((v) {
      return TextPainter(
        text: TextSpan(
          text: v.toStringAsFixed(2),
          style: Theme.of(context).textTheme.labelSmall!.copyWith(
            fontSize: _GraphMetrics.tooltipFontSize,
            fontWeight: _GraphMetrics.axisLabelFontWeight,
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
    double maxNum = plotData.values.fold(
      0.0,
      (previous, current) => current > previous ? current : previous,
    );
    double minNum = plotData.values.fold(
      0.0,
      (previous, current) => current < previous ? current : previous,
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
      double rectWidth =
          paintRange /
          (maxNum - minNum) *
          (plotData.values.toList()[i] - minNum);
      canvas.drawRect(
        Rect.fromLTWH(rectLeftStart, rectTopStart, rectWidth, rectHeight),
        _fillPaint,
      );

      double valueLeftStart =
          rectLeftStart + rectWidth + _GraphMetrics.lineWidth / 2;
      double valueTopStart = rowHeight * (i + 0.5) - longestTitleHeight * 0.5;
      values[i].paint(canvas, Offset(valueLeftStart, valueTopStart));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
