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

    // Horizontal Step
    int step = data.keys.last.difference(data.keys.first).inDays + 2;
    final horizontalStep = (graphWidth - 50) / step;
    log.info(
      "[SelfGraph] horizontalstep $horizontalStep, from width $graphWidth and step $step",
    );

    final keynum = min(data.length, 4);
    final keyStep = data.keys.last.difference(data.keys.first).inDays / keynum;
    final xstep = (graphWidth - 50) / keynum;
    final datekey = List.generate(
      keynum + 1,
      (i) => data.keys.first.add(Duration(days: (i * keyStep).toInt())),
    );
    final datevalues = List.generate(keynum + 1, (i) => 24 + i * xstep);
    markAtX = {for (var i = 0; i < keynum + 1; ++i) datekey[i]: datevalues[i]};

    // Vertical Step
    // Point's initial point is at the upper left corner
    double minY = graphHeight - 30;
    double maxY = 10;
    double biggestValue = data.values.reduce((a, b) => a > b ? a : b);
    double smallestValue = data.values.reduce((a, b) => a > b ? b : a);
    double verticalStep = (biggestValue - smallestValue) / (minY - maxY);
    log.info(
      "[SelfGraph] verticalstep $verticalStep, "
      "from ($biggestValue - $smallestValue) / (${minY - maxY}), "
      "height $graphHeight",
    );

    // List of Points based on horizontal and vertical step
    points = data.keys.map<Offset>((k) {
      return Offset(
        horizontalStep * (k.difference(data.keys.first).inDays + 1) + 30,
        minY - (data[k]! - smallestValue) / verticalStep,
      );
    }).toList();

    if (biggestValue == smallestValue) {
      biggestValue = (biggestValue + 1);
      smallestValue = max(smallestValue - 1, 0);
      final lineOffsetBasic = graphHeight / 3;
      lines = {
        biggestValue.toInt(): lineOffsetBasic,
        smallestValue.toInt(): lineOffsetBasic * 2,
      };
      return;
    }
    biggestValue = biggestValue + 50;
    smallestValue = max(smallestValue - 50, 0);
    final verticalkeyStep = (biggestValue - smallestValue) / 5;
    final lineOffsetBasic = graphHeight / 5;
    final keys = List.generate(
      4,
      (i) => (biggestValue - (i + 1) * verticalkeyStep).toInt(),
    );
    final values = List.generate(4, (i) => (i + 1) * lineOffsetBasic);
    lines = {for (var i = 0; i < 4; ++i) keys[i]: values[i]};
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
      if (distance < minDistance && distance < 8) {
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
              left: min(_selected!.$1.dx, widget.graphWidth - 90),
              top: min(_selected!.$1.dy, widget.graphHeight - 48),
              child: Card.outlined(
                child: Padding(
                  padding: EdgeInsets.all(4),
                  child: Text(
                    "Date: ${_selected!.$2.month}.${_selected!.$2.day}\n"
                    "Amount: ${_selected!.$3.toStringAsFixed(2)}",
                    style: Theme.of(
                      context,
                    ).textTheme.labelSmall!.copyWith(fontSize: 9),
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
      ..strokeWidth = 2.0
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
      if (points.length == 3) {
        points.insert(0, points.first);
        points.add(points.last);
      }

      // AI-generated how to paint Catmull-Rom splines with Flutter
      final spline = CatmullRomSpline(points, tension: 0.0);
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
      ..strokeWidth = 6.0
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
            fontSize: 9,
            fontWeight: FontWeight.w400,
          ),
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(canvas, Offset(0, offset[i]! - 16));
    }
    canvas.drawLine(
      Offset(0, size.height - 24),
      Offset(size.width, size.height - 24),
      _strokePaint,
    );

    for (var i in markAtX.keys) {
      TextPainter textPainter = TextPainter(
        text: TextSpan(
          text: "${i.month}.${i.day}",
          style: Theme.of(context).textTheme.labelSmall!.copyWith(
            fontSize: 9,
            fontWeight: FontWeight.w400,
          ),
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(canvas, Offset(markAtX[i]!, size.height - 16));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
