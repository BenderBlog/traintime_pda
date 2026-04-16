// Copyright 2026 Traintime PDA Authours, originally by BenderBlog Rodriguez.
// SPDX-License-Identifier: MPL-2.0

import 'dart:collection';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:watermeter/model/xidian_ids/electricity.dart';
import 'package:watermeter/repository/logger.dart';

class _GraphMetrics {
  static const double chartHorizontalPadding = 30;
  static const double chartRightReserved = 20;
  static const double chartTopPadding = 10;
  static const double chartBottomPadding = 30;

  static const int defaultYAxisLabelCount = 4;
  static const int defaultYAxisSegmentCount = 5;
  static const double yAxisPaddingValue = 50;
  static const double flatDataExtraValue = 1;

  static const double pointHitTestRadius = 8;

  static const double tooltipCardWidth = 90;
  static const double tooltipCardHeight = 48;
  static const double tooltipPadding = 4;
  static const double tooltipFontSize = 9;

  static const double lineStrokeWidth = 2;
  static const double pointStrokeWidth = 6;
  static const double axisLabelOffsetY = 16;
  static const double xAxisBottomOffset = chartBottomPadding;

  static const FontWeight axisLabelFontWeight = FontWeight.w400;
}

class ElectricityUsageGraph extends StatefulWidget {
  late final SplayTreeMap<DateTime, double> data;
  late final List<Offset> points;
  late final Map<int, double> lines;
  late final Map<DateTime, double> markAtX;
  final double graphHeight;
  final double graphWidth;
  ElectricityUsageGraph({
    super.key,
    required List<ElectricityInfo> historyElectricityInfo,
    required this.graphHeight,
    required this.graphWidth,
  }) {
    data = SplayTreeMap();
    // Parsing number, store the latest data.
    // Notice that the historyElectricityInfo have sorted.
    for (final info in historyElectricityInfo) {
      final v = double.tryParse(info.remain);
      if (v == null) continue;

      final dayTime = DateTime(
        info.fetchDay.year,
        info.fetchDay.month,
        info.fetchDay.day,
      );
      // If historyElectricityInfo have not sorted,
      // This line should be rewrite to ensure that the
      // latest data have been fetched.
      data[dayTime] = v;
    }

    log.info("[ElectricityWindow][ElectricityUsageGraph] Based on $data");

    if (data.isEmpty) {
      points = [];
      return;
    }

    // All chart elements should use the same plot bounds; otherwise points,
    // axis lines, and labels will drift apart into different coordinate systems.
    final dates = data.keys.toList();
    final plotLeft = _GraphMetrics.chartHorizontalPadding;
    final plotRight = graphWidth - _GraphMetrics.chartRightReserved;
    final plotTop = _GraphMetrics.chartTopPadding;
    final plotBottom = graphHeight - _GraphMetrics.chartBottomPadding;
    final plotWidth = plotRight - plotLeft;
    final plotHeight = plotBottom - plotTop;

    // Horizontal Step
    final step = dates.last.difference(dates.first).inDays + 2;
    final horizontalStep = plotWidth / step;
    log.info(
      "[SelfGraph] horizontalstep $horizontalStep, from width $graphWidth and step $step",
    );

    // Vertical Step
    // Point's initial point is at the upper left corner
    final rawBiggestValue = data.values.reduce((a, b) => a > b ? a : b);
    final rawSmallestValue = data.values.reduce((a, b) => a > b ? b : a);
    final isFlatData = rawBiggestValue == rawSmallestValue;
    // Flat data still needs a non-zero range so the single horizontal line can
    // be placed around the visual middle instead of collapsing to the bottom.
    double biggestValue = isFlatData
        ? rawBiggestValue + _GraphMetrics.flatDataExtraValue
        : rawBiggestValue + _GraphMetrics.yAxisPaddingValue;
    double smallestValue = isFlatData
        ? max(rawSmallestValue - _GraphMetrics.flatDataExtraValue, 0)
        : max(rawSmallestValue - _GraphMetrics.yAxisPaddingValue, 0);
    final verticalStep = plotHeight / (biggestValue - smallestValue);
    log.info(
      "[SelfGraph] verticalstep $verticalStep, "
      "from $plotHeight / ($biggestValue - $smallestValue), "
      "height $graphHeight",
    );

    // List of Points based on horizontal and vertical step
    points = dates.map<Offset>((k) {
      return Offset(
        horizontalStep * (k.difference(dates.first).inDays + 1) + plotLeft,
        plotBottom - (data[k]! - smallestValue) * verticalStep,
      );
    }).toList();

    final markCount = min(dates.length, 5);
    if (markCount == 1) {
      markAtX = {dates.first: points.first.dx};
    } else {
      // Sample existing points instead of regenerating dates from fractional
      // day steps, so short ranges cannot produce duplicate tick dates.
      final markIndices = List.generate(
        markCount,
        (i) => (i * (dates.length - 1) / (markCount - 1)).round(),
      );
      markAtX = {
        for (final index in markIndices) dates[index]: points[index].dx,
      };
    }

    log.info(
      "[SelfGraph] Preliminary there are ${points.length} dot(s), "
      "$points",
    );

    if (isFlatData) {
      lines = {rawBiggestValue.toInt(): plotTop + plotHeight / 2};
      return;
    }
    final verticalkeyStep =
        (biggestValue - smallestValue) / _GraphMetrics.defaultYAxisSegmentCount;
    final List<double> keys = List.generate(
      _GraphMetrics.defaultYAxisLabelCount,
      (i) => biggestValue - (i + 1) * verticalkeyStep,
    );
    lines = {
      for (final value in keys)
        value.toInt(): plotBottom - (value - smallestValue) * verticalStep,
    };
  }

  @override
  State<ElectricityUsageGraph> createState() => _ElectricityUsageGraphState();
}

class _ElectricityUsageGraphState extends State<ElectricityUsageGraph> {
  (Offset, DateTime, double)? _selected;

  void _handleTap(TapDownDetails details) {
    if (widget.data.isEmpty) return;

    final Offset tapPosition = details.localPosition;
    int closestIndex = -1;
    double minDistance = double.infinity;

    for (int i = 0; i < widget.points.length; i++) {
      double distance = (widget.points[i] - tapPosition).distance;
      if (distance < minDistance &&
          distance < _GraphMetrics.pointHitTestRadius) {
        minDistance = distance;
        closestIndex = i;
      }
    }

    setState(() {
      if (closestIndex >= 0) {
        _selected = (
          widget.points[closestIndex],
          widget.data.keys.toList()[closestIndex],
          widget.data.values.toList()[closestIndex],
        );
      } else {
        _selected = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.data.isEmpty) {
      log.info(
        "[ElectricityWindow][ElectricityUsageGraph] "
        "Not enough data, quit!",
      );

      return Text(
        FlutterI18n.translate(context, "electricity.not_enough_data"),
        textAlign: TextAlign.center,

        style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
      ).width(double.infinity);
    }

    return GestureDetector(
      onTapDown: (details) {
        _handleTap(details);
      },
      child: Stack(
        children: [
          // Paint the line which passes the dots.
          RepaintBoundary(
            child: CustomPaint(
              painter: LineChartPainter(
                points: widget.points,
                color: Theme.of(context).primaryColor,
              ),
              child: SizedBox(
                width: widget.graphWidth,
                height: widget.graphHeight,
              ),
            ),
          ),

          // Paint the dots.
          RepaintBoundary(
            child: CustomPaint(
              painter: PoiotPainter(
                points: widget.points,
                color: Theme.of(context).primaryColor,
              ),
              child: RepaintBoundary(
                child: SizedBox(
                  width: widget.graphWidth,
                  height: widget.graphHeight,
                ),
              ),
            ),
          ),

          // Paint the background lines.
          RepaintBoundary(
            child: CustomPaint(
              painter: BackgroundLinePainter(
                context: context,
                offset: widget.lines,
                markAtX: widget.markAtX,
              ),
              child: RepaintBoundary(
                child: SizedBox(
                  width: widget.graphWidth,
                  height: widget.graphHeight,
                ),
              ),
            ),
          ),

          if (_selected != null)
            Positioned(
              left: min(
                _selected!.$1.dx,
                widget.graphWidth - _GraphMetrics.tooltipCardWidth,
              ),
              top: min(
                _selected!.$1.dy,
                widget.graphHeight - _GraphMetrics.tooltipCardHeight,
              ),
              child: Card.outlined(
                child: Padding(
                  padding: EdgeInsets.all(_GraphMetrics.tooltipPadding),
                  child: Text(
                    "Date: ${_selected!.$2.month}.${_selected!.$2.day}\n"
                    "Amount: ${_selected!.$3.toStringAsFixed(2)}",
                    style: Theme.of(context).textTheme.labelSmall!.copyWith(
                      fontSize: _GraphMetrics.tooltipFontSize,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class LineChartPainter extends CustomPainter {
  final List<Offset> points;
  final Color color;
  late final Paint _strokePaint;

  LineChartPainter({required this.points, required this.color}) {
    _strokePaint = Paint()
      ..strokeWidth = _GraphMetrics.lineStrokeWidth
      ..color = color
      ..style = PaintingStyle.stroke;
  }

  Path _getPath(List<Offset> points) {
    if (points.isEmpty) return Path();

    // Calculate Paths
    final path = Path()..moveTo(points.first.dx, points.first.dy);

    // At least four points is required to paint the curve
    if (points.length < 2) {
    } else if (points.length < 3) {
      path.lineTo(points.last.dx, points.last.dy);
    } else {
      // CatmullRomSpline require at least 4 dots, copy the head and tail dots.
      final splineInput = List<Offset>.from(points);
      if (splineInput.length == 3) {
        splineInput.insert(0, splineInput.first);
        splineInput.add(splineInput.last);
      }

      // AI-generated how to paint Catmull-Rom splines with Flutter
      final spline = CatmullRomSpline(splineInput, tension: 0.0);
      final List<Curve2DSample> samples = spline.generateSamples().toList();
      if (samples.isNotEmpty) {
        path.moveTo(samples.first.value.dx, samples.first.value.dy);
        for (var sample in samples.skip(1)) {
          path.lineTo(sample.value.dx, sample.value.dy);
        }
      }
    }

    return path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;
    final path = _getPath(points);
    canvas.drawPath(path, _strokePaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class PoiotPainter extends CustomPainter {
  final List<Offset> points;
  final Color color;
  late final Paint _dotPaint;

  PoiotPainter({super.repaint, required this.points, required this.color}) {
    _dotPaint = Paint()
      ..strokeWidth = _GraphMetrics.pointStrokeWidth
      ..color = color
      ..strokeCap = StrokeCap.round;
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPoints(PointMode.points, points, _dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class BackgroundLinePainter extends CustomPainter {
  Map<int, double> offset;
  final BuildContext context;
  late final Paint _strokePaint;
  final Map<DateTime, double> markAtX;

  BackgroundLinePainter({
    super.repaint,
    required this.offset,
    required this.context,
    required this.markAtX,
  }) {
    _strokePaint = Paint()..style = PaintingStyle.stroke;
  }

  @override
  void paint(Canvas canvas, Size size) {
    for (var i in offset.keys) {
      canvas.drawLine(
        Offset(0, offset[i]!),
        Offset(size.width, offset[i]!),
        _strokePaint,
      );
      TextPainter textPainter = TextPainter(
        text: TextSpan(
          text: i.toString(),
          style: Theme.of(context).textTheme.labelSmall!.copyWith(
            fontSize: _GraphMetrics.tooltipFontSize,
            fontWeight: _GraphMetrics.axisLabelFontWeight,
          ),
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(
        canvas,
        Offset(0, offset[i]! - _GraphMetrics.axisLabelOffsetY),
      );
    }
    canvas.drawLine(
      Offset(0, size.height - _GraphMetrics.xAxisBottomOffset),
      Offset(size.width, size.height - _GraphMetrics.xAxisBottomOffset),
      _strokePaint,
    );

    for (var i in markAtX.keys) {
      TextPainter textPainter = TextPainter(
        text: TextSpan(
          text: "${i.month}.${i.day}",
          style: Theme.of(context).textTheme.labelSmall!.copyWith(
            fontSize: _GraphMetrics.tooltipFontSize,
            fontWeight: _GraphMetrics.axisLabelFontWeight,
          ),
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(
        canvas,
        Offset(
          markAtX[i]! - textPainter.width / 2,
          size.height - _GraphMetrics.axisLabelOffsetY,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
